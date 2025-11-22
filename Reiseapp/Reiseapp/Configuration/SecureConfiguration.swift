//
//  SecureConfiguration.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  Secure configuration management for API keys and sensitive data

import Foundation

struct SecureConfiguration {
    
    // MARK: - API Keys (Secure Access)
    
    /// OpenAI API Key - retrieved from environment variables only
    /// Never hardcode API keys in source code!
    static var openAIAPIKey: String? {
        return getEnvironmentVariable("OPENAI_API_KEY")
    }
    
    /// OpenWeatherMap API Key - Add OPENWEATHER_API_KEY to your Xcode scheme environment variables
    static var openWeatherAPIKey: String? {
        return getEnvironmentVariable("OPENWEATHER_API_KEY")
    }
    
    /// Amadeus Client ID - Add AMADEUS_CLIENT_ID to your Xcode scheme environment variables
    static var amadeusClientId: String? {
        return getEnvironmentVariable("AMADEUS_CLIENT_ID")
    }
    
    /// Amadeus Client Secret - Add AMADEUS_CLIENT_SECRET to your Xcode scheme environment variables
    static var amadeusClientSecret: String? {
        return getEnvironmentVariable("AMADEUS_CLIENT_SECRET")
    }
    
    /// RapidAPI Key - Add RAPIDAPI_KEY to your Xcode scheme environment variables
    static var rapidAPIKey: String? {
        return getEnvironmentVariable("RAPIDAPI_KEY")
    }
    
    /// HasData API Key - Add HASDATA_API_KEY to your Xcode scheme environment variables
    static var hasDataAPIKey: String? {
        return getEnvironmentVariable("HASDATA_API_KEY")
    }
    
    // MARK: - Helper Method
    
    /// Generic environment variable getter with .env file support
    private static func getEnvironmentVariable(_ key: String) -> String? {
        // Load .env file if it exists (for local development)
        loadEnvironmentFile()
        
        // Check environment variables in order of preference:
        // 1. Environment variable (from .env file or system environment)
        // 2. Process environment (for Xcode schemes)
        return ProcessInfo.processInfo.environment[key]
    }
    
    /// Load environment variables from .env file
    private static func loadEnvironmentFile() {
        guard let path = Bundle.main.path(forResource: ".env", ofType: nil) ??
              Bundle.main.path(forResource: ".env", ofType: "")
        else { return }
        
        do {
            let content = try String(contentsOfFile: path, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            for line in lines {
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                if !trimmed.isEmpty && !trimmed.hasPrefix("#") {
                    let parts = trimmed.components(separatedBy: "=")
                    if parts.count >= 2 {
                        let key = parts[0].trimmingCharacters(in: .whitespaces)
                        let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
                        setenv(key, value, 0) // Don't override if already set
                    }
                }
            }
        } catch {
            // Silently fail if .env file can't be read
        }
    }
    
    
    // MARK: - Configuration Validation
    
    /// Validates if required API keys are configured
    static func validateConfiguration() -> [String] {
        var missingKeys: [String] = []
        
        if openAIAPIKey?.isEmpty != false {
            missingKeys.append("OPENAI_API_KEY")
        }
        if openWeatherAPIKey?.isEmpty != false {
            missingKeys.append("OPENWEATHER_API_KEY")
        }
        if amadeusClientId?.isEmpty != false {
            missingKeys.append("AMADEUS_CLIENT_ID")
        }
        if amadeusClientSecret?.isEmpty != false {
            missingKeys.append("AMADEUS_CLIENT_SECRET")
        }
        if rapidAPIKey?.isEmpty != false {
            missingKeys.append("RAPIDAPI_KEY")
        }
        if hasDataAPIKey?.isEmpty != false {
            missingKeys.append("HASDATA_API_KEY")
        }
        
        return missingKeys
    }
    
    /// Prints configuration status to console (for debugging)
    static func printConfigurationStatus() {
        let missing = validateConfiguration()
        
        if missing.isEmpty {
            print("✅ All API keys are configured securely")
        } else {
            print("⚠️ Missing API keys: \(missing.joined(separator: ", "))")
            print("💡 Configure them in Xcode Scheme → Environment Variables")
        }
    }
    
    // MARK: - Security Helpers
    
    /// Checks if we're running in a secure environment
    static var isSecureEnvironment: Bool {
        // Consider environment secure if no hardcoded keys are detected
        // This is a basic check - in production you might want more sophisticated validation
        return !ProcessInfo.processInfo.environment.values.contains { $0.hasPrefix("sk-") && $0.count > 20 }
    }
    
    /// Returns masked version of API key for logging (security)
    static func maskAPIKey(_ key: String?) -> String {
        guard let key = key, !key.isEmpty else { return "❌ Not configured" }
        let visibleChars = min(8, key.count)
        let hiddenCount = max(0, key.count - visibleChars)
        return "\(key.prefix(visibleChars))" + String(repeating: "*", count: hiddenCount)
    }
}

// MARK: - Development Helpers

#if DEBUG
extension SecureConfiguration {
    /// Debug information about configuration (only in debug builds)
    static func debugConfiguration() {
        print("🔧 DEBUG: API Configuration Status")
        print("   OpenAI Key: \(maskAPIKey(openAIAPIKey))")
        print("   OpenWeather Key: \(maskAPIKey(openWeatherAPIKey))")
        print("   Amadeus ID: \(maskAPIKey(amadeusClientId))")
        print("   RapidAPI Key: \(maskAPIKey(rapidAPIKey))")
        print("   HasData Key: \(maskAPIKey(hasDataAPIKey))")
        print("   Secure Environment: \(isSecureEnvironment ? "✅" : "⚠️")")
    }
}
#endif