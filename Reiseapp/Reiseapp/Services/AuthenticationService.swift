//
//  AuthenticationService.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import Foundation

// MARK: - Authentication Service Protocol

/// Service für Benutzer-Authentifizierung
protocol AuthenticationService {
    /// Aktuell eingeloggter Benutzer
    var currentUser: User? { get async }
    
    /// Login mit E-Mail und Passwort
    func login(email: String, password: String) async throws -> User
    
    /// Benutzer ausloggen
    func logout() async throws
    
    /// Prüft ob Benutzer eingeloggt ist
    func isLoggedIn() async -> Bool
}

// MARK: - Local Authentication Service

/// Lokale Implementierung für Demo/Development
final class LocalAuthenticationService: AuthenticationService {
    
    // Demo-Benutzer für Testing
    private let demoUsers: [String: String] = [
        "demo@reiseapp.de": "123456",
        "test@example.com": "password",
        "user@travel.com": "travel123"
    ]
    
    // Aktueller Benutzer im Memory
    private var _currentUser: User?
    
    init() {
        // Simuliere persistenten Login-Status
        // In echter App: UserDefaults oder Keychain prüfen
    }
    
    var currentUser: User? {
        get async {
            return _currentUser
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        // Simuliere Netzwerk-Delay
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1 Sekunde
        
        // Trimme Eingaben
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Validiere E-Mail Format
        guard trimmedEmail.isValidEmail else {
            throw LoginError.invalidEmail
        }
        
        // Prüfe Credentials gegen Demo-Daten
        guard let storedPassword = demoUsers[trimmedEmail],
              storedPassword == trimmedPassword else {
            throw LoginError.invalidCredentials
        }
        
        // Erstelle User-Objekt
        let user = User(
            email: trimmedEmail,
            firstName: "Demo",
            lastName: "User",
            isLoggedIn: true
        )
        
        _currentUser = user
        
        // In echter App: Token in Keychain speichern
        // KeychainHelper.save(token: "demo_token")
        
        return user
    }
    
    func logout() async throws {
        // Simuliere Netzwerk-Delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 Sekunden
        
        _currentUser = nil
        
        // In echter App: Token aus Keychain entfernen
        // KeychainHelper.delete(key: "auth_token")
    }
    
    func isLoggedIn() async -> Bool {
        return _currentUser != nil
    }
}

// MARK: - Mock Authentication Service

/// Mock für Previews und Tests
final class MockAuthenticationService: AuthenticationService {
    var shouldSucceed: Bool = true
    var mockUser: User?
    
    init(shouldSucceed: Bool = true) {
        self.shouldSucceed = shouldSucceed
        self.mockUser = User(
            email: "preview@example.com",
            firstName: "Preview",
            lastName: "User",
            isLoggedIn: shouldSucceed
        )
    }
    
    var currentUser: User? {
        get async {
            return shouldSucceed ? mockUser : nil
        }
    }
    
    func login(email: String, password: String) async throws -> User {
        guard shouldSucceed else {
            throw LoginError.invalidCredentials
        }
        
        guard email.isValidEmail else {
            throw LoginError.invalidEmail
        }
        
        let user = User(email: email, isLoggedIn: true)
        mockUser = user
        return user
    }
    
    func logout() async throws {
        mockUser = nil
    }
    
    func isLoggedIn() async -> Bool {
        return mockUser?.isLoggedIn ?? false
    }
}
