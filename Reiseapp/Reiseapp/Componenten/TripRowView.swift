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
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    private var daysRemaining: Int {
        guard let startDate = trip.startDate else { return 0 }
        
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startOfTripDate = calendar.startOfDay(for: startDate)
        
        let components = calendar.dateComponents([.day], from: startOfToday, to: startOfTripDate)
        return components.day ?? 0
    }
    
    private var countdownText: String {
        let days = daysRemaining
        if days > 0 {
            return "Noch \(days) \(days == 1 ? "Tag" : "Tage")"
        } else if days == 0 {
            return "Heute!"
        } else {
            return "Vergangen"
        }
    }
    
    private var countdownColor: Color {
        let days = daysRemaining
        if days > 7 {
            return .blue
        } else if days > 0 {
            return .orange
        } else if days == 0 {
            return .green
        } else {
            return .gray
        }
    }

    var body: some View {
        HStack(spacing: 12) {
            thumbnail

            VStack(alignment: .leading, spacing: 4) {
                // Greeting text with trip destination
                Text("Deine Reise nach \(trip.destination)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(trip.title)
                    .font(.headline)
                    .lineLimit(1)
                
                // Travel dates
                if let startDate = trip.startDate, let endDate = trip.endDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.caption)
                            .foregroundStyle(.blue)
                        
                        Text("\(dateFormatter.string(from: startDate)) - \(dateFormatter.string(from: endDate))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Days countdown
                HStack(spacing: 4) {
                    Image(systemName: daysRemaining > 0 ? "clock" : (daysRemaining == 0 ? "star.fill" : "checkmark.circle.fill"))
                        .font(.caption)
                        .foregroundStyle(countdownColor)
                    
                    Text(countdownText)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(countdownColor)
                }
            }

            Spacer()
            
            if showDisclosure {
                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }

    @ViewBuilder
    private var thumbnail: some View {
        if let imageName = trip.imageName, !imageName.isEmpty {
            // Check if it's a URL (hotel image)
            if imageName.hasPrefix("http") || imageName.hasPrefix("https") {
                AsyncImage(url: URL(string: imageName)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 44, height: 44)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    case .failure(_):
                        placeholder
                            .frame(width: 44, height: 44)
                    case .empty:
                        placeholder
                            .frame(width: 44, height: 44)
                    @unknown default:
                        placeholder
                            .frame(width: 44, height: 44)
                    }
                }
            } else if UIImage(named: imageName) != nil {
                // Local image
                Image(imageName)
                    .resizable().scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                placeholder
                    .frame(width: 44, height: 44)
            }
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
