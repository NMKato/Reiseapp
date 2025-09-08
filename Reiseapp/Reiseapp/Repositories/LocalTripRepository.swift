//
//  LocalTripRepository.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

/// „Local“ – später durch SwiftData/CoreData ersetzen.
final class LocalTripRepository: TripRepository {
    private var storage: [Trip]

    init(seed: [Trip] = []) {
        self.storage = seed
    }

    func fetchTrips() async throws -> [Trip] {
        storage
    }

    func add(_ trip: Trip) async throws {
        storage.insert(trip, at: 0)
    }

    func delete(ids: [UUID]) async throws {
        storage.removeAll { ids.contains($0.id) }
    }
}
