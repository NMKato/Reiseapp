//
//  OpenAIService.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  OpenAI API Integration Service
//

import Foundation

class OpenAIService: ObservableObject {
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-4-turbo-preview"
    private let networkManager: NetworkManaging
    
    @Published var isProcessing = false
    @Published var lastError: String?
    
    var isConfigured: Bool {
        return !apiKey.isEmpty
    }
    
    init(apiKey: String? = nil, networkManager: NetworkManaging = NetworkManager.shared) {
        // SECURE: API key must be provided via environment variables or parameter
        // Never hardcode API keys in source code for security!
        self.apiKey = apiKey ?? SecureConfiguration.openAIAPIKey ?? ""
        self.networkManager = networkManager
        
        if self.apiKey.isEmpty {
            print("⚠️ OpenAI API Key not configured. AI features will be disabled.")
            print("💡 To enable AI features:")
            print("   1. Get API key from https://platform.openai.com/account/api-keys")
            print("   2. Add OPENAI_API_KEY to your Xcode scheme environment variables")
            print("   3. See SECURITY.md for detailed setup instructions")
        } else {
            print("✅ OpenAI API Key configured successfully (\(SecureConfiguration.maskAPIKey(self.apiKey)))")
        }
        
        #if DEBUG
        SecureConfiguration.printConfigurationStatus()
        #endif
    }
    
    // MARK: - Main Chat Function with Function Calling
    
    func chat(messages: [ChatMessage], 
              functions: [ChatFunction]? = nil,
              temperature: Double = 0.7) async throws -> OpenAIResponse {
        
        guard !apiKey.isEmpty else {
            throw AIError.missingAPIKey
        }
        
        isProcessing = true
        defer { isProcessing = false }
        
        let request = OpenAIRequest(
            model: model,
            messages: messages,
            functions: functions,
            functionCall: functions != nil ? "auto" : nil,
            temperature: temperature,
            maxTokens: 1000
        )
        
        let requestData = try JSONEncoder().encode(request)
        
        let endpoint = Endpoint(
            baseURL: baseURL,
            path: "",
            method: .POST,
            headers: [
                "Authorization": "Bearer \(apiKey)",
                "Content-Type": "application/json"
            ],
            body: requestData
        )
        
        do {
            let response = try await networkManager.request(endpoint, type: OpenAIResponse.self)
            return response
        } catch {
            lastError = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Process Natural Language to Command
    
    func processNaturalLanguage(_ text: String, context: TravelContext) async throws -> AICommand {
        let systemPrompt = createSystemPrompt()
        let userMessage = createUserMessage(text, context: context)
        
        let messages = [
            ChatMessage(role: "system", content: systemPrompt),
            ChatMessage(role: "user", content: userMessage)
        ]
        
        let functions = createTravelFunctions()
        
        let response = try await chat(messages: messages, functions: functions)
        
        // Parse function call from response
        if let functionCall = response.choices.first?.message.functionCall {
            return try parseAICommand(from: functionCall, originalText: text)
        } else {
            // Fallback to text response
            let message = response.choices.first?.message.content ?? ""
            return AICommand(type: .unknown, parameters: ["message": message], rawText: text)
        }
    }
    
    // MARK: - Private Helper Methods
    
    private func createSystemPrompt() -> String {
        """
        Du bist ein hilfreicher Reiseassistent für eine deutsche Reise-App.
        Du hilfst Nutzern bei der Suche nach Hotels, Flügen und der Reiseplanung.
        
        Wichtige Informationen:
        - Antworte immer auf Deutsch
        - Sei freundlich und hilfsbereit
        - Verwende die bereitgestellten Funktionen, um Aktionen auszuführen
        - Frage nach fehlenden Informationen, bevor du eine Funktion aufrufst
        - Gib klare Bestätigungen nach erfolgreichen Aktionen
        
        Verfügbare Funktionen:
        - search_hotels: Suche nach Hotels
        - search_flights: Suche nach Flügen
        - book_hotel: Buche ein Hotel
        - book_flight: Buche einen Flug
        - get_weather: Wetterinformationen abrufen
        - create_trip: Neue Reise erstellen
        """
    }
    
    private func createUserMessage(_ text: String, context: TravelContext) -> String {
        var contextInfo = "Aktueller Kontext:\n"
        
        if let destination = context.currentDestination {
            contextInfo += "- Reiseziel: \(destination)\n"
        }
        if let checkIn = context.checkInDate {
            contextInfo += "- Check-in: \(formatDate(checkIn))\n"
        }
        if let checkOut = context.checkOutDate {
            contextInfo += "- Check-out: \(formatDate(checkOut))\n"
        }
        contextInfo += "- Gäste: \(context.numberOfGuests)\n"
        contextInfo += "- Flugklasse: \(context.flightClass)\n"
        
        return """
        \(contextInfo)
        
        Nutzeranfrage: \(text)
        """
    }
    
    private func createTravelFunctions() -> [ChatFunction] {
        [
            ChatFunction(
                name: "search_hotels",
                description: "Suche nach Hotels in einem bestimmten Reiseziel",
                parameters: ChatFunctionParameters(
                    properties: [
                        "destination": ChatFunctionProperty(
                            type: "string",
                            description: "Das Reiseziel (Stadt oder Region)",
                            enumValues: nil
                        ),
                        "check_in_date": ChatFunctionProperty(
                            type: "string",
                            description: "Check-in Datum im Format YYYY-MM-DD",
                            enumValues: nil
                        ),
                        "check_out_date": ChatFunctionProperty(
                            type: "string",
                            description: "Check-out Datum im Format YYYY-MM-DD",
                            enumValues: nil
                        ),
                        "guests": ChatFunctionProperty(
                            type: "integer",
                            description: "Anzahl der Gäste",
                            enumValues: nil
                        ),
                        "max_price": ChatFunctionProperty(
                            type: "number",
                            description: "Maximaler Preis pro Nacht (optional)",
                            enumValues: nil
                        )
                    ],
                    required: ["destination", "check_in_date", "check_out_date", "guests"]
                )
            ),
            
            ChatFunction(
                name: "search_flights",
                description: "Suche nach Flügen zwischen zwei Orten",
                parameters: ChatFunctionParameters(
                    properties: [
                        "origin": ChatFunctionProperty(
                            type: "string",
                            description: "Abflugort (Stadt oder Flughafencode)",
                            enumValues: nil
                        ),
                        "destination": ChatFunctionProperty(
                            type: "string",
                            description: "Zielort (Stadt oder Flughafencode)",
                            enumValues: nil
                        ),
                        "departure_date": ChatFunctionProperty(
                            type: "string",
                            description: "Abflugdatum im Format YYYY-MM-DD",
                            enumValues: nil
                        ),
                        "return_date": ChatFunctionProperty(
                            type: "string",
                            description: "Rückflugdatum im Format YYYY-MM-DD (optional)",
                            enumValues: nil
                        ),
                        "passengers": ChatFunctionProperty(
                            type: "integer",
                            description: "Anzahl der Passagiere",
                            enumValues: nil
                        ),
                        "direct_only": ChatFunctionProperty(
                            type: "boolean",
                            description: "Nur Direktflüge anzeigen",
                            enumValues: nil
                        )
                    ],
                    required: ["origin", "destination", "departure_date", "passengers"]
                )
            ),
            
            ChatFunction(
                name: "get_weather",
                description: "Wetterinformationen für ein Reiseziel abrufen",
                parameters: ChatFunctionParameters(
                    properties: [
                        "destination": ChatFunctionProperty(
                            type: "string",
                            description: "Das Reiseziel",
                            enumValues: nil
                        ),
                        "date": ChatFunctionProperty(
                            type: "string",
                            description: "Datum für Wettervorhersage (optional)",
                            enumValues: nil
                        )
                    ],
                    required: ["destination"]
                )
            ),
            
            ChatFunction(
                name: "create_trip",
                description: "Erstelle eine neue Reise",
                parameters: ChatFunctionParameters(
                    properties: [
                        "title": ChatFunctionProperty(
                            type: "string",
                            description: "Titel der Reise",
                            enumValues: nil
                        ),
                        "destination": ChatFunctionProperty(
                            type: "string",
                            description: "Reiseziel",
                            enumValues: nil
                        ),
                        "start_date": ChatFunctionProperty(
                            type: "string",
                            description: "Startdatum im Format YYYY-MM-DD",
                            enumValues: nil
                        ),
                        "end_date": ChatFunctionProperty(
                            type: "string",
                            description: "Enddatum im Format YYYY-MM-DD",
                            enumValues: nil
                        ),
                        "adults": ChatFunctionProperty(
                            type: "integer",
                            description: "Anzahl Erwachsene",
                            enumValues: nil
                        )
                    ],
                    required: ["title", "destination", "start_date", "end_date"]
                )
            )
        ]
    }
    
    private func parseAICommand(from functionCall: OpenAIFunctionCall, originalText: String) throws -> AICommand {
        let type = AICommandType(rawValue: functionCall.name) ?? .unknown
        
        guard let data = functionCall.arguments.data(using: .utf8),
              let parameters = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AIError.invalidFunctionArguments
        }
        
        return AICommand(type: type, parameters: parameters, rawText: originalText)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}

// MARK: - AI Errors

enum AIError: LocalizedError {
    case missingAPIKey
    case invalidFunctionArguments
    case networkError(String)
    case processingError(String)
    
    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API Key fehlt"
        case .invalidFunctionArguments:
            return "Ungültige Funktionsargumente"
        case .networkError(let message):
            return "Netzwerkfehler: \(message)"
        case .processingError(let message):
            return "Verarbeitungsfehler: \(message)"
        }
    }
}
