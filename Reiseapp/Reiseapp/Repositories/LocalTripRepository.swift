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
        private let fileURL: URL
       private let encoder = JSONEncoder()
       private let decoder = JSONDecoder()
       private let queue = DispatchQueue(label: "LocalTripRepository.queue", qos: .userInitiated)

       /// If you pass a `seed`, it will be written only if the file doesn't exist yet.
       init(filename: String = "trips.json", seed: [Trip] = []) {
           let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
           self.fileURL = dir.appendingPathComponent(filename)
           encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
           encoder.dateEncodingStrategy = .iso8601
           decoder.dateDecodingStrategy = .iso8601

           if !FileManager.default.fileExists(atPath: fileURL.path), !seed.isEmpty {
               do {
                   let data = try encoder.encode(seed)
                   try data.write(to: fileURL, options: .atomic)
               } catch {
                   print("Seed write failed:", error)
               }
           }
       }
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
