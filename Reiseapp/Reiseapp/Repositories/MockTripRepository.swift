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
        Trip(
            title: "UI Preview",
            destination: "Anywhere",
            startDate: Date().addingTimeInterval(86400),
            endDate: Date().addingTimeInterval(86400 * 5),
            imageName: "photo.on.rectangle"
        ),
        Trip(
            title: "Demo Reise",
            destination: "Barcelona",
            startDate: Date().addingTimeInterval(86400 * 14),
            endDate: Date().addingTimeInterval(86400 * 21)
        ),
        Trip(
            title: "Wochenendtrip",
            destination: "München"
        )
    ]

    func fetchTrips() async throws -> [Trip] {
        // Simuliere kleinen Delay für realistische Preview
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1 Sekunden
        return items
    }
    
    func add(_ trip: Trip) async throws {
        items.insert(trip, at: 0)
    }
    
    func delete(ids: [UUID]) async throws {
        items.removeAll { ids.contains($0.id) }
    }
}
