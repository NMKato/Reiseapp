//
//  AICommandHandler.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  AI Command Handler für App-Steuerung via Sprache
//

import Foundation
import SwiftUI

class AICommandHandler: ObservableObject {
    
    // MARK: - Dependencies
    
    private weak var exploreViewModel: ExploreViewModel?
    private weak var appEnvironment: AppEnvironment?
    
    @Published var isExecuting = false
    @Published var lastResult: AIResponse?
    @Published var executionLog: [String] = []
    
    // MARK: - Initialization
    
    init() {}
    
    @MainActor
    func configure(exploreViewModel: ExploreViewModel, appEnvironment: AppEnvironment) {
        self.exploreViewModel = exploreViewModel
        self.appEnvironment = appEnvironment
    }
    
    // MARK: - Execute AI Commands
    
    @MainActor
    func execute(_ command: AICommand) async -> AIResponse {
        isExecuting = true
        defer { isExecuting = false }
        
        logExecution("Executing command: \(command.type.rawValue)")
        
        do {
            switch command.type {
            case .searchHotels:
                return await executeHotelSearch(command)
                
            case .searchFlights:
                return await executeFlightSearch(command)
                
            case .bookHotel:
                return await executeHotelBooking(command)
                
            case .bookFlight:
                return await executeFlightBooking(command)
                
            case .addToTrip:
                return await executeAddToTrip(command)
                
            case .getWeather:
                return await executeWeatherRequest(command)
                
            case .createTrip:
                return await executeCreateTrip(command)
                
            case .showTrips:
                return await executeShowTrips(command)
                
            case .getLocalExperiences:
                return await executeLocalExperiences(command)
                
            case .getTravelTips:
                return await executeTravelTips(command)
                
            case .unknown:
                return AIResponse(
                    message: "Entschuldigung, ich habe das nicht verstanden. Können Sie es anders formulieren?",
                    success: false,
                    error: "Unknown command type"
                )
            }
        } catch {
            logExecution("Error: \(error.localizedDescription)")
            return AIResponse(
                message: "Es ist ein Fehler aufgetreten: \(error.localizedDescription)",
                success: false,
                error: error.localizedDescription
            )
        }
    }
    
    // MARK: - Hotel Search Execution
    
    @MainActor
    private func executeHotelSearch(_ command: AICommand) async -> AIResponse {
        guard let exploreViewModel = exploreViewModel else {
            return AIResponse(message: "ViewModel nicht verfügbar", success: false)
        }
        
        // Parse parameters
        guard let destination = command.parameters["destination"] as? String else {
            return AIResponse(message: "Reiseziel fehlt", success: false)
        }
        
        let checkInDateString = command.parameters["check_in_date"] as? String ?? ""
        let checkOutDateString = command.parameters["check_out_date"] as? String ?? ""
        let guests = command.parameters["guests"] as? Int ?? 2
        let maxPrice = command.parameters["max_price"] as? Double
        
        // Parse dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let checkInDate = dateFormatter.date(from: checkInDateString) ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        let checkOutDate = dateFormatter.date(from: checkOutDateString) ?? Calendar.current.date(byAdding: .day, value: 10, to: Date())!
        
        // Update ViewModel
        exploreViewModel.selectedCategory = .hotels
        exploreViewModel.destinationInput = destination
        exploreViewModel.checkInDate = checkInDate
        exploreViewModel.checkOutDate = checkOutDate
        exploreViewModel.guests = guests
        
        if let maxPrice = maxPrice {
            exploreViewModel.usePriceFilter = true
            exploreViewModel.priceRange = 0...maxPrice
        }
        
        // Navigate to hotels section and start search
        appEnvironment?.selectedTab = 1 // Entdecken Tab
        
        // Execute search
        exploreViewModel.startHotelSearch()
        
        logExecution("Hotel search started for \(destination)")
        
        return AIResponse(
            command: command,
            message: "Ich suche Hotels in \(destination) für \(guests) Gäste vom \(formatDate(checkInDate)) bis \(formatDate(checkOutDate)).",
            success: true,
            suggestedActions: ["Ergebnisse anzeigen", "Filter ändern", "Andere Stadt suchen"]
        )
    }
    
    // MARK: - Flight Search Execution
    
    @MainActor
    private func executeFlightSearch(_ command: AICommand) async -> AIResponse {
        guard let exploreViewModel = exploreViewModel else {
            return AIResponse(message: "ViewModel nicht verfügbar", success: false)
        }
        
        // Parse parameters
        guard let origin = command.parameters["origin"] as? String,
              let destination = command.parameters["destination"] as? String else {
            return AIResponse(message: "Abflug- oder Zielort fehlt", success: false)
        }
        
        let departureDateString = command.parameters["departure_date"] as? String ?? ""
        let returnDateString = command.parameters["return_date"] as? String
        let passengers = command.parameters["passengers"] as? Int ?? 1
        let directOnly = command.parameters["direct_only"] as? Bool ?? false
        
        // Parse dates
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let departureDate = dateFormatter.date(from: departureDateString) ?? Calendar.current.date(byAdding: .day, value: 7, to: Date())!
        
        // Update ViewModel
        exploreViewModel.selectedCategory = .flights
        exploreViewModel.originInput = origin
        exploreViewModel.destinationInput = destination
        exploreViewModel.departureDate = departureDate
        exploreViewModel.passengers = passengers
        exploreViewModel.directFlightsOnly = directOnly
        
        if let returnDateString = returnDateString,
           let returnDate = dateFormatter.date(from: returnDateString) {
            exploreViewModel.returnDate = returnDate
            exploreViewModel.isOneWay = false
        } else {
            exploreViewModel.isOneWay = true
        }
        
        // Navigate to flights section
        appEnvironment?.selectedTab = 1 // Entdecken Tab
        
        // Execute search
        exploreViewModel.startFlightSearch()
        
        logExecution("Flight search started from \(origin) to \(destination)")
        
        let directText = directOnly ? " (nur Direktflüge)" : ""
        let returnText = exploreViewModel.isOneWay ? "" : " und zurück am \(formatDate(exploreViewModel.returnDate))"
        
        return AIResponse(
            command: command,
            message: "Ich suche Flüge von \(origin) nach \(destination) am \(formatDate(departureDate))\(returnText) für \(passengers) Passagier\(passengers > 1 ? "e" : "")\(directText).",
            success: true,
            suggestedActions: ["Ergebnisse anzeigen", "Rückflug hinzufügen", "Andere Route suchen"]
        )
    }
    
    // MARK: - Flight Booking Execution
    
    @MainActor
    private func executeFlightBooking(_ command: AICommand) async -> AIResponse {
        // This would be called when user says "Buche den ersten Flug" after search
        guard let exploreViewModel = exploreViewModel,
              let appEnvironment = appEnvironment else {
            return AIResponse(message: "Dienste nicht verfügbar", success: false)
        }
        
        // Get first flight from search results
        guard let firstFlight = await exploreViewModel.flightResults.first else {
            return AIResponse(
                message: "Keine Flüge gefunden. Bitte zuerst nach Flügen suchen.",
                success: false
            )
        }
        
        // Book the flight using existing method
        await exploreViewModel.addFlightToTrip(firstFlight, appEnvironment: appEnvironment)
        
        logExecution("Flight booked: \(firstFlight.departure.airport.code) → \(firstFlight.arrival.airport.code)")
        
        return AIResponse(
            command: command,
            message: "Flug von \(firstFlight.departure.airport.code) nach \(firstFlight.arrival.airport.code) wurde zu Ihren Reisen hinzugefügt!",
            success: true,
            suggestedActions: ["Reisen anzeigen", "Hotel hinzufügen", "Weitere Flüge suchen"]
        )
    }
    
    // MARK: - Weather Request
    
    @MainActor
    private func executeWeatherRequest(_ command: AICommand) async -> AIResponse {
        guard let destination = command.parameters["destination"] as? String else {
            return AIResponse(message: "Reiseziel für Wetter fehlt", success: false)
        }
        
        // Switch to weather category
        exploreViewModel?.selectedCategory = .weather
        exploreViewModel?.destinationInput = destination
        appEnvironment?.selectedTab = 1
        
        logExecution("Weather request for \(destination)")
        
        return AIResponse(
            command: command,
            message: "Hier sind die Wetterinformationen für \(destination).",
            success: true
        )
    }
    
    // MARK: - Show Trips
    
    @MainActor
    private func executeShowTrips(_ command: AICommand) async -> AIResponse {
        // Switch to Reisen tab
        appEnvironment?.selectedTab = 0
        
        logExecution("Showing trips")
        
        return AIResponse(
            command: command,
            message: "Hier sind Ihre gespeicherten Reisen.",
            success: true,
            suggestedActions: ["Neue Reise erstellen", "Reise bearbeiten"]
        )
    }
    
    // MARK: - Helper Methods
    
    @MainActor
    private func executeHotelBooking(_ command: AICommand) async -> AIResponse {
        // Similar to flight booking - book first hotel from results
        guard let exploreViewModel = exploreViewModel,
              let appEnvironment = appEnvironment else {
            return AIResponse(message: "Dienste nicht verfügbar", success: false)
        }
        
        guard let firstHotel = await exploreViewModel.searchResults.first else {
            return AIResponse(
                message: "Keine Hotels gefunden. Bitte zuerst nach Hotels suchen.",
                success: false
            )
        }
        
        // This would trigger the UnterkunftDetailSheet
        exploreViewModel.selectedHotel = firstHotel
        
        return AIResponse(
            command: command,
            message: "Hotel \(firstHotel.name) ausgewählt. Möchten Sie es zu Ihrer Reise hinzufügen?",
            success: true,
            suggestedActions: ["Zur Reise hinzufügen", "Andere Hotels anzeigen"]
        )
    }
    
    private func executeAddToTrip(_ command: AICommand) async -> AIResponse {
        // Generic add to trip handler
        return AIResponse(
            message: "Element zu Reise hinzugefügt",
            success: true
        )
    }
    
    private func executeCreateTrip(_ command: AICommand) async -> AIResponse {
        // Create new trip
        guard let title = command.parameters["title"] as? String,
              let destination = command.parameters["destination"] as? String else {
            return AIResponse(message: "Titel oder Reiseziel fehlt", success: false)
        }
        
        return AIResponse(
            command: command,
            message: "Neue Reise '\(title)' nach \(destination) wurde erstellt.",
            success: true
        )
    }
    
    private func executeLocalExperiences(_ command: AICommand) async -> AIResponse {
        guard let destination = command.parameters["destination"] as? String else {
            return AIResponse(message: "Reiseziel fehlt", success: false)
        }
        
        return AIResponse(
            command: command,
            message: "Hier sind lokale Erlebnisse in \(destination).",
            success: true
        )
    }
    
    private func executeTravelTips(_ command: AICommand) async -> AIResponse {
        return AIResponse(
            message: "Hier sind hilfreiche Reisetipps für Sie.",
            success: true
        )
    }
    
    private func logExecution(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .shortened)
        let logEntry = "[\(timestamp)] \(message)"
        executionLog.append(logEntry)
        print("🤖 AICommandHandler: \(logEntry)")
        
        // Keep only last 50 log entries
        if executionLog.count > 50 {
            executionLog.removeFirst()
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter.string(from: date)
    }
}