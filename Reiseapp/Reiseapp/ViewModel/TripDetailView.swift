//
//  TripDetailView.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI

struct TripDetailView: View {
    let trip: Trip

    var body: some View {
        VStack(spacing: 16) {
            Text(trip.title).font(.largeTitle.bold())
            Text(trip.destination).font(.title3).foregroundStyle(.secondary)
            Spacer()
        }
        .padding()
        .navigationTitle("Reise-Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
