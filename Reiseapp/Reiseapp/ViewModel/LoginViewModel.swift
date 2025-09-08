//
//  LoginViewModel.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import Foundation

// MARK: - Login ViewModel

/// ViewModel für Login-Funktionalität
@MainActor
final class LoginViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Login-Daten
    @Published var credentials = LoginCredentials()
    
    /// Passwort Sichtbarkeit
    @Published var isPasswordVisible = false
    
    /// Loading State während Login
    @Published var isLoading = false
    
    /// Fehlermeldung für UI
    @Published var errorMessage: String?
    
    /// Erfolgreicher Login
    @Published var isLoggedIn = false
    
    // MARK: - Private Properties
    
    private let authService: AuthenticationService
    
    // MARK: - Computed Properties
    
    /// Login-Button ist aktiviert wenn Felder ausgefüllt sind
    var isLoginButtonEnabled: Bool {
        credentials.isValid && !isLoading
    }
    
    /// Zeigt Error-State in UI
    var hasError: Bool {
        errorMessage != nil
    }
    
    // MARK: - Initialization
    
    init(authService: AuthenticationService) {
        self.authService = authService
    }
    
    // MARK: - Public Methods
    
    /// Führt Login-Prozess aus
    func login() async {
        // Reset vorherige Fehler
        clearError()
        
        // Validiere E-Mail Format vor Service Call
        guard credentials.hasValidEmail else {
            showError(.invalidEmail)
            return
        }
        
        // Starte Loading State
        isLoading = true
        
        do {
            // Führe Login über Service aus
            let user = try await authService.login(
                email: credentials.email,
                password: credentials.password
            )
            
            // Erfolgreicher Login
            isLoggedIn = true
            
            // Optional: Credentials für Sicherheit clearen
            clearCredentials()
            
        } catch let error as LoginError {
            // Bekannte Login-Fehler
            showError(error)
        } catch {
            // Unbekannte Fehler
            showError(.unknownError)
        }
        
        // Stoppe Loading State
        isLoading = false
    }
    
    /// Togglet Passwort Sichtbarkeit
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }
    
    /// Entfernt aktuelle Fehlermeldung
    func clearError() {
        errorMessage = nil
    }
    
    /// Setzt Login-Daten zurück
    func clearCredentials() {
        credentials = LoginCredentials()
        isPasswordVisible = false
    }
    
    /// Prüft ob Benutzer bereits eingeloggt ist
    func checkAuthenticationStatus() async {
        isLoggedIn = await authService.isLoggedIn()
    }
    
    // MARK: - Private Methods
    
    /// Zeigt Fehlermeldung in UI
    private func showError(_ error: LoginError) {
        errorMessage = error.errorDescription
        
        // Auto-Hide Error nach 5 Sekunden
        Task {
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            await MainActor.run {
                if errorMessage == error.errorDescription {
                    clearError()
                }
            }
        }
    }
}
