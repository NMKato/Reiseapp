//
//  SwiftDataTripRepository.swift
//  Reiseapp
//
//  Created by Claude on 11.09.25.
//

import SwiftUI
import SwiftData
import Foundation

/// MVVM+R: Repository-Implementation (R-Layer)
/// SwiftData-basierte Implementierung des TripRepository Protocols für persistente Datenspeicherung
@MainActor
final class SwiftDataTripRepository: TripRepository {
    
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - TripRepository Implementation
    
    func fetchTrips() async throws -> [Trip] {
        let descriptor = FetchDescriptor<PersistentTrip>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        do {
            let persistentTrips = try modelContext.fetch(descriptor)
            let trips = persistentTrips.map { $0.toTrip() }
            
            print("📱 SwiftData: Loaded \(trips.count) trips from database")
            return trips
        } catch {
            print("❌ SwiftData Error loading trips: \(error)")
            throw TripRepositoryError.loadingFailed(error)
        }
    }
    
    func add(_ trip: Trip) async throws {
        do {
            // Validierung
            guard trip.isValid else {
                throw TripRepositoryError.invalidData("Trip validation failed")
            }
            
            // Konvertiere zu SwiftData Model
            let persistentTrip = trip.toPersistent()
            
            // Füge zum Context hinzu
            modelContext.insert(persistentTrip)
            
            // Speichere in Datenbank
            try modelContext.save()
            
            print("✅ SwiftData: Trip '\(trip.title)' saved to database")
        } catch {
            print("❌ SwiftData Error saving trip: \(error)")
            throw TripRepositoryError.savingFailed(error)
        }
    }
    
    func delete(ids: [UUID]) async throws {
        do {
            // Erstelle Predicate für die zu löschenden IDs
            let predicate = #Predicate<PersistentTrip> { trip in
                ids.contains(trip.id)
            }
            
            // Erstelle FetchDescriptor mit Predicate
            let descriptor = FetchDescriptor<PersistentTrip>(
                predicate: predicate
            )
            
            // Hole die zu löschenden Trips
            let tripsToDelete = try modelContext.fetch(descriptor)
            
            // Lösche jeden Trip aus dem Context
            for trip in tripsToDelete {
                modelContext.delete(trip)
            }
            
            // Speichere Änderungen
            try modelContext.save()
            
            print("✅ SwiftData: Deleted \(tripsToDelete.count) trips from database")
        } catch {
            print("❌ SwiftData Error deleting trips: \(error)")
            throw TripRepositoryError.deletingFailed(error)
        }
    }
    
    // MARK: - Additional SwiftData Methods
    
    /// Lädt einen spezifischen Trip anhand der ID
    func fetchTrip(by id: UUID) async throws -> Trip? {
        let predicate = #Predicate<PersistentTrip> { trip in
            trip.id == id
        }
        
        let descriptor = FetchDescriptor<PersistentTrip>(predicate: predicate)
        
        do {
            let persistentTrips = try modelContext.fetch(descriptor)
            return persistentTrips.first?.toTrip()
        } catch {
            print("❌ SwiftData Error loading trip by ID: \(error)")
            throw TripRepositoryError.loadingFailed(error)
        }
    }
    
    /// Aktualisiert einen existierenden Trip
    func update(_ trip: Trip) async throws {
        do {
            // Validierung
            guard trip.isValid else {
                throw TripRepositoryError.invalidData("Trip validation failed")
            }
            
            // Suche existierenden Trip
            let predicate = #Predicate<PersistentTrip> { persistentTrip in
                persistentTrip.id == trip.id
            }
            
            let descriptor = FetchDescriptor<PersistentTrip>(predicate: predicate)
            let existingTrips = try modelContext.fetch(descriptor)
            
            guard let existingTrip = existingTrips.first else {
                throw TripRepositoryError.notFound("Trip with ID \(trip.id) not found")
            }
            
            // Update die Eigenschaften
            existingTrip.title = trip.title
            existingTrip.destination = trip.destination
            existingTrip.startDate = trip.startDate
            existingTrip.endDate = trip.endDate
            existingTrip.imageName = trip.imageName
            existingTrip.numberOfAdults = trip.numberOfAdults
            existingTrip.numberOfChildren = trip.numberOfChildren
            existingTrip.budget = trip.budget
            existingTrip.currency = trip.currency
            
            // Speichere Änderungen
            try modelContext.save()
            
            print("✅ SwiftData: Trip '\(trip.title)' updated in database")
        } catch {
            print("❌ SwiftData Error updating trip: \(error)")
            throw TripRepositoryError.savingFailed(error)
        }
    }
    
    /// Liefert die Anzahl gespeicherter Trips
    func count() async throws -> Int {
        let descriptor = FetchDescriptor<PersistentTrip>()
        
        do {
            let trips = try modelContext.fetch(descriptor)
            return trips.count
        } catch {
            print("❌ SwiftData Error counting trips: \(error)")
            return 0
        }
    }
    
    /// Löscht alle Trips (für Development/Testing)
    func deleteAll() async throws {
        do {
            let descriptor = FetchDescriptor<PersistentTrip>()
            let allTrips = try modelContext.fetch(descriptor)
            
            for trip in allTrips {
                modelContext.delete(trip)
            }
            
            try modelContext.save()
            
            print("✅ SwiftData: All trips deleted from database")
        } catch {
            print("❌ SwiftData Error deleting all trips: \(error)")
            throw TripRepositoryError.deletingFailed(error)
        }
    }
}

// MARK: - Error Handling

enum TripRepositoryError: LocalizedError {
    case loadingFailed(Error)
    case savingFailed(Error)
    case deletingFailed(Error)
    case invalidData(String)
    case notFound(String)
    
    var errorDescription: String? {
        switch self {
        case .loadingFailed(let error):
            return "Failed to load trips: \(error.localizedDescription)"
        case .savingFailed(let error):
            return "Failed to save trip: \(error.localizedDescription)"
        case .deletingFailed(let error):
            return "Failed to delete trips: \(error.localizedDescription)"
        case .invalidData(let message):
            return "Invalid trip data: \(message)"
        case .notFound(let message):
            return "Trip not found: \(message)"
        }
    }
}