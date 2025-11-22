//
//  AppConfiguration.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import Foundation
import SwiftUI

// MARK: - App Configuration

struct AppConfiguration {
    
    // MARK: - Travel Destinations
    
    struct Destinations {
        static let allDestinations = [
            "Barcelona", "Paris", "Rom", "Amsterdam", "Wien", 
            "Berlin", "Madrid", "London", "Milano", "Prag", 
            "Budapest", "Istanbul", "München", "Hamburg", 
            "Köln", "Frankfurt", "Dresden", "Leipzig"
        ]
        
        static let popularDestinations = [
            "Berlin", "München", "Barcelona", "Paris", 
            "London", "Amsterdam", "Rom", "Wien"
        ]
        
        static let europeanDestinations = [
            "Barcelona", "Paris", "Rom", "Amsterdam", "Wien",
            "Berlin", "Madrid", "London", "Milano", "Prag",
            "Budapest", "Istanbul"
        ]
        
        static let germanCities = [
            "Berlin", "München", "Hamburg", "Köln", 
            "Frankfurt", "Stuttgart", "Düsseldorf", 
            "Dresden", "Leipzig", "Hannover"
        ]
    }
    
    // MARK: - City Weather Data
    
    struct WeatherData {
        static let cityWeatherData = [
            CityWeather(city: "Berlin", temp: "24°", condition: "☀️", landmark: "Brandenburger Tor", gradient: [.blue, .cyan]),
            CityWeather(city: "München", temp: "22°", condition: "⛅", landmark: "Marienplatz", gradient: [.orange, .red]),
            CityWeather(city: "Barcelona", temp: "28°", condition: "☀️", landmark: "Sagrada Familia", gradient: [.purple, .pink]),
            CityWeather(city: "Paris", temp: "25°", condition: "🌤️", landmark: "Eiffelturm", gradient: [.green, .mint]),
            CityWeather(city: "London", temp: "19°", condition: "🌦️", landmark: "Big Ben", gradient: [.indigo, .blue]),
            CityWeather(city: "Amsterdam", temp: "21°", condition: "⛅", landmark: "Grachten", gradient: [.orange, .yellow])
        ]
    }
    
    // MARK: - City Landmarks
    
    // MARK: - Remove duplicated structs - use ones from ExploreView.swift instead
    
    // MARK: - Planning Features
    
    struct PlanningFeatures {
        static let features = [
            PlanningFeature(
                title: "Budget planen",
                subtitle: "Erstelle ein detailliertes Budget für deine Reise",
                icon: "creditcard",
                color: .green
            ),
            PlanningFeature(
                title: "Reiseplan",
                subtitle: "Plane deine Aktivitäten Tag für Tag",
                icon: "calendar",
                color: .blue
            ),
            PlanningFeature(
                title: "Packliste",
                subtitle: "Vergiss nichts Wichtiges mit unserer Packliste",
                icon: "bag",
                color: .orange
            ),
            PlanningFeature(
                title: "Dokumente",
                subtitle: "Verwalte alle wichtigen Reisedokumente",
                icon: "doc.text",
                color: .purple
            )
        ]
    }
    
    // MARK: - Travel Essentials
    
    struct TravelEssentials {
        static let essentials = [
            TravelEssential(
                icon: "person.text.rectangle",
                title: "Reisepass",
                description: "Prüfe Gültigkeit",
                color: .blue
            ),
            TravelEssential(
                icon: "shield.checkered",
                title: "Versicherung",
                description: "Reiseversicherung abschließen",
                color: .green
            ),
            TravelEssential(
                icon: "creditcard.trianglebadge.exclamationmark",
                title: "Währung",
                description: "Geld wechseln",
                color: .orange
            ),
            TravelEssential(
                icon: "bag.badge.plus",
                title: "Packen",
                description: "Koffer packen",
                color: .purple
            )
        ]
    }
    
    // MARK: - Travel Tips
    
    struct TravelTips {
        static let tips = [
            TravelTip(
                icon: "calendar.badge.exclamationmark",
                title: "Früh buchen spart Geld",
                description: "Buche Flüge und Hotels mindestens 6-8 Wochen im Voraus für die besten Preise.",
                color: .green
            ),
            TravelTip(
                icon: "antenna.radiowaves.left.and.right",
                title: "Lokale SIM-Karte",
                description: "Kaufe eine lokale SIM-Karte am Flughafen für günstigeres Internet.",
                color: .orange
            ),
            TravelTip(
                icon: "map",
                title: "Offline-Karten",
                description: "Lade Karten offline herunter, um auch ohne Internet navigieren zu können.",
                color: .blue
            ),
            TravelTip(
                icon: "exclamationmark.shield",
                title: "Notfall-Kontakte",
                description: "Speichere wichtige Notfall-Kontakte und Botschaftsinformationen.",
                color: .red
            )
        ]
    }
    
    // MARK: - Popular Flight Routes
    
    struct FlightRoutes {
        static let popularRoutes = [
            ("BER", "BCN", "€89", "Berlin → Barcelona"),
            ("MUC", "CDG", "€120", "München → Paris"),
            ("HAM", "LHR", "€95", "Hamburg → London"),
            ("FRA", "FCO", "€110", "Frankfurt → Rom"),
            ("DUS", "AMS", "€75", "Düsseldorf → Amsterdam"),
            ("STR", "VIE", "€85", "Stuttgart → Wien")
        ]
    }
    
    // MARK: - Default Search Parameters
    
    struct DefaultSearchParameters {
        static let defaultGuests = 2
        static let defaultRooms = 1
        static let defaultPriceRange: ClosedRange<Double> = 0...500
        static let defaultDaysInAdvance = 7
        static let defaultTripDuration = 3
        static let maxSearchResults = 20
        static let maxPopularHotels = 18
    }
    
    // MARK: - UI Configuration
    
    struct UIConfig {
        static let gridCardWidth: CGFloat = 160
        static let gridCardHeight: CGFloat = 220
        static let imageHeight: CGFloat = 120
        static let contentHeight: CGFloat = 80
        static let gridSpacing: CGFloat = 24
        static let columnSpacing: CGFloat = 16
        static let cornerRadius: CGFloat = 12
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.1
    }
    
    // MARK: - Cache Configuration
    
    struct CacheConfig {
        static let popularHotelsExpiration: TimeInterval = 3600 // 1 hour
        static let searchResultsExpiration: TimeInterval = 1800 // 30 minutes
        static let weatherDataExpiration: TimeInterval = 1800 // 30 minutes
        static let maxCacheSize = 50 // Maximum number of cached items
    }
}

// MARK: - Data Models removed to avoid conflicts with ExploreView.swift
// Use the structs already defined in ExploreView.swift instead

// MARK: - Color Extensions for Serialization

extension Color {
    func toString() -> String {
        switch self {
        case .red: return "red"
        case .green: return "green"
        case .blue: return "blue"
        case .orange: return "orange"
        case .yellow: return "yellow"
        case .pink: return "pink"
        case .purple: return "purple"
        case .mint: return "mint"
        case .cyan: return "cyan"
        case .indigo: return "indigo"
        default: return "blue"
        }
    }
    
    static func fromString(_ string: String) -> Color? {
        switch string.lowercased() {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "mint": return .mint
        case "cyan": return .cyan
        case "indigo": return .indigo
        default: return nil
        }
    }
}