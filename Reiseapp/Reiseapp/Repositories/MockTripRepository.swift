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
        Trip(title: "UI Preview",
                     startLocation: "Home",
                     destination: "📍 Anywhere",
                     startDate: Date().addingTimeInterval(86400),
                     ticketPrice: 49.99,
                     persons: ["Alex"])
    ]

    func fetchTrips() async throws -> [Trip] { items }
    func add(_ trip: Trip) async throws { items.insert(trip, at: 0) }
    func delete(ids: [UUID]) async throws { items.removeAll { ids.contains($0.id) } }
}
