//
//  TripRowView.swift
//  Reiseapp
//
//  Created by Florica Girisci on 08.09.25.
//

import SwiftUI

struct TripRowView: View {
    let trip: Trip
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Image placeholder
            if let imageName = trip.imageName {
                Image(systemName: imageName)
                    .font(.system(size: 28))
                    .foregroundColor(.blue)
                    .frame(width: 56, height: 56)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .accessibilityHidden(true)
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.2))
                    Image(systemName: "photo")
                        .foregroundColor(.gray)
                }
                .frame(width: 56, height: 56)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(trip.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(trip.destination)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                HStack(spacing: 12) {
                    if let startDate = trip.startDate {
                        Label(startDate.formatted(date: .abbreviated, time: .omitted), 
                              systemImage: "calendar")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    }
                    
                    if trip.hasActivities {
                        Label("\(trip.totalActivities)", systemImage: "star.fill")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                    
                    if let duration = trip.duration {
                        Label("\(duration) Tage", systemImage: "clock")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 4)
            
            Spacer()
        }
        .contentShape(Rectangle())
    }
}