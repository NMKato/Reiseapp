//
//  MockTripRepository.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

final class MockTripRepository: TripRepository {
    var items: [Trip] = [
        Trip(title: "UI Preview", destination: "📍 Anywhere")
    ]

    func fetchTrips() async throws -> [Trip] { items }
    func add(_ trip: Trip) async throws { items.insert(trip, at: 0) }
    func delete(ids: [UUID]) async throws { items.removeAll { ids.contains($0.id) } }
}
