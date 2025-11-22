//
//  AIModels.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  AI Assistant Models and Types
//

import Foundation

// MARK: - AI Command Types

enum AICommandType: String, Codable {
    case searchHotels = "search_hotels"
    case searchFlights = "search_flights"
    case bookHotel = "book_hotel"
    case bookFlight = "book_flight"
    case addToTrip = "add_to_trip"
    case getWeather = "get_weather"
    case getLocalExperiences = "get_local_experiences"
    case getTravelTips = "get_travel_tips"
    case createTrip = "create_trip"
    case showTrips = "show_trips"
    case unknown = "unknown"
}

// MARK: - AI Command

struct AICommand: Codable {
    let id: UUID
    let type: AICommandType
    let parameters: [String: Any]
    let timestamp: Date
    let rawText: String
    
    init(type: AICommandType, parameters: [String: Any], rawText: String) {
        self.id = UUID()
        self.type = type
        self.parameters = parameters
        self.timestamp = Date()
        self.rawText = rawText
    }
    
    // Custom Codable implementation for [String: Any]
    enum CodingKeys: String, CodingKey {
        case id, type, parameters, timestamp, rawText
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        type = try container.decode(AICommandType.self, forKey: .type)
        timestamp = try container.decode(Date.self, forKey: .timestamp)
        rawText = try container.decode(String.self, forKey: .rawText)
        
        // Decode parameters as Data
        if let data = try? container.decode(Data.self, forKey: .parameters),
           let params = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            parameters = params
        } else {
            parameters = [:]
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(rawText, forKey: .rawText)
        
        // Encode parameters as Data
        if let data = try? JSONSerialization.data(withJSONObject: parameters) {
            try container.encode(data, forKey: .parameters)
        }
    }
}

// MARK: - AI Response

struct AIResponse {
    let id: UUID
    let command: AICommand?
    let message: String
    let success: Bool
    let error: String?
    let suggestedActions: [String]
    
    init(command: AICommand? = nil, 
         message: String, 
         success: Bool = true, 
         error: String? = nil,
         suggestedActions: [String] = []) {
        self.id = UUID()
        self.command = command
        self.message = message
        self.success = success
        self.error = error
        self.suggestedActions = suggestedActions
    }
}

// MARK: - OpenAI Models

struct ChatMessage: Codable {
    let role: String
    let content: String
}

struct ChatFunction: Codable {
    let name: String
    let description: String
    let parameters: ChatFunctionParameters
}

struct ChatFunctionParameters: Codable {
    let type: String
    let properties: [String: ChatFunctionProperty]
    let required: [String]
    
    init(properties: [String: ChatFunctionProperty], required: [String] = []) {
        self.type = "object"
        self.properties = properties
        self.required = required
    }
}

struct ChatFunctionProperty: Codable {
    let type: String
    let description: String
    let enumValues: [String]?
    
    enum CodingKeys: String, CodingKey {
        case type, description
        case enumValues = "enum"
    }
}

// MARK: - OpenAI Request/Response

struct OpenAIRequest: Codable {
    let model: String
    let messages: [ChatMessage]
    let functions: [ChatFunction]?
    let functionCall: String?
    let temperature: Double
    let maxTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case model, messages, functions, temperature
        case functionCall = "function_call"
        case maxTokens = "max_tokens"
    }
}

struct OpenAIResponse: Codable {
    let id: String
    let choices: [OpenAIChoice]
    let usage: OpenAIUsage?
}

struct OpenAIChoice: Codable {
    let message: OpenAIMessage
    let finishReason: String?
    
    enum CodingKeys: String, CodingKey {
        case message
        case finishReason = "finish_reason"
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String?
    let functionCall: OpenAIFunctionCall?
    
    enum CodingKeys: String, CodingKey {
        case role, content
        case functionCall = "function_call"
    }
}

struct OpenAIFunctionCall: Codable {
    let name: String
    let arguments: String
}

struct OpenAIUsage: Codable {
    let promptTokens: Int
    let completionTokens: Int
    let totalTokens: Int
    
    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

// MARK: - Voice State

enum VoiceState: Equatable {
    case idle
    case listening
    case processing
    case speaking
    case error(String)
}

// MARK: - Travel Context

struct TravelContext {
    var currentDestination: String?
    var checkInDate: Date?
    var checkOutDate: Date?
    var numberOfGuests: Int
    var budget: Double?
    var preferredAmenities: [String]
    var flightClass: String
    var directFlightsOnly: Bool
    
    init() {
        self.numberOfGuests = 2
        self.preferredAmenities = []
        self.flightClass = "economy"
        self.directFlightsOnly = false
    }
}