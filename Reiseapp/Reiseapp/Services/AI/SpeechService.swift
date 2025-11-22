//
//  SpeechService.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  Speech Recognition and Text-to-Speech Service
//

import Foundation
import Speech
import AVFoundation

extension Notification.Name {
    static let speechAuthorizationChanged = Notification.Name("speechAuthorizationChanged")
}

class SpeechService: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    @Published var isListening = false
    @Published var transcript = ""
    @Published var isSpeaking = false
    @Published var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined
    @Published var lastError: String?
    
    // MARK: - Speech Recognition Properties
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "de-DE"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    // MARK: - Text-to-Speech Properties
    
    private let synthesizer = AVSpeechSynthesizer()
    
    override init() {
        super.init()
        synthesizer.delegate = self
        // Don't request authorization immediately - wait for user to activate voice assistant
        authorizationStatus = SFSpeechRecognizer.authorizationStatus()
    }
    
    // MARK: - Authorization
    
    @MainActor
    func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                self?.authorizationStatus = authStatus
                
                switch authStatus {
                case .authorized:
                    print("✅ Speech recognition authorized")
                    // Post notification that authorization succeeded
                    NotificationCenter.default.post(name: .speechAuthorizationChanged, object: authStatus)
                case .denied:
                    self?.lastError = "Spracherkennung wurde verweigert"
                case .restricted:
                    self?.lastError = "Spracherkennung ist eingeschränkt"
                case .notDetermined:
                    self?.lastError = "Spracherkennung nicht bestimmt"
                @unknown default:
                    self?.lastError = "Unbekannter Autorisierungsstatus"
                }
            }
        }
    }
    
    // MARK: - Start/Stop Listening
    
    @MainActor
    func startListening() throws {
        guard authorizationStatus == .authorized else {
            throw SpeechError.notAuthorized
        }
        
        guard !isListening else { return }
        
        // Cancel any ongoing recognition task
        stopListening()
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestCreationFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        recognitionRequest.requiresOnDeviceRecognition = false
        
        let inputNode = audioEngine.inputNode
        
        // Start recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let result = result {
                    self.transcript = result.bestTranscription.formattedString
                    
                    // Check if recognition is final
                    if result.isFinal {
                        self.stopListening()
                    }
                } else if let error = error {
                    self.lastError = "Erkennungsfehler: \(error.localizedDescription)"
                    self.stopListening()
                }
            }
        }
        
        // Configure audio input
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        audioEngine.prepare()
        try audioEngine.start()
        
        isListening = true
        transcript = ""
        print("🎤 Started listening...")
    }
    
    @MainActor
    func stopListening() {
        guard isListening else { return }
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        
        recognitionRequest = nil
        recognitionTask = nil
        isListening = false
        
        print("🛑 Stopped listening")
    }
    
    // MARK: - Text-to-Speech
    
    @MainActor
    func speak(_ text: String, language: String = "de-DE") {
        guard !isSpeaking else { return }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: language)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 0.9
        
        isSpeaking = true
        synthesizer.speak(utterance)
        print("🔊 Speaking: \(text)")
    }
    
    @MainActor
    func stopSpeaking() {
        synthesizer.stopSpeaking(at: .immediate)
        isSpeaking = false
    }
    
    // MARK: - Toggle Listening
    
    @MainActor
    func toggleListening() {
        if isListening {
            stopListening()
        } else {
            do {
                try startListening()
            } catch {
                lastError = "Fehler beim Starten der Spracherkennung: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - AVSpeechSynthesizerDelegate

extension SpeechService: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = true
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        DispatchQueue.main.async {
            self.isSpeaking = false
        }
    }
}

// MARK: - Speech Errors

enum SpeechError: LocalizedError {
    case notAuthorized
    case requestCreationFailed
    case audioEngineError
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Spracherkennung nicht autorisiert"
        case .requestCreationFailed:
            return "Anfrage konnte nicht erstellt werden"
        case .audioEngineError:
            return "Audio Engine Fehler"
        }
    }
}