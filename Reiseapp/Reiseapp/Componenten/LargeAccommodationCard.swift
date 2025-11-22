//
//  LargeAccommodationCard.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Large Accommodation Card (Bildorientiert)
struct LargeAccommodationCard: View {
    let accommodation: Hotel
    
    var body: some View {
        VStack(spacing: 0) {
            // Großes Hauptbild
            ZStack(alignment: .topTrailing) {
                if let firstImage = accommodation.images.first, let imageURL = URL(string: firstImage) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 220)
                                .clipped()
                        case .failure(_):
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.red.opacity(0.3))
                                .frame(height: 220)
                                .overlay(
                                    VStack {
                                        Image(systemName: "exclamationmark.triangle")
                                            .font(.largeTitle)
                                            .foregroundStyle(.red)
                                        Text("Bild nicht verfügbar")
                                            .font(.caption)
                                            .foregroundStyle(.red)
                                    }
                                )
                        case .empty:
                            RoundedRectangle(cornerRadius: 0)
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.4), .cyan.opacity(0.4)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 220)
                                .overlay(
                                    VStack {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                            .foregroundStyle(.white)
                                        Text("Lade Bild...")
                                            .font(.caption)
                                            .foregroundStyle(.white.opacity(0.8))
                                    }
                                )
                        @unknown default:
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.gray.opacity(0.3))
                                .frame(height: 220)
                        }
                    }
                } else {
                    RoundedRectangle(cornerRadius: 0)
                        .fill(
                            LinearGradient(
                                colors: [.blue.opacity(0.4), .cyan.opacity(0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 220)
                        .overlay(
                            VStack {
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 48))
                                    .foregroundStyle(.white.opacity(0.8))
                                Text("Standardbild")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                            }
                        )
                }
                
                // Preis Badge (rechts oben)
                Text("€\(Int(accommodation.pricePerNight.amount))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.top, 12)
                    .padding(.trailing, 12)
            }
            
            // Informationsbereich
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    // Name der Unterkunft
                    Text(accommodation.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(2)
                    
                    // Rating
                    if let rating = accommodation.rating {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                    .font(.caption)
                                    .foregroundStyle(.yellow)
                            }
                            Text("\(rating, specifier: "%.1f")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("pro Nacht")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    } else {
                        HStack {
                            Text("Neue Unterkunft")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("pro Nacht")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Standort
                HStack(spacing: 6) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text(accommodation.address.fullAddress)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    if let distance = accommodation.distanceFromCenter {
                        Spacer()
                        Text("\(String(format: "%.1f", distance)) km")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                // Ausstattung (prominenter dargestellt)
                if !accommodation.amenities.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(accommodation.amenities.prefix(5), id: \.self) { amenity in
                                HStack(spacing: 4) {
                                    Image(systemName: amenityIcon(for: amenity))
                                        .font(.caption2)
                                        .foregroundStyle(.blue)
                                    Text(amenity)
                                        .font(.caption2)
                                        .foregroundStyle(.primary)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        .padding(.horizontal, 1) // Für bessere clipping Vermeidung
                    }
                }
            }
            .padding(16)
        }
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
    
    private func amenityIcon(for amenity: String) -> String {
        let lowercased = amenity.lowercased()
        switch lowercased {
        case let str where str.contains("wifi") || str.contains("internet"):
            return "wifi"
        case let str where str.contains("pool") || str.contains("schwimm"):
            return "figure.pool.swim"
        case let str where str.contains("fitness") || str.contains("gym"):
            return "dumbbell.fill"
        case let str where str.contains("küche") || str.contains("kitchen"):
            return "oven.fill"
        case let str where str.contains("parkplatz") || str.contains("parking"):
            return "car.fill"
        case let str where str.contains("klima") || str.contains("air"):
            return "snowflake"
        case let str where str.contains("wasch") || str.contains("wash"):
            return "washer.fill"
        case let str where str.contains("haustier") || str.contains("pet"):
            return "pawprint.fill"
        default:
            return "checkmark.circle.fill"
        }
    }
}

#Preview {
    LargeAccommodationCard(
        accommodation: Hotel(
            id: "1",
            name: "Moderne Wohnung im Stadtzentrum",
            address: Address(street: "Hauptstraße 123", city: "Berlin", postalCode: "10115", country: "Deutschland"),
            rating: 4.8,
            pricePerNight: Price(amount: 85, currency: "EUR"),
            amenities: ["WLAN", "Küche", "Waschmaschine", "Klimaanlage"],
            images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400"],
            description: "Eine wunderschöne Wohnung.",
            distanceFromCenter: 2.5,
            coordinates: Coordinates(latitude: 52.5200, longitude: 13.4050),
            availability: true,
            roomTypes: [],
            contact: nil
        )
    )
}