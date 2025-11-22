//
//  UnterkunftDetailSheet.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Unterkunft Detail Sheet (wie Airbnb)
struct UnterkunftDetailSheet: View {
    let accommodation: Hotel
    let checkInDate: Date
    let checkOutDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var appEnvironment
    @State private var selectedImageIndex = 0
    @State private var showTravelSheet = false
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    private var nightsCount: Int {
        Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 1
    }
    
    private var totalPrice: Double {
        accommodation.pricePerNight.amount * Double(nightsCount)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Hero Image Gallery
                    imageGallery
                    
                    // Content
                    VStack(alignment: .leading, spacing: 24) {
                        // Header Info
                        headerSection
                        
                        // Reisedaten
                        reisedatenSection
                        
                        // Zimmer & Gäste Info
                        zimmerSection
                        
                        Divider()
                        
                        // Beschreibung
                        beschreibungSection
                        
                        Divider()
                        
                        // Ausstattung
                        ausstattungSection
                        
                        Divider()
                        
                        // Standort
                        standortSection
                        
                        // Preis & Buchung
                        preisSection
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(accommodation.name)
                        .font(.headline)
                        .lineLimit(1)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showTravelSheet) {
                TravelOptionsSheet(
                    room: accommodation.roomTypes.first ?? RoomType(
                        id: "default",
                        name: "Standard Room",
                        maxOccupancy: 2,
                        price: accommodation.pricePerNight,
                        amenities: accommodation.amenities,
                        available: true,
                        images: accommodation.images
                    ),
                    hotel: accommodation,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate
                )
            }
        }
    }
    
    // MARK: - Image Gallery
    private var imageGallery: some View {
        TabView(selection: $selectedImageIndex) {
            ForEach(accommodation.images.indices, id: \.self) { index in
                AsyncImage(url: URL(string: accommodation.images[index])) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 300)
                            .clipped()
                    case .failure(_), .empty:
                        Rectangle()
                            .fill(.gray.opacity(0.3))
                            .frame(height: 300)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundStyle(.gray)
                                    Text("Bild nicht verfügbar")
                                        .font(.caption)
                                        .foregroundStyle(.gray)
                                }
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .tag(index)
            }
        }
        .frame(height: 300)
        .tabViewStyle(.page)
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(accommodation.name)
                .font(.title2)
                .fontWeight(.bold)
            
            HStack {
                if let rating = accommodation.rating {
                    HStack(spacing: 2) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text("\(rating, specifier: "%.1f")")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                }
                
                Text("•")
                    .foregroundStyle(.secondary)
                
                Text(accommodation.address.fullAddress)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
    
    // MARK: - Reisedaten Section
    private var reisedatenSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.blue)
                Text("Deine Reise")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("ANREISE")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(dateFormatter.string(from: checkInDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("ABREISE")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(dateFormatter.string(from: checkOutDate))
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("AUFENTHALT")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text("\(nightsCount) \(nightsCount == 1 ? "Nacht" : "Nächte")")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Zimmer Section
    private var zimmerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "bed.double")
                    .foregroundStyle(.blue)
                Text("Unterkunft Details")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(spacing: 12) {
                accommodationDetail(
                    icon: "person.2",
                    title: "Gäste",
                    value: "Bis zu 2 Gäste" // Standardwert, könnte aus API kommen
                )
                
                accommodationDetail(
                    icon: "bed.double",
                    title: "Schlafzimmer",
                    value: "1 Schlafzimmer" // Standardwert
                )
                
                accommodationDetail(
                    icon: "shower",
                    title: "Badezimmer",
                    value: "1 Badezimmer" // Standardwert
                )
            }
        }
    }
    
    private func accommodationDetail(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundStyle(.secondary)
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    // MARK: - Beschreibung Section
    private var beschreibungSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "text.alignleft")
                    .foregroundStyle(.blue)
                Text("Über diese Unterkunft")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(accommodation.description ?? "Diese wunderschöne Unterkunft bietet alles, was Sie für einen perfekten Aufenthalt benötigen. Genießen Sie den Komfort und die Annehmlichkeiten in bester Lage.")
                .font(.body)
                .lineSpacing(4)
        }
    }
    
    // MARK: - Ausstattung Section
    private var ausstattungSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "checkmark.seal")
                    .foregroundStyle(.blue)
                Text("Was diese Unterkunft bietet")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), alignment: .leading), count: 2), spacing: 12) {
                ForEach(accommodation.amenities, id: \.self) { amenity in
                    HStack(spacing: 8) {
                        Image(systemName: amenityIcon(for: amenity))
                            .foregroundStyle(.blue)
                            .frame(width: 20)
                        Text(amenity)
                            .font(.subheadline)
                        Spacer()
                    }
                }
            }
        }
    }
    
    // MARK: - Standort Section
    private var standortSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "location")
                    .foregroundStyle(.blue)
                Text("Wo du übernachtest")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text(accommodation.address.fullAddress)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let distance = accommodation.distanceFromCenter {
                    Text("\(String(format: "%.1f", distance)) km vom Stadtzentrum entfernt")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(16)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    // MARK: - Preis Section
    private var preisSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("€\(Int(accommodation.pricePerNight.amount))")
                        .font(.title2)
                        .fontWeight(.bold)
                    + Text(" pro Nacht")
                        .font(.subheadline)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                    
                    Text("Gesamt: €\(Int(totalPrice)) für \(nightsCount) \(nightsCount == 1 ? "Nacht" : "Nächte")")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
            }
            
            Button("Unterkunft hinzufügen") {
                showTravelSheet = true
            }
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.blue, in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(.vertical)
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
    UnterkunftDetailSheet(
        accommodation: Hotel(
            id: "1",
            name: "Moderne Wohnung im Stadtzentrum",
            address: Address(street: "Hauptstraße 123", city: "Berlin", postalCode: "10115", country: "Deutschland"),
            rating: 4.8,
            pricePerNight: Price(amount: 85, currency: "EUR"),
            amenities: ["WLAN", "Küche", "Waschmaschine", "Klimaanlage"],
            images: ["https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400"],
            description: "Eine wunderschöne, moderne Wohnung im Herzen der Stadt.",
            distanceFromCenter: 2.5,
            coordinates: Coordinates(latitude: 52.5200, longitude: 13.4050),
            availability: true,
            roomTypes: [],
            contact: nil
        ),
        checkInDate: Date(),
        checkOutDate: Calendar.current.date(byAdding: .day, value: 3, to: Date()) ?? Date()
    )
    .environment(\.appEnvironment, .preview)
}
