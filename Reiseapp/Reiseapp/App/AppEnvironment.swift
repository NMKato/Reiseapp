//
//  AppEnvironment.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

// Dependency Container
final class AppEnvironment: ObservableObject {
    let tripRepository: TripRepository

    init(tripRepository: TripRepository) {
        self.tripRepository = tripRepository
    }

    static var live: AppEnvironment {
        AppEnvironment(tripRepository: LocalTripRepository(seed: SeedData.trips))
    }
    static var preview: AppEnvironment {
        AppEnvironment(tripRepository: MockTripRepository())
    }
}


private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
