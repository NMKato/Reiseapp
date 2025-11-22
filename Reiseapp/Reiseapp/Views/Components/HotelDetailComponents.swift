//
//  HotelDetailComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct CityLandmark {
    let city: String
    let hotel: String
    let price: String
    let landmark: String
    let gradient: [Color]
    let imageURL: String
}

// MARK: - Hotel Sections

struct PopularHotelsSection: View {
    let checkInDate: Date
    let checkOutDate: Date
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Beliebte Hotels")
                    .font(.headline)
                Spacer()
                Button("Alle anzeigen") {}
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)
            
            if viewModel.isLoadingPopularHotels {
                HStack {
                    Spacer()
                    ProgressView("Hotels werden geladen...")
                        .font(.caption)
                    Spacer()
                }
                .frame(height: 120)
            } else if viewModel.popularHotels.isEmpty {
                Text("Keine Hotels verfügbar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(viewModel.popularHotels.prefix(5), id: \.id) { hotel in
                            VStack(alignment: .leading, spacing: 8) {
                                // Hotel image
                                ZStack {
                                    if let firstImage = hotel.images.first, let imageURL = URL(string: firstImage) {
                                        AsyncImage(url: imageURL) { phase in
                                            switch phase {
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 160, height: 100)
                                                    .clipped()
                                                    .cornerRadius(12)
                                            case .failure(_):
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.red.opacity(0.3))
                                                    .frame(width: 160, height: 100)
                                                    .overlay(
                                                        Image(systemName: "exclamationmark.triangle")
                                                            .font(.title2)
                                                            .foregroundStyle(.white.opacity(0.8))
                                                    )
                                            case .empty:
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.blue.opacity(0.3))
                                                    .frame(width: 160, height: 100)
                                                    .overlay(
                                                        ProgressView()
                                                            .scaleEffect(0.8)
                                                            .foregroundStyle(.white)
                                                    )
                                            @unknown default:
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(.gray.opacity(0.3))
                                                    .frame(width: 160, height: 100)
                                                    .overlay(
                                                        Image(systemName: "building.2.fill")
                                                            .font(.largeTitle)
                                                            .foregroundStyle(.white.opacity(0.8))
                                                    )
                                            }
                                        }
                                    } else {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.blue.opacity(0.3))
                                            .frame(width: 160, height: 100)
                                            .overlay(
                                                Image(systemName: "building.2.fill")
                                                    .font(.largeTitle)
                                                    .foregroundStyle(.white.opacity(0.8))
                                            )
                                    }
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(hotel.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .lineLimit(2)
                                    Text(hotel.address.city)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text(hotel.pricePerNight.formatted)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .frame(width: 160)
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            if viewModel.popularHotels.isEmpty && !viewModel.isLoadingPopularHotels {
                viewModel.loadPopularHotels()
            }
        }
    }
}

struct ModernPopularHotelsSection: View {
    @StateObject private var viewModel = ExploreViewModel()
    @State private var apiHotels: [Hotel] = []
    @State private var isLoading = true
    private let hotelService = HotelSearchService()
    
    // Popular destinations for hotel showcase
    private let showcaseDestinations = ["Berlin", "München", "Barcelona", "Paris", "Amsterdam"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Premium Hotels")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Alle anzeigen") {}
                    .font(.subheadline)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)
            
            if isLoading {
                HStack {
                    Spacer()
                    VStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Premium Hotels werden geladen...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
                .frame(height: 240)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(apiHotels.prefix(6), id: \.id) { hotel in
                            ModernHotelCardFromAPI(hotel: hotel)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .onAppear {
            loadPremiumHotels()
        }
    }
    
    private func loadPremiumHotels() {
        guard isLoading && apiHotels.isEmpty else { return }
        
        Task {
            var hotels: [Hotel] = []
            
            for destination in showcaseDestinations {
                do {
                    let parameters = HotelSearchParameters(
                        destination: destination,
                        checkInDate: viewModel.checkInDate,
                        checkOutDate: viewModel.checkOutDate,
                        numberOfAdults: 2,
                        numberOfChildren: 0,
                        numberOfRooms: 1,
                        maxPrice: nil,
                        minRating: 4.5, // Premium hotels only
                        accommodationType: nil,
                        hasWiFi: false,
                        hasKitchen: false,
                        hasParking: false,
                        hasWashingMachine: false,
                        isPetFriendly: false,
                        hasAirConditioning: false,
                        hasPool: false,
                        hasGym: false,
                        hasCrib: false
                    )
                    
                    let result = try await hotelService.searchHotels(parameters: parameters)
                    // Get the best hotel from each destination
                    if let bestHotel = result.first {
                        hotels.append(bestHotel)
                    }
                } catch {
                    print("Failed to load premium hotel for \(destination): \(error)")
                }
            }
            
            await MainActor.run {
                self.apiHotels = hotels
                self.isLoading = false
            }
        }
    }
}

// MARK: - Hotel Cards

struct ModernHotelCardFromAPI: View {
    let hotel: Hotel
    
    var body: some View {
        VStack(spacing: 0) {
            // Hotel image with fixed dimensions
            ZStack(alignment: .bottom) {
                if let firstImage = hotel.images.first, let imageURL = URL(string: firstImage) {
                    AsyncImage(url: imageURL) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .clipped()
                        case .failure(_):
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.title2)
                                        .foregroundStyle(.gray)
                                )
                        case .empty:
                            Rectangle()
                                .fill(LinearGradient(colors: [.blue.opacity(0.5), .cyan.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .overlay(
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .foregroundStyle(.white)
                                )
                        @unknown default:
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                        }
                    }
                } else {
                    Rectangle()
                        .fill(LinearGradient(colors: [.blue.opacity(0.5), .cyan.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.title)
                                .foregroundStyle(.white.opacity(0.8))
                        )
                }
                
                // Gradient overlay for text readability
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.7)],
                    startPoint: .center,
                    endPoint: .bottom
                )
            }
            .frame(height: 120)
            .clipped()
            
            // Content section with fixed height
            VStack(alignment: .leading, spacing: 6) {
                // Name and Location
                Text(hotel.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(hotel.address.city)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                // Rating
                HStack(spacing: 2) {
                    if let rating = hotel.rating {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(rating, specifier: "%.1f")")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Price
                    Text(hotel.pricePerNight.formatted)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                
                // Distance
                if let distance = hotel.distanceFromCenter {
                    Text("\(distance, specifier: "%.1f") km vom Zentrum")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            .padding(10)
            .frame(height: 100)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 220) // Fixed total height
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

struct ModernHotelCard: View {
    let landmark: CityLandmark
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Hotel image with beautiful overlay
            ZStack {
                AsyncImage(url: URL(string: landmark.imageURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(16)
                } placeholder: {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: landmark.gradient,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "building.2.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.9))
                        )
                }
                
                // Gradient overlay for better text readability
                LinearGradient(
                    colors: [Color.clear, Color.black.opacity(0.6)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .cornerRadius(16)
                
                // City and landmark info overlay
                VStack {
                    Spacer()
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(landmark.city)
                                .font(.subheadline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            
                            Text(landmark.landmark)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.9))
                        }
                        
                        Spacer()
                        
                        Text(landmark.price)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.25))
                            .cornerRadius(8)
                    }
                    .padding()
                }
            }
            
            // Hotel name
            VStack(alignment: .leading, spacing: 4) {
                Text(landmark.hotel)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                HStack {
                    HStack(spacing: 2) {
                        ForEach(0..<5) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                    
                    Spacer()
                    
                    Text("ab \(landmark.price)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(width: 200)
        .padding()
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

struct HotelGridCard: View {
    let hotel: Hotel
    
    var body: some View {
        VStack(spacing: 0) {
            // Bild mit fester Größe
            if let firstImage = hotel.images.first, let imageURL = URL(string: firstImage) {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .overlay(
                            ProgressView()
                                .scaleEffect(0.8)
                        )
                }
                .frame(width: 160, height: 120)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                Rectangle()
                    .fill(LinearGradient(
                        colors: [.blue.opacity(0.3), .cyan.opacity(0.3)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 160, height: 120)
                    .overlay(
                        Image(systemName: "building.2.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            
            // Content mit fester Größe
            VStack(alignment: .leading, spacing: 4) {
                Text(hotel.name)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(hotel.address.city)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                HStack {
                    if let rating = hotel.rating {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text("\(rating, specifier: "%.1f")")
                                .font(.caption2)
                                .fontWeight(.medium)
                        }
                    }
                    
                    Spacer()
                    
                    Text(hotel.pricePerNight.formatted)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(10)
            .frame(width: 160, height: 80)
            .background(Color(.systemBackground))
        }
        .frame(width: 160, height: 220)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Hotel Results Section

struct HotelResultsSection: View {
    let hotels: [Hotel]
    let checkInDate: Date
    let checkOutDate: Date
    @State private var showingMap = false
    @State private var selectedHotel: Hotel?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with map toggle
            HStack {
                Text("Gefundene Hotels")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                
                if !hotels.isEmpty {
                    Button(action: { showingMap = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: "map")
                                .font(.caption)
                            Text("Karte")
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(8)
                    }
                }
                
                Text("\(hotels.count) gefunden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            
            if hotels.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "building.2")
                        .font(.system(size: 40))
                        .foregroundStyle(.secondary)
                    Text("Keine Hotels gefunden")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                LazyVGrid(columns: [
                    GridItem(.fixed(160), spacing: 16),
                    GridItem(.fixed(160), spacing: 16)
                ], spacing: 24) {
                    ForEach(hotels, id: \.id) { hotel in
                        Button(action: {
                            selectedHotel = hotel
                        }) {
                            HotelGridCard(hotel: hotel)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .sheet(isPresented: $showingMap) {
            NavigationStack {
                HotelMapView(hotels: hotels, destination: "Ziel")
                    .navigationTitle("Hotels auf Karte")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Fertig") {
                                showingMap = false
                            }
                        }
                    }
            }
        }
        .sheet(item: $selectedHotel) { hotel in
            UnterkunftDetailSheet(
                accommodation: hotel,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate
            )
        }
    }
}

// MARK: - Hotel Search Expanded View

struct HotelSearchExpandedView: View {
    let destination: String
    let checkInDate: Date
    let checkOutDate: Date
    let onHotelSelected: (Hotel) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Hotels in \(destination)")
                .font(.headline)
            
            HotelResultsSection(
                hotels: [],
                checkInDate: checkInDate,
                checkOutDate: checkOutDate
            )
        }
    }
}

// MARK: - Extensions


// MARK: - Previews

#if DEBUG
struct HotelDetailComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PopularHotelsSection(
                checkInDate: Date(), 
                checkOutDate: Date().addingTimeInterval(86400),
                viewModel: ExploreViewModel()
            )
                .previewDisplayName("Popular Hotels Section")
            
            ModernHotelCard(
                landmark: CityLandmark(
                    city: "Berlin",
                    hotel: "Hotel Adlon Kempinski",
                    price: "€299",
                    landmark: "Brandenburger Tor",
                    gradient: [Color.orange, Color.yellow],
                    imageURL: "https://example.com/hotel.jpg"
                )
            )
            .previewDisplayName("Modern Hotel Card")
        }
    }
}
#endif