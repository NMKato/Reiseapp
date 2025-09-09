//
//  LoginModels.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import Foundation

// MARK: - Login Credentials

/// Login-Daten für Authentifizierung
struct LoginCredentials {
    var email: String
    var password: String
    
    init(email: String = "", password: String = "") {
        self.email = email
        self.password = password
    }
    
    /// Prüft ob beide Felder ausgefüllt sind
    var isValid: Bool {
        !email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !password.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Prüft auf gültige E-Mail Format
    var hasValidEmail: Bool {
        email.trimmingCharacters(in: .whitespacesAndNewlines).isValidEmail
    }
}

// MARK: - Login Errors

/// Fehlertypen für Login-Prozess
enum LoginError: LocalizedError {
    case invalidEmail
    case invalidCredentials
    case networkError
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Bitte tragen Sie eine gültige E-Mail ein."
        case .invalidCredentials:
            return "Login fehlgeschlagen. Bitte überprüfen Sie die E-Mail oder das Passwort."
        case .networkError:
            return "Netzwerkfehler. Bitte versuchen Sie es später erneut."
        case .unknownError:
            return "Ein unbekannter Fehler ist aufgetreten."
        }
    }
}

// MARK: - String Extension für E-Mail Validation

extension String {
    /// Prüft ob String eine gültige E-Mail Adresse ist
    var isValidEmail: Bool {
        let emailRegex = "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}
