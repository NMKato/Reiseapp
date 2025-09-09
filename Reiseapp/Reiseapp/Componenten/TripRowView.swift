//
//  TripRowView.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI

struct TripRowView: View {
    let trip: Trip
    var showDisclosure: Bool = false   // <- neu

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 2) {
                Text(trip.title).font(.headline)
                Text(trip.destination)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()
            if showDisclosure {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let name = trip.imageName, !name.isEmpty, UIImage(named: name) != nil {
            Image(name)
                .resizable().scaledToFill()
                .frame(width: 44, height: 44)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            placeholder
                .frame(width: 44, height: 44)
        }
    }

    private var placeholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8).fill(.thinMaterial)
            Image(systemName: "photo")
                .imageScale(.large)
                .foregroundStyle(.secondary)
        }
    }
}
