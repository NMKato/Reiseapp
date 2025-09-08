//
//  TripsListView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import SwiftUI

struct TripsListView: View {
    @StateObject private var vm: TripsListViewModel

    // Repo wird vom Aufrufer (z. B. RootView) übergeben
    init(repo: TripRepository) {
        _vm = StateObject(wrappedValue: TripsListViewModel(repo: repo))
    }

    var body: some View {
        Group {
            if vm.trips.isEmpty {
                Text("Noch keine Reisen")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(filtered) { trip in
                        NavigationLink(value: trip) {
                            TripRowView(trip: trip)   // Disclosure-Pfeil kommt vom NavigationLink
                        }
                    }
                    .onDelete { idx in
                        Task { await vm.delete(at: idx) }
                    }
                }
                .listStyle(.insetGrouped)      // ⬅️ hängt wieder korrekt an der List
                .refreshable { await vm.load() } // optional: Pull-to-refresh
            }
        }
        .navigationTitle("Meine Reisen")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { vm.showingAddSheet = true } label: {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Neue Reise")
            }
        }
        .sheet(isPresented: $vm.showingAddSheet) {
            AddTripSheet { title, dest in
                await vm.add(title: title, destination: dest)
            }
        }
        .searchable(text: $vm.query)
        .navigationDestination(for: Trip.self) { trip in
            TripDetailView(trip: trip)
        }
        .task { await vm.load() }
    }

    private var filtered: [Trip] {
        let q = vm.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return vm.trips }
        return vm.trips.filter {
            $0.title.localizedCaseInsensitiveContains(q) ||
            $0.destination.localizedCaseInsensitiveContains(q)
        }
    }
}