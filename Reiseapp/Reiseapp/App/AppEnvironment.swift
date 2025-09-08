//
//  AppEnvironment.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

/// Dependency Container
final class AppEnvironment: ObservableObject {
    let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    /// In der App: Live-Umgebung (aktuell: Local/In-Memory)
    static func live() -> AppEnvironment {
        AppEnvironment(tripRepository: LocalTripRepository(seed: SeedData.trips))
    }

    /// Für Previews/Tests
    static func preview() -> AppEnvironment {
        AppEnvironment(tripRepository: MockTripRepository())
    }
}
