//
//  TripRepository.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

protocol TripRepository {
    func fetchTrips() async throws -> [Trip]
    func add(_ trip: Trip) async throws
    func delete(ids: [UUID]) async throws
}
