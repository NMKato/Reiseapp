//
//  TripsListViewModel.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

@MainActor
final class TripsListViewModel: ObservableObject {
    @Published var trips: [Trip] = []
    @Published var query: String = ""
    @Published var showingAddSheet = false

    private let repo: TripRepository

    init(repo: TripRepository) {
        self.repo = repo
    }

    func load() async {
        do { trips = try await repo.fetchTrips() }
        catch { trips = [] }
    }

    func add(title: String, destination: String) async {
        guard !title.isEmpty, !destination.isEmpty else { return }
        do {
            try await repo.add(.init(title: title, destination: destination))
            await load()
        } catch { }
    }

    func delete(at offsets: IndexSet) async {
        let ids = offsets.map { trips[$0].id }
        do { try await repo.delete(ids: ids); await load() } catch { }
    }

    var filtered: [Trip] {
        let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return trips }
        return trips.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.destination.localizedCaseInsensitiveContains(q)
        }
    }
}
