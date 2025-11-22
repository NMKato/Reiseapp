//
//  AppInfo.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  App configuration and privacy permissions

import Foundation

struct AppInfo {
    
    // Privacy Usage Descriptions for Info.plist
    static let privacyDescriptions: [String: String] = [
        "NSMicrophoneUsageDescription": "Diese App benötigt Zugriff auf das Mikrofon, um Ihre Spracheingaben für die KI-Assistenten-Funktion aufzunehmen. Ihre Sprachdaten werden nur zur Verarbeitung von Reisesuchen verwendet.",
        "NSSpeechRecognitionUsageDescription": "Diese App nutzt Spracherkennung, um Ihnen zu ermöglichen, Hotels und Flüge per Spracheingabe zu suchen. Ihre Spracheingabe wird nur zur Verarbeitung Ihrer Reiseanfragen verwendet."
    ]
    
    // App display information
    static let displayName = "Reiseapp"
    static let version = "1.0.0"
    static let build = "1"
    
    // Feature flags
    static let isVoiceAssistantEnabled = true
    static let isDebugModeEnabled = ProcessInfo.processInfo.environment["DEBUG"] == "1"
    
    // Check if required permissions are configured
    static func validatePrivacyPermissions() -> Bool {
        // In a real app, you might check Bundle.main.infoDictionary
        // For now, return true as we expect the user to configure them
        return true
    }
    
    // Get privacy description for a specific permission
    static func privacyDescription(for key: String) -> String? {
        return privacyDescriptions[key]
    }
    
    // Print app configuration info
    static func printAppInfo() {
        print("📱 App: \(displayName) v\(version) (\(build))")
        print("🎙️ Voice Assistant: \(isVoiceAssistantEnabled ? "Enabled" : "Disabled")")
        print("🔧 Debug Mode: \(isDebugModeEnabled ? "Enabled" : "Disabled")")
        
        if isDebugModeEnabled {
            print("🔐 Privacy Descriptions configured: \(privacyDescriptions.count) keys")
        }
    }
}