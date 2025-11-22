//
//  AIAssistantService.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  Haupter AI Assistant Service - koordiniert Sprache, OpenAI und App-Steuerung
//

import Foundation
import SwiftUI
import Speech

class AIAssistantService: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var isActive = false
    @Published var voiceState: VoiceState = .idle
    @Published var currentTranscript = ""
    @Published var assistantResponse = ""
    @Published var conversationHistory: [ChatMessage] = []
    @Published var travelContext = TravelContext()
    @Published var lastError: String?
    @Published var isProcessingCommand = false
    
    // MARK: - Services
    
    private let speechService = SpeechService()
    private let openAIService: OpenAIService
    private let commandHandler = AICommandHandler()
    
    // MARK: - Configuration
    
    private let maxHistoryMessages = 10
    private let responseTimeout: TimeInterval = 30
    
    // MARK: - Initialization
    
    init(openAIAPIKey: String? = nil) {
        self.openAIService = OpenAIService(apiKey: openAIAPIKey)
        setupBindings()
    }
    
    @MainActor
    func configure(exploreViewModel: ExploreViewModel, appEnvironment: AppEnvironment) {
        commandHandler.configure(exploreViewModel: exploreViewModel, appEnvironment: appEnvironment)
    }
    
    // MARK: - Setup
    
    private func setupBindings() {
        // Bind speech service transcript to our property
        speechService.$transcript
            .assign(to: &$currentTranscript)
        
        // Monitor transcript changes for voice commands
        $currentTranscript
            .debounce(for: .seconds(1.5), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] transcript in
                if !transcript.isEmpty && self?.speechService.isListening == false {
                    Task {
                        await self?.processVoiceInput(transcript)
                    }
                }
            }
            .store(in: &cancellables)
        
        // Update voice state based on speech service
        speechService.$isListening
            .combineLatest(speechService.$isSpeaking)
            .map { isListening, isSpeaking in
                if isListening { return VoiceState.listening }
                if isSpeaking { return VoiceState.speaking }
                return VoiceState.idle
            }
            .assign(to: &$voiceState)
        
        // Listen for speech authorization changes
        NotificationCenter.default.publisher(for: .speechAuthorizationChanged)
            .sink { [weak self] notification in
                if let authStatus = notification.object as? SFSpeechRecognizerAuthorizationStatus,
                   authStatus == .authorized,
                   let self = self,
                   self.isActive {
                    Task { @MainActor in
                        self.startListening()
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Main Voice Interaction Methods
    
    @MainActor
    func startVoiceAssistant() {
        guard !isActive else { return }
        
        isActive = true
        lastError = nil
        
        // Request permissions if needed
        if speechService.authorizationStatus != .authorized {
            speechService.requestAuthorization()
            // Wait for authorization result - startListening will be called when authorized
            return
        }
        
        startListening()
    }
    
    @MainActor
    func stopVoiceAssistant() {
        isActive = false
        speechService.stopListening()
        speechService.stopSpeaking()
        voiceState = .idle
    }
    
    @MainActor
    func toggleVoiceAssistant() {
        if isActive {
            stopVoiceAssistant()
        } else {
            startVoiceAssistant()
        }
    }
    
    @MainActor
    private func startListening() {
        guard isActive else { return }
        
        do {
            try speechService.startListening()
            voiceState = .listening
            print("🎤 AI Assistant listening...")
        } catch {
            lastError = "Spracherkennung konnte nicht gestartet werden: \(error.localizedDescription)"
            voiceState = .error(error.localizedDescription)
        }
    }
    
    // MARK: - Voice Input Processing
    
    @MainActor
    private func processVoiceInput(_ transcript: String) async {
        guard !transcript.isEmpty, isActive else { return }
        
        // Check if OpenAI is configured
        guard openAIService.isConfigured else {
            let errorMessage = "KI-Assistent nicht konfiguriert. OpenAI API-Schlüssel fehlt."
            lastError = errorMessage
            assistantResponse = errorMessage
            speechService.speak(errorMessage)
            voiceState = .error("API-Schlüssel fehlt")
            isProcessingCommand = false
            return
        }
        
        voiceState = .processing
        isProcessingCommand = true
        
        do {
            print("🗣️ Processing voice input: \(transcript)")
            
            // Add user message to conversation
            addToConversation(role: "user", content: transcript)
            
            // Process with OpenAI to get command
            let command = try await openAIService.processNaturalLanguage(transcript, context: travelContext)
            
            // Execute the command via command handler
            let response = await commandHandler.execute(command)
            
            // Update context based on command
            updateTravelContext(from: command)
            
            // Add assistant response to conversation
            addToConversation(role: "assistant", content: response.message)
            
            // Speak the response
            assistantResponse = response.message
            speechService.speak(response.message)
            
            // Update state
            lastError = response.success ? nil : response.error
            isProcessingCommand = false
            
            print("✅ Command executed successfully: \(response.message)")
            
        } catch {
            lastError = "Fehler bei der Verarbeitung: \(error.localizedDescription)"
            let errorMessage = "Entschuldigung, ich konnte Ihre Anfrage nicht verarbeiten. Versuchen Sie es erneut."
            
            assistantResponse = errorMessage
            speechService.speak(errorMessage)
            
            isProcessingCommand = false
            voiceState = .error(error.localizedDescription)
            
            print("❌ Error processing voice input: \(error)")
        }
        
        // Start listening again after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self, self.isActive else { return }
            // Only restart listening if not in error state
            switch self.voiceState {
            case .error:
                break // Don't restart if there's an error
            default:
                self.startListening()
            }
        }
    }
    
    // MARK: - Direct Text Processing (for testing)
    
    @MainActor
    func processTextInput(_ text: String) async {
        await processVoiceInput(text)
    }
    
    // MARK: - Test Function
    
    @MainActor
    func testAIIntegration() async -> Bool {
        guard openAIService.isConfigured else {
            lastError = "OpenAI API Key nicht konfiguriert"
            return false
        }
        
        do {
            print("🧪 Testing AI integration with sample command...")
            let testCommand = try await openAIService.processNaturalLanguage(
                "Suche Hotels in Berlin für 2 Gäste",
                context: travelContext
            )
            print("✅ AI Integration test successful: \(testCommand.type.rawValue)")
            return true
        } catch {
            print("❌ AI Integration test failed: \(error)")
            lastError = "AI Test fehlgeschlagen: \(error.localizedDescription)"
            return false
        }
    }
    
    // MARK: - Conversation Management
    
    @MainActor
    private func addToConversation(role: String, content: String) {
        let message = ChatMessage(role: role, content: content)
        conversationHistory.append(message)
        
        // Keep only recent messages
        if conversationHistory.count > maxHistoryMessages {
            conversationHistory.removeFirst()
        }
    }
    
    @MainActor
    private func updateTravelContext(from command: AICommand) {
        // Update travel context based on executed command
        switch command.type {
        case .searchHotels, .searchFlights:
            if let destination = command.parameters["destination"] as? String {
                travelContext.currentDestination = destination
            }
            if let guests = command.parameters["guests"] as? Int {
                travelContext.numberOfGuests = guests
            }
            if let passengers = command.parameters["passengers"] as? Int {
                travelContext.numberOfGuests = passengers
            }
            if let directOnly = command.parameters["direct_only"] as? Bool {
                travelContext.directFlightsOnly = directOnly
            }
            
        default:
            break
        }
    }
    
    @MainActor
    func clearConversation() {
        conversationHistory.removeAll()
        travelContext = TravelContext()
        assistantResponse = ""
        currentTranscript = ""
    }
    
    // MARK: - Wake Word Detection (Future)
    
    @MainActor
    func enableWakeWord(_ enabled: Bool) {
        // TODO: Implement wake word detection
        // For now, just toggle active state
        if enabled && !isActive {
            startVoiceAssistant()
        } else if !enabled && isActive {
            stopVoiceAssistant()
        }
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    func getVoiceStateDescription() -> String {
        switch voiceState {
        case .idle:
            return "Bereit"
        case .listening:
            return "Höre zu..."
        case .processing:
            return "Verarbeite..."
        case .speaking:
            return "Spreche..."
        case .error(let message):
            return "Fehler: \(message)"
        }
    }
    
    @MainActor
    func getVoiceStateColor() -> Color {
        switch voiceState {
        case .idle:
            return .gray
        case .listening:
            return .blue
        case .processing:
            return .orange
        case .speaking:
            return .green
        case .error:
            return .red
        }
    }
    
    @MainActor
    func getVoiceStateIcon() -> String {
        switch voiceState {
        case .idle:
            return "mic.slash"
        case .listening:
            return "mic.fill"
        case .processing:
            return "gearshape"
        case .speaking:
            return "speaker.wave.2"
        case .error:
            return "exclamationmark.triangle"
        }
    }
}

// MARK: - Combine Import

import Combine