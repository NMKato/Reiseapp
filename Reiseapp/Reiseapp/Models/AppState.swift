//
//  AppState.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import Foundation

// MARK: - App State

/// Zentraler App-Zustand für Navigation und Session Management
enum AppState: Equatable {
    case loading
    case unauthenticated
    case authenticated(User)
    
    // MARK: - Computed Properties
    
    /// Benutzer ist eingeloggt
    var isAuthenticated: Bool {
        switch self {
        case .authenticated:
            return true
        case .loading, .unauthenticated:
            return false
        }
    }
    
    /// Aktueller Benutzer falls eingeloggt
    var currentUser: User? {
        switch self {
        case .authenticated(let user):
            return user
        case .loading, .unauthenticated:
            return nil
        }
    }
    
    /// App ist im Loading-Zustand
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .unauthenticated, .authenticated:
            return false
        }
    }
}

// MARK: - Network State

/// Netzwerk-Status für Repository-Layer
enum NetworkState: Equatable {
    case idle
    case loading
    case success
    case error(String)
    
    var isLoading: Bool {
        switch self {
        case .loading:
            return true
        case .idle, .success, .error:
            return false
        }
    }
    
    var errorMessage: String? {
        switch self {
        case .error(let message):
            return message
        case .idle, .loading, .success:
            return nil
        }
    }
}
