import Foundation

// MARK: - App Error

/// Zentrale Error-Behandlung für die gesamte App
enum AppError: LocalizedError {
    
    // MARK: - Authentication Errors
    case authenticationFailed
    case userNotFound
    case invalidCredentials
    case sessionExpired
    
    // MARK: - Repository Errors
    case repositoryError(String)
    case dataNotFound
    case saveFailed
    case deleteFailed
    case loadFailed
    
    // MARK: - Network Errors
    case networkUnavailable
    case serverError
    case timeout
    case invalidResponse
    
    // MARK: - Validation Errors
    case invalidInput(String)
    case missingRequiredField(String)
    case invalidEmailFormat
    case invalidDateRange
    
    // MARK: - LocalizedError Implementation
    
    var errorDescription: String? {
        switch self {
        // Authentication
        case .authenticationFailed:
            return "Anmeldung fehlgeschlagen"
        case .userNotFound:
            return "Benutzer nicht gefunden"
        case .invalidCredentials:
            return "Login fehlgeschlagen. Bitte überprüfen Sie die E-Mail oder das Passwort."
        case .sessionExpired:
            return "Sitzung abgelaufen. Bitte melden Sie sich erneut an."
            
        // Repository
        case .repositoryError(let message):
            return "Datenfehler: \(message)"
        case .dataNotFound:
            return "Daten nicht gefunden"
        case .saveFailed:
            return "Speichern fehlgeschlagen"
        case .deleteFailed:
            return "Löschen fehlgeschlagen"
        case .loadFailed:
            return "Laden der Daten fehlgeschlagen"
            
        // Network
        case .networkUnavailable:
            return "Keine Internetverbindung"
        case .serverError:
            return "Serverfehler. Bitte versuchen Sie es später erneut."
        case .timeout:
            return "Zeitüberschreitung. Bitte versuchen Sie es erneut."
        case .invalidResponse:
            return "Ungültige Serverantwort"
            
        // Validation
        case .invalidInput(let field):
            return "Ungültige Eingabe: \(field)"
        case .missingRequiredField(let field):
            return "\(field) ist erforderlich"
        case .invalidEmailFormat:
            return "Bitte tragen Sie eine gültige E-Mail ein."
        case .invalidDateRange:
            return "Ungültiger Datumsbereich"
        }
    }
    
    var failureReason: String? {
        switch self {
        case .authenticationFailed:
            return "Die Anmeldedaten sind ungültig oder das Konto ist gesperrt."
        case .networkUnavailable:
            return "Prüfen Sie Ihre Internetverbindung und versuchen Sie es erneut."
        case .serverError:
            return "Der Server ist momentan nicht erreichbar."
        default:
            return nil
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .authenticationFailed, .invalidCredentials:
            return "Überprüfen Sie Ihre E-Mail und Ihr Passwort."
        case .networkUnavailable:
            return "Stellen Sie eine Internetverbindung her und versuchen Sie es erneut."
        case .sessionExpired:
            return "Melden Sie sich erneut an."
        case .serverError, .timeout:
            return "Warten Sie einen Moment und versuchen Sie es erneut."
        default:
            return "Versuchen Sie es erneut oder kontaktieren Sie den Support."
        }
    }
}

// MARK: - Error Extensions

extension AppError {
    
    /// Konvertiert LoginError zu AppError
    static func from(_ loginError: LoginError) -> AppError {
        switch loginError {
        case .invalidEmail:
            return .invalidEmailFormat
        case .invalidCredentials:
            return .invalidCredentials
        case .networkError:
            return .networkUnavailable
        case .unknownError:
            return .authenticationFailed
        }
    }
    
    /// Erstellt Repository-Error mit Kontext
    static func repository(_ message: String) -> AppError {
        return .repositoryError(message)
    }
    
    /// Erstellt Validation-Error mit Field-Name
    static func validation(_ field: String) -> AppError {
        return .missingRequiredField(field)
    }
}

// MARK: - Equatable Implementation

extension AppError: Equatable {
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        // Authentication
        case (.authenticationFailed, .authenticationFailed),
             (.userNotFound, .userNotFound),
             (.invalidCredentials, .invalidCredentials),
             (.sessionExpired, .sessionExpired):
            return true
            
        // Repository
        case (.repositoryError(let lhsMessage), .repositoryError(let rhsMessage)):
            return lhsMessage == rhsMessage
        case (.dataNotFound, .dataNotFound),
             (.saveFailed, .saveFailed),
             (.deleteFailed, .deleteFailed),
             (.loadFailed, .loadFailed):
            return true
            
        // Network
        case (.networkUnavailable, .networkUnavailable),
             (.serverError, .serverError),
             (.timeout, .timeout),
             (.invalidResponse, .invalidResponse):
            return true
            
        // Validation
        case (.invalidInput(let lhsField), .invalidInput(let rhsField)):
            return lhsField == rhsField
        case (.missingRequiredField(let lhsField), .missingRequiredField(let rhsField)):
            return lhsField == rhsField
        case (.invalidEmailFormat, .invalidEmailFormat),
             (.invalidDateRange, .invalidDateRange):
            return true
            
        default:
            return false
        }
    }
}
