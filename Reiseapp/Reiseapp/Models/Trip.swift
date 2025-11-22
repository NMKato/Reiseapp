//
//  Trip.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

// MARK: - Trip Model

/// Hauptmodel für eine Reise - MVVM+R konform
struct Trip: Identifiable, Hashable, Codable {
    let id: UUID
    var title: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var imageName: String?
    var days: [DayPlan]
    
    // New properties for API integration
    var numberOfAdults: Int
    var numberOfChildren: Int
    var budget: Double?
    var currency: String
    var hotelBookings: [HotelBooking]
    var flightBookings: [FlightBooking]
    var weatherForecast: WeatherForecast?
    var destinationCoordinates: Coordinates?

    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        imageName: String? = nil,
        days: [DayPlan] = [],
        numberOfAdults: Int = 1,
        numberOfChildren: Int = 0,
        budget: Double? = nil,
        currency: String = "EUR",
        hotelBookings: [HotelBooking] = [],
        flightBookings: [FlightBooking] = [],
        weatherForecast: WeatherForecast? = nil,
        destinationCoordinates: Coordinates? = nil
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.imageName = imageName
        self.days = days
        self.numberOfAdults = numberOfAdults
        self.numberOfChildren = numberOfChildren
        self.budget = budget
        self.currency = currency
        self.hotelBookings = hotelBookings
        self.flightBookings = flightBookings
        self.weatherForecast = weatherForecast
        self.destinationCoordinates = destinationCoordinates
    }
    
    // MARK: - Computed Properties für View-Layer
    
    /// Anzahl der geplanten Tage
    var dayCount: Int {
        days.count
    }
    
    /// Reisedauer in Tagen (basierend auf Start-/Enddatum)
    var duration: Int? {
        guard let startDate = startDate, let endDate = endDate else { return nil }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return components.day
    }
    
    /// Formatiertes Datum für UI
    var dateRangeText: String {
        guard let startDate = startDate else { return "Datum nicht festgelegt" }
        
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        if let endDate = endDate {
            return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
        } else {
            return "Ab \(formatter.string(from: startDate))"
        }
    }
    
    /// Placeholder für Bild (für Repository/View Trennung)
    var displayImageName: String {
        imageName ?? "photo.on.rectangle"
    }
    
    /// Hat die Reise geplante Aktivitäten
    var hasActivities: Bool {
        days.contains { !$0.activities.isEmpty }
    }
    
    /// Gesamtanzahl der Aktivitäten
    var totalActivities: Int {
        days.reduce(0) { $0 + $1.activities.count }
    }
    
    /// Gesamtanzahl der Reisenden
    var totalTravelers: Int {
        numberOfAdults + numberOfChildren
    }
    
    /// Formatiertes Budget
    var formattedBudget: String? {
        guard let budget = budget else { return nil }
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: budget))
    }
}

// MARK: - Repository Helper Extensions

extension Trip {
    
    /// Erstellt Demo-Trip für Repository Testing
    static func demo(title: String, destination: String) -> Trip {
        Trip(
            title: title,
            destination: destination,
            startDate: Date().addingTimeInterval(86400 * 7), // In einer Woche
            endDate: Date().addingTimeInterval(86400 * 14),   // In zwei Wochen
            imageName: "photo.on.rectangle"
        )
    }
    
    /// Business Logic für Day-Management (für Repository/ViewModel)
    mutating func addDay(_ dayPlan: DayPlan) {
        days.append(dayPlan)
    }
    
    /// Business Logic für Day-Removal
    mutating func removeDay(at index: Int) {
        guard index < days.count else { return }
        days.remove(at: index)
    }
    
    /// Validation für Repository Layer
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
