//
//  APIConfiguration.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import Foundation

enum APIEnvironment {
    case development
    case production
    
    var baseURLs: APIBaseURLs {
        switch self {
        case .development, .production:
            return APIBaseURLs(
                weather: "https://api.openweathermap.org/data/2.5",
                amadeus: "https://test.api.amadeus.com",
                amadeusAuth: "https://test.api.amadeus.com/v1/security/oauth2/token",
                rapidAPIHotels: "https://hotels4.p.rapidapi.com",
                hasDataAirbnb: "https://api.hasdata.com/scrape/airbnb"
            )
        }
    }
}

struct APIBaseURLs {
    let weather: String
    let amadeus: String
    let amadeusAuth: String
    let rapidAPIHotels: String
    let hasDataAirbnb: String
}

final class APIConfiguration: ObservableObject {
    static let shared = APIConfiguration()
    
    private let environment: APIEnvironment = .development
    
    var baseURLs: APIBaseURLs {
        environment.baseURLs
    }
    
    // API Keys - SECURE: All keys loaded from environment variables
    // NEVER hardcode API keys in source code for security!
    struct APIKeys {
        // OpenWeatherMap API Key (Free tier: 1000 calls/day)
        // Add OPENWEATHER_API_KEY to your Xcode scheme environment variables
        static let openWeatherMap = SecureConfiguration.openWeatherAPIKey ?? ""
        
        // Amadeus API Credentials (Free tier: 500 calls/month)  
        // Add AMADEUS_CLIENT_ID and AMADEUS_CLIENT_SECRET to your Xcode scheme environment variables
        static let amadeusClientId = SecureConfiguration.amadeusClientId ?? ""
        static let amadeusClientSecret = SecureConfiguration.amadeusClientSecret ?? ""
        
        // RapidAPI Key for Hotels
        // Add RAPIDAPI_KEY to your Xcode scheme environment variables
        static let rapidAPIKey = SecureConfiguration.rapidAPIKey ?? ""
        
        // HasData API Key for Airbnb
        // Add HASDATA_API_KEY to your Xcode scheme environment variables
        static let hasDataAPIKey = SecureConfiguration.hasDataAPIKey ?? ""
    }
    
    // Amadeus OAuth Token Management
    private var amadeusAccessToken: String?
    private var amadeusTokenExpiry: Date?
    
    func getAmadeusToken() async throws -> String {
        print("🔄 Getting Amadeus token...")
        
        // Check if we have a valid token
        if let token = amadeusAccessToken,
           let expiry = amadeusTokenExpiry,
           expiry > Date() {
            print("✅ Using cached token (expires: \(expiry))")
            return token
        }
        
        print("🔄 Token expired or missing, requesting new token...")
        
        // Request new token
        let tokenData = try await requestAmadeusToken()
        self.amadeusAccessToken = tokenData.accessToken
        self.amadeusTokenExpiry = Date().addingTimeInterval(TimeInterval(tokenData.expiresIn - 60))
        
        print("✅ New token received, expires in \(tokenData.expiresIn) seconds")
        print("🔑 New token: \(tokenData.accessToken.prefix(20))...")
        
        return tokenData.accessToken
    }
    
    private func requestAmadeusToken() async throws -> AmadeusToken {
        print("🔐 Requesting new Amadeus token...")
        print("🔗 Auth URL: \(baseURLs.amadeusAuth)")
        print("👤 Client ID: \(APIKeys.amadeusClientId)")
        
        let endpoint = Endpoint(
            baseURL: baseURLs.amadeusAuth,
            path: "",
            method: .POST,
            headers: ["Content-Type": "application/x-www-form-urlencoded"],
            body: "grant_type=client_credentials&client_id=\(APIKeys.amadeusClientId)&client_secret=\(APIKeys.amadeusClientSecret)".data(using: .utf8)
        )
        
        do {
            let tokenResponse = try await NetworkManager.shared.request(endpoint, type: AmadeusToken.self)
            print("✅ Token request successful")
            return tokenResponse
        } catch {
            print("❌ Token request failed: \(error)")
            throw error
        }
    }
}

// Amadeus Token Response
struct AmadeusToken: Codable {
    let type: String
    let username: String
    let applicationName: String
    let clientId: String
    let tokenType: String
    let accessToken: String
    let expiresIn: Int
    let state: String
    let scope: String
    
    private enum CodingKeys: String, CodingKey {
        case type, username, state, scope
        case applicationName = "application_name"
        case clientId = "client_id"
        case tokenType = "token_type"
        case accessToken = "access_token"
        case expiresIn = "expires_in"
    }
}

// Rate Limiting Helper
final class RateLimiter {
    private var lastRequestTimes: [String: Date] = [:]
    private let queue = DispatchQueue(label: "rate.limiter")
    
    func shouldAllowRequest(for service: String, minimumInterval: TimeInterval) -> Bool {
        queue.sync {
            let now = Date()
            if let lastTime = lastRequestTimes[service] {
                let timeSinceLastRequest = now.timeIntervalSince(lastTime)
                if timeSinceLastRequest < minimumInterval {
                    return false
                }
            }
            lastRequestTimes[service] = now
            return true
        }
    }
}
