//
//  LocalTripRepository.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

/// MVVM+R: Repository-Implementation (R-Layer)
/// Lokale In-Memory Implementierung des TripRepository Protocols
/// Später Austausch gegen SwiftData-Implementation
final class LocalTripRepository: TripRepository {
    
    // MARK: - Properties
    
    private var storage: [Trip]

    // MARK: - Initialization
    
    init(seed: [Trip] = []) {
        self.storage = seed
    }

    // MARK: - TripRepository Implementation
    
    func fetchTrips() async throws -> [Trip] {
        // Simuliere kurzen Network-Delay für realistisches Verhalten
        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 Sekunden
        return storage
    }

    func add(_ trip: Trip) async throws {
        // Simuliere Network-Delay
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 Sekunden
        
        // Füge am Anfang hinzu (neueste zuerst)
        storage.insert(trip, at: 0)
    }

    func delete(ids: [UUID]) async throws {
        // Simuliere Network-Delay
        try await Task.sleep(nanoseconds: 200_000_000) // 0.2 Sekunden
        
        // Entferne alle Trips mit den angegebenen IDs
        storage.removeAll { ids.contains($0.id) }
    }
}
