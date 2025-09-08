//
//  User.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import Foundation

/// Benutzer-Model für Authentifizierung und Profil-Verwaltung
struct User: Identifiable, Hashable, Codable {
    let id: UUID
    var email: String
    var firstName: String?
    var lastName: String?
    var profileImageName: String?
    var isLoggedIn: Bool
    
    init(
        id: UUID = UUID(),
        email: String,
        firstName: String? = nil,
        lastName: String? = nil,
        profileImageName: String? = nil,
        isLoggedIn: Bool = false
    ) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.profileImageName = profileImageName
        self.isLoggedIn = isLoggedIn
    }
    
    /// Vollständiger Name falls vorhanden
    var fullName: String? {
        guard let firstName = firstName, let lastName = lastName else { return nil }
        return "\(firstName) \(lastName)"
    }
    
    /// Display Name für UI (vollständiger Name oder E-Mail)
    var displayName: String {
        return fullName ?? email
    }
}
