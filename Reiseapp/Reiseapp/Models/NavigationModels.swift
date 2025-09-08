//
//  NavigationModels.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import Foundation

// MARK: - Tab Navigation

/// Haupttabs der App
enum AppTab: String, CaseIterable, Identifiable {
    case trips = "trips"
    case favorites = "favorites"
    case profile = "profile"
    
    var id: String { rawValue }
    
    /// Tab-Titel für UI
    var title: String {
        switch self {
        case .trips:
            return "Reisen"
        case .favorites:
            return "Favoriten"
        case .profile:
            return "Profil"
        }
    }
    
    /// System-Icon Name für Tab
    var systemImage: String {
        switch self {
        case .trips:
            return "suitcase"
        case .favorites:
            return "heart"
        case .profile:
            return "person.circle"
        }
    }
    
    /// Gefülltes System-Icon für aktiven Tab
    var systemImageFilled: String {
        switch self {
        case .trips:
            return "suitcase.fill"
        case .favorites:
            return "heart.fill"
        case .profile:
            return "person.circle.fill"
        }
    }
}

// MARK: - Navigation Path

/// Navigation Destinations innerhalb der App
enum NavigationDestination: Hashable {
    case tripDetail(Trip)
    case tripEdit(Trip)
    case addTrip
    case dayPlanDetail(DayPlan)
    case activityEdit(Activity)
    
    /// Eindeutige ID für Navigation
    var id: String {
        switch self {
        case .tripDetail(let trip):
            return "tripDetail_\(trip.id)"
        case .tripEdit(let trip):
            return "tripEdit_\(trip.id)"
        case .addTrip:
            return "addTrip"
        case .dayPlanDetail(let dayPlan):
            return "dayPlanDetail_\(dayPlan.id)"
        case .activityEdit(let activity):
            return "activityEdit_\(activity.id)"
        }
    }
}
