//
//  TripRowView.swift
//  Reiseapp
//
//  Created by Florica Girisci on 08.09.25.
//

import SwiftUI
import UIKit

struct TripRow: View {
    let trip: Trip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let data = trip.photoData, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityHidden(true)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    Image(systemName: "photo")
                }
                .frame(width: 56, height: 56)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title).font(.headline)
                Text("\(trip.startLocation) → \(trip.destination)")
                    .foregroundStyle(.secondary)
                HStack(spacing: 12) {
                    Label((trip.startDate?.formatted(
                        date: .abbreviated, time: .omitted))!,
                          systemImage: "calendar")
                    Label("\(trip.persons.count)", systemImage: "person.2")
                    Label {
                        Text(trip.totalPrice,
                             format: .currency(code: Locale.current.currency?.identifier ?? "EUR"))
                    } icon: {
                        Image(systemName: "eurosign.circle")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
