//
//  HotelSearchView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import SwiftUI
import MapKit
import CoreLocation

struct HotelSearchView: View {
    @State private var destination: String
    @State private var checkInDate: Date
    @State private var checkOutDate: Date
    @State private var numberOfAdults: Int
    @State private var numberOfChildren: Int
    @State private var numberOfRooms: Int
    @State private var maxPrice: Double = 500
    @State private var minRating: Double = 3.0
    
    // Moderne smarte Filter
    @State private var selectedAccommodationType: AccommodationType = .all
    @State private var hasWiFi = false
    @State private var hasKitchen = false
    @State private var hasParking = false
    @State private var hasWashingMachine = false
    @State private var isPetFriendly = false
    @State private var hasAirConditioning = false
    @State private var hasPool = false
    @State private var hasGym = false
    @State private var hasCrib = false
    
    init(
        destination: String = "",
        checkInDate: Date = Date(),
        checkOutDate: Date = Date().addingTimeInterval(86400 * 2),
        numberOfAdults: Int = 2,
        numberOfChildren: Int = 0,
        numberOfRooms: Int = 1
    ) {
        self._destination = State(initialValue: destination)
        self._checkInDate = State(initialValue: checkInDate)
        self._checkOutDate = State(initialValue: checkOutDate)
        self._numberOfAdults = State(initialValue: numberOfAdults)
        self._numberOfChildren = State(initialValue: numberOfChildren)
        self._numberOfRooms = State(initialValue: numberOfRooms)
    }
    
    @State private var accommodations: [Hotel] = []
    @State private var isSearching = false
    @State private var errorMessage: String?
    @State private var selectedAccommodation: Hotel?
    @State private var showFilters = false
    @State private var sortOption: SortOption = .priceAscending
    @State private var showMapView = false
    
    private let accommodationService = HotelSearchService()
    
    
    enum SortOption: String, CaseIterable {
        case priceAscending = "Preis aufsteigend"
        case priceDescending = "Preis absteigend"
        case ratingDescending = "Beste Bewertung"
        case distanceAscending = "Nähe zum Zentrum"
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Search Header
                    searchSection
                    
                    // Filters Bar
                    filtersBar
                    
                    // Results Section
                    if isSearching {
                        ProgressView("Suche Unterkünfte...")
                            .frame(maxWidth: .infinity)
                            .padding(40)
                    } else if !accommodations.isEmpty {
                        resultsSection
                    } else if errorMessage != nil {
                        errorView
                    } else {
                        emptyStateView
                    }
                }
                .padding()
            }
            .dismissKeyboardOnScroll()
            .navigationTitle("Unterkünfte finden")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showFilters) {
                ModernFiltersSheet(
                    maxPrice: $maxPrice,
                    minRating: $minRating,
                    sortOption: $sortOption,
                    selectedAccommodationType: $selectedAccommodationType,
                    hasWiFi: $hasWiFi,
                    hasKitchen: $hasKitchen,
                    hasParking: $hasParking,
                    hasWashingMachine: $hasWashingMachine,
                    isPetFriendly: $isPetFriendly,
                    hasAirConditioning: $hasAirConditioning,
                    hasPool: $hasPool,
                    hasGym: $hasGym
                )
            }
            .sheet(item: $selectedAccommodation) { accommodation in
                UnterkunftDetailSheet(accommodation: accommodation, checkInDate: checkInDate, checkOutDate: checkOutDate)
            }
            .sheet(isPresented: $showMapView) {
                AccommodationsMapView(accommodations: accommodations, destination: destination)
            }
            .onAppear {
                // Auto-search if destination is provided
                if !destination.isEmpty {
                    searchAccommodations()
                }
            }
        }
    }
    
    // MARK: - Search Section
    private var searchSection: some View {
        VStack(spacing: 16) {
            // Destination Input
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(.secondary)
                TextField("Reiseziel", text: $destination)
                    .textFieldStyle(.plain)
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(12)
            
            // Date Selection
            HStack(spacing: 12) {
                DatePickerCard(
                    title: "Check-in",
                    date: $checkInDate,
                    icon: "calendar.badge.plus"
                )
                
                DatePickerCard(
                    title: "Check-out",
                    date: $checkOutDate,
                    icon: "calendar.badge.minus"
                )
            }
            
            // Guest Selection
            HStack(spacing: 12) {
                StepperCard(
                    title: "Erwachsene",
                    value: $numberOfAdults,
                    range: 1...10,
                    icon: "person.2.fill"
                )
                
                StepperCard(
                    title: "Kinder",
                    value: $numberOfChildren,
                    range: 0...10,
                    icon: "figure.and.child.holdinghands"
                )
                
                StepperCard(
                    title: "Zimmer",
                    value: $numberOfRooms,
                    range: 1...10,
                    icon: "bed.double.fill"
                )
            }
            
            // Search Button
            Button(action: searchAccommodations) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Unterkünfte suchen")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
            .disabled(destination.isEmpty)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
        )
    }
    
    // MARK: - Filters Bar
    private var filtersBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Sort Menu
                Menu {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Button(action: { sortOption = option }) {
                            Label(
                                option.rawValue,
                                systemImage: sortOption == option ? "checkmark" : ""
                            )
                        }
                    }
                } label: {
                    FilterChip(
                        title: sortOption.rawValue,
                        icon: "arrow.up.arrow.down",
                        isActive: true
                    )
                }
                
                // Filter Button
                Button(action: { showFilters = true }) {
                    FilterChip(
                        title: "Filter",
                        icon: "slider.horizontal.3",
                        isActive: false
                    )
                }
                
                // Map Button
                Button(action: { showMapView = true }) {
                    FilterChip(
                        title: "Karte",
                        icon: "map.fill",
                        isActive: false
                    )
                }
                
                // Quick Filters
                FilterChip(
                    title: "Unter €\(Int(maxPrice))",
                    icon: "eurosign",
                    isActive: maxPrice < 500
                )
                
                FilterChip(
                    title: "\(Int(minRating))+ Sterne",
                    icon: "star.fill",
                    isActive: minRating > 3
                )
            }
        }
    }
    
    // MARK: - Results Section
    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("\(accommodations.count) Unterkünfte gefunden")
                    .font(.headline)
                Spacer()
            }
            
            LazyVStack(spacing: 16) {
                ForEach(sortedAccommodations) { accommodation in
                    LargeAccommodationCard(accommodation: accommodation)
                        .onTapGesture {
                            selectedAccommodation = accommodation
                        }
                }
            }
        }
    }
    
    private var sortedAccommodations: [Hotel] {
        accommodations.sorted { accommodation1, accommodation2 in
            switch sortOption {
            case .priceAscending:
                return accommodation1.pricePerNight.amount < accommodation2.pricePerNight.amount
            case .priceDescending:
                return accommodation1.pricePerNight.amount > accommodation2.pricePerNight.amount
            case .ratingDescending:
                return (accommodation1.rating ?? 0) > (accommodation2.rating ?? 0)
            case .distanceAscending:
                return (accommodation1.distanceFromCenter ?? 0) < (accommodation2.distanceFromCenter ?? 0)
            }
        }
    }
    
    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "building.2.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)
            
            Text("Finde dein perfektes Hotel")
                .font(.title3)
                .fontWeight(.medium)
            
            Text("Gib dein Reiseziel ein und wir finden die besten Hotels für dich")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Error View
    private var errorView: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(.orange)
            
            Text(errorMessage ?? "Ein Fehler ist aufgetreten")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            Button("Erneut versuchen") {
                searchAccommodations()
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Search Function
    private func searchAccommodations() {
        Task {
            isSearching = true
            errorMessage = nil
            
            let parameters = HotelSearchParameters(
                destination: destination,
                checkInDate: checkInDate,
                checkOutDate: checkOutDate,
                numberOfAdults: numberOfAdults,
                numberOfChildren: numberOfChildren,
                numberOfRooms: numberOfRooms,
                maxPrice: maxPrice,
                minRating: minRating,
                accommodationType: selectedAccommodationType == .all ? nil : selectedAccommodationType.rawValue,
                hasWiFi: hasWiFi,
                hasKitchen: hasKitchen,
                hasParking: hasParking,
                hasWashingMachine: hasWashingMachine,
                isPetFriendly: isPetFriendly,
                hasAirConditioning: hasAirConditioning,
                hasPool: hasPool,
                hasGym: hasGym,
                hasCrib: hasCrib
            )
            
            do {
                let results = try await accommodationService.searchHotels(parameters: parameters)
                await MainActor.run {
                    withAnimation {
                        self.accommodations = results
                        self.isSearching = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isSearching = false
                }
            }
        }
    }
}

// MARK: - Hotel Card
struct HotelCard: View {
    let hotel: Hotel
    
    var body: some View {
        HStack(spacing: 16) {
            // Hotel Image
            if let firstImage = hotel.images.first, let imageURL = URL(string: firstImage) {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    case .failure(_):
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.red.opacity(0.3))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "exclamationmark.triangle")
                                    .foregroundStyle(.red)
                            )
                    case .empty:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.3), .cyan.opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .foregroundStyle(.white)
                            )
                    @unknown default:
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.gray)
                            .frame(width: 100, height: 100)
                    }
                }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .cyan.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .overlay(
                        Image(systemName: "building.2.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.white.opacity(0.8))
                    )
            }
            
            // Hotel Info
            VStack(alignment: .leading, spacing: 6) {
                Text(hotel.name)
                    .font(.headline)
                    .lineLimit(1)
                
                // Rating
                if let rating = hotel.rating {
                    HStack(spacing: 4) {
                        ForEach(0..<5) { index in
                            Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(.yellow)
                        }
                        Text(String(format: "%.1f", rating))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Location
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hotel.address.fullAddress)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        if let distance = hotel.distanceFromCenter {
                            Text("\(String(format: "%.1f", distance)) km vom Zentrum")
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                
                // Amenities
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(hotel.amenities.prefix(3), id: \.self) { amenity in
                            Text(amenity)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.ultraThinMaterial)
                                .cornerRadius(6)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: 4) {
                Text(hotel.pricePerNight.formatted)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text("pro Nacht")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if hotel.availability {
                    Text("Verfügbar")
                        .font(.caption)
                        .foregroundStyle(.green)
                } else {
                    Text("Ausgebucht")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
        )
    }
}

// MARK: - Helper Components
struct DatePickerCard: View {
    let title: String
    @Binding var date: Date
    let icon: String
    
    var body: some View {
        DatePicker(selection: $date, displayedComponents: .date) {
            Label(title, systemImage: icon)
                .font(.caption)
        }
        .datePickerStyle(.compact)
        .padding()
        .background(.quaternary)
        .cornerRadius(12)
    }
}

struct StepperCard: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            HStack(spacing: 12) {
                Button(action: { if value > range.lowerBound { value -= 1 } }) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(value > range.lowerBound ? .primary : .tertiary)
                }
                .disabled(value <= range.lowerBound)
                
                Text("\(value)")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .frame(minWidth: 20)
                
                Button(action: { if value < range.upperBound { value += 1 } }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(value < range.upperBound ? .primary : .tertiary)
                }
                .disabled(value >= range.upperBound)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.quaternary)
        .cornerRadius(12)
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(title)
                .font(.caption)
                .fontWeight(isActive ? .semibold : .regular)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(isActive ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.1))
        .foregroundStyle(isActive ? Color.accentColor : .primary)
        .cornerRadius(20)
    }
}

// MARK: - Filters Sheet
struct FiltersSheet: View {
    @Binding var maxPrice: Double
    @Binding var minRating: Double
    @Binding var sortOption: HotelSearchView.SortOption
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Preis") {
                    VStack(alignment: .leading) {
                        Text("Maximaler Preis: €\(Int(maxPrice))")
                            .font(.headline)
                        Slider(value: $maxPrice, in: 50...1000, step: 50)
                    }
                }
                
                Section("Bewertung") {
                    VStack(alignment: .leading) {
                        Text("Mindestbewertung: \(Int(minRating)) Sterne")
                            .font(.headline)
                        Slider(value: $minRating, in: 1...5, step: 1)
                    }
                }
                
                Section("Sortierung") {
                    Picker("Sortieren nach", selection: $sortOption) {
                        ForEach(HotelSearchView.SortOption.allCases, id: \.self) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Hotel Detail Sheet
struct HotelDetailSheet: View {
    let hotel: Hotel
    let checkInDate: Date
    let checkOutDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRoom: RoomType?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Travel Dates Display
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Check-in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(checkInDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Check-out")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(checkOutDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    // Hero Image
                    if let firstImage = hotel.images.first, let imageURL = URL(string: firstImage) {
                        AsyncImage(url: imageURL) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(height: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            case .failure(_):
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.red.opacity(0.4))
                                    .frame(height: 200)
                                    .overlay(
                                        VStack {
                                            Image(systemName: "exclamationmark.triangle")
                                                .font(.largeTitle)
                                                .foregroundStyle(.red)
                                            Text("Bild konnte nicht geladen werden")
                                                .font(.caption)
                                                .foregroundStyle(.red)
                                        }
                                    )
                            case .empty:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [.blue.opacity(0.4), .cyan.opacity(0.4)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(height: 200)
                                    .overlay(
                                        VStack {
                                            ProgressView()
                                                .foregroundStyle(.white)
                                            Text("Lade Bild...")
                                                .font(.caption)
                                                .foregroundStyle(.white)
                                        }
                                    )
                            @unknown default:
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(.gray)
                                    .frame(height: 200)
                            }
                        }
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.4), .cyan.opacity(0.4)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                            .overlay(
                                Image(systemName: "building.2.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white.opacity(0.8))
                            )
                    }
                    
                    // Hotel Info
                    VStack(alignment: .leading, spacing: 16) {
                        Text(hotel.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if let rating = hotel.rating {
                            HStack {
                                ForEach(0..<5) { index in
                                    Image(systemName: index < Int(rating) ? "star.fill" : "star")
                                        .foregroundStyle(.yellow)
                                }
                                Text(String(format: "%.1f", rating))
                                    .foregroundStyle(.secondary)
                            }
                        }
                        
                        // Address
                        Label(hotel.address.fullAddress, systemImage: "location.fill")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        // Description
                        if let description = hotel.description {
                            Text(description)
                                .font(.body)
                        }
                        
                        // Amenities
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Ausstattung")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(hotel.amenities, id: \.self) { amenity in
                                    HStack {
                                        Image(systemName: "checkmark.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                        Text(amenity)
                                            .font(.caption)
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // STANDALONE TEST BUTTON
                        Button("🔴 STANDALONE TEST BUTTON") {
                            print("🔴 STANDALONE BUTTON CLICKED!")
                        }
                        .padding()
                        .background(.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        // Room Types
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Zimmertypen")
                                    .font(.headline)
                                Spacer()
                                Button("TEST") {
                                    print("🧪 TEST BUTTON WORKS!")
                                }
                                .foregroundColor(.red)
                            }
                            
                            ForEach(hotel.roomTypes) { room in
                                Button("🛏️ \(room.name) - \(room.price.formatted)") {
                                    selectedRoom = room
                                }
                                .padding()
                                .background(.quaternary)
                                .cornerRadius(12)
                            }
                        }
                        
                        // Book Button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "calendar.badge.plus")
                                Text("Jetzt buchen")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Hotel Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(item: $selectedRoom) { room in
            RoomDetailSheet(room: room, hotel: hotel, checkInDate: checkInDate, checkOutDate: checkOutDate)
        }
    }
}

// MARK: - Room Detail Sheet
struct RoomDetailSheet: View {
    let room: RoomType
    let hotel: Hotel
    let checkInDate: Date
    let checkOutDate: Date
    @Environment(\.dismiss) private var dismiss
    @State private var showTravelOptions = false
    
    var hotelName: String {
        return hotel.name
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Travel Dates Display
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Check-in")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(checkInDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Check-out")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(checkOutDate.formatted(date: .abbreviated, time: .omitted))
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)
                    
                    // Room Images
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(room.images, id: \.self) { imageURL in
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 300, height: 200)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    case .failure(_):
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.red.opacity(0.3))
                                            .frame(width: 300, height: 200)
                                            .overlay(
                                                VStack {
                                                    Image(systemName: "exclamationmark.triangle")
                                                        .font(.title)
                                                        .foregroundStyle(.red)
                                                    Text("Bild nicht verfügbar")
                                                        .font(.caption)
                                                        .foregroundStyle(.red)
                                                }
                                            )
                                    case .empty:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.gray.opacity(0.3))
                                            .frame(width: 300, height: 200)
                                            .overlay(
                                                VStack {
                                                    ProgressView()
                                                    Text("Lade Bild...")
                                                        .font(.caption)
                                                        .foregroundStyle(.gray)
                                                }
                                            )
                                    @unknown default:
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(.gray)
                                            .frame(width: 300, height: 200)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        // Room Info
                        VStack(alignment: .leading, spacing: 8) {
                            Text(room.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("in \(hotelName)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Text(room.price.formatted + " pro Nacht")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundStyle(.blue)
                        }
                        
                        Divider()
                        
                        // Occupancy
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(.blue)
                            Text("Max. \(room.maxOccupancy) Personen")
                                .font(.subheadline)
                        }
                        
                        Divider()
                        
                        // Amenities
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Zimmerausstattung")
                                .font(.headline)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 12) {
                                ForEach(room.amenities, id: \.self) { amenity in
                                    HStack {
                                        Image(systemName: amenityIcon(for: amenity))
                                            .font(.caption)
                                            .foregroundStyle(.green)
                                        Text(amenity)
                                            .font(.callout)
                                    }
                                    .padding(12)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(8)
                                }
                            }
                        }
                        
                        // Availability Status
                        HStack {
                            Image(systemName: room.available ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(room.available ? .green : .red)
                            Text(room.available ? "Verfügbar" : "Nicht verfügbar")
                                .font(.subheadline)
                                .foregroundStyle(room.available ? .green : .red)
                        }
                        
                        // Add to Trip Button
                        if room.available {
                            Button(action: {
                                showTravelOptions = true
                            }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("Hotel zur Reise hinzufügen")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Zimmer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showTravelOptions) {
            TravelOptionsSheet(room: room, hotel: hotel, checkInDate: checkInDate, checkOutDate: checkOutDate)
        }
    }
    
    private func amenityIcon(for amenity: String) -> String {
        switch amenity.lowercased() {
        case let s where s.contains("bett"): return "bed.double.fill"
        case let s where s.contains("bad"): return "bathtub.fill"
        case let s where s.contains("tv"): return "tv.fill"
        case let s where s.contains("wifi"): return "wifi"
        case let s where s.contains("balkon"): return "building.2.fill"
        case let s where s.contains("minibar"): return "refrigerator.fill"
        case let s where s.contains("küche"): return "oven.fill"
        case let s where s.contains("wohnzimmer"): return "sofa.fill"
        default: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Travel Options Sheet
struct TravelOptionsSheet: View {
    let room: RoomType?
    let hotel: Hotel?
    let destination: String?
    let checkInDate: Date?
    let checkOutDate: Date?
    
    // Optional callbacks for ExploreView integration
    let onComplete: ((String) -> Void)?
    let onNeedFlightSearch: ((String) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var env
    @State private var showFlightSearch = false
    @State private var showMapView = false
    @State private var selectedTransport: TransportType?
    
    // Convenience init for HotelSearchView usage
    init(room: RoomType, hotel: Hotel, checkInDate: Date? = nil, checkOutDate: Date? = nil) {
        self.room = room
        self.hotel = hotel
        self.destination = nil
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.onComplete = nil
        self.onNeedFlightSearch = nil
    }
    
    // New init for ExploreView usage
    init(destination: String, checkInDate: Date? = nil, checkOutDate: Date? = nil, onComplete: @escaping (String) -> Void, onNeedFlightSearch: @escaping (String) -> Void) {
        self.room = nil
        self.hotel = nil
        self.destination = destination
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.onComplete = onComplete
        self.onNeedFlightSearch = onNeedFlightSearch
    }
    
    enum TransportType {
        case flight, car, none
    }
    
    // Extract city from hotel address for destination
    var hotelCity: String {
        return hotel?.address.city ?? destination ?? "Unbekannt"
    }
    
    var hotelName: String {
        return hotel?.name ?? "Reiseziel"
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "location.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text("Wie möchten Sie anreisen?")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: 8) {
                        if let room = room {
                            Text("\(room.name)")
                                .font(.headline)
                        }
                        Text("in \(hotelName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Travel Options
                VStack(spacing: 16) {
                    // Flight Option
                    Button(action: {
                        if selectedTransport == .flight {
                            // Flight already selected - this means user came back from FlightSearchSheet
                            // Don't save again, just acknowledge the selection
                            print("✈️ Flight already selected, no need to save again")
                            if let onComplete = onComplete {
                                dismiss()
                                onComplete(hotelCity)
                            } else {
                                dismiss() // Close without saving (FlightSearchSheet already saved)
                            }
                        } else {
                            selectedTransport = .flight
                            if let onNeedFlightSearch = onNeedFlightSearch {
                                dismiss()
                                onNeedFlightSearch(hotelCity)
                            } else {
                                showFlightSearch = true
                            }
                        }
                    }) {
                        TravelOptionCard(
                            title: selectedTransport == .flight ? "✈️ Flugreise speichern" : "Mit dem Flugzeug",
                            subtitle: selectedTransport == .flight ? "Flug bereits gewählt" : "Schnell und bequem",
                            icon: "airplane",
                            color: selectedTransport == .flight ? .green : .blue
                        )
                    }
                    
                    // Car Option  
                    Button(action: {
                        if selectedTransport == .car {
                            // Car already selected - this means user came back from CarRouteSheet
                            // Don't save again, just acknowledge the selection
                            print("🚗 Car already selected, no need to save again")
                            if let onComplete = onComplete {
                                dismiss()
                                onComplete(hotelCity)
                            } else {
                                dismiss() // Close without saving (CarRouteSheet already saved)
                            }
                        } else {
                            selectedTransport = .car
                            if hotel != nil {
                                showMapView = true
                            } else {
                                // For ExploreView - immediately complete (no duplicate save)
                                if let onComplete = onComplete {
                                    dismiss()
                                    onComplete(hotelCity)
                                } else {
                                    // Hotel mode without CarRouteSheet - save once
                                    if let room = room, let hotel = hotel {
                                        saveTrip(withTransport: true, transportType: .car)
                                    }
                                }
                            }
                        }
                    }) {
                        TravelOptionCard(
                            title: selectedTransport == .car ? "🚗 Roadtrip speichern" : "Mit dem Auto",
                            subtitle: selectedTransport == .car ? "Route bereits gewählt" : "Flexibel und unabhängig",
                            icon: "car.fill",
                            color: selectedTransport == .car ? .green : .blue
                        )
                    }
                    
                    // No Transport Option
                    Button(action: {
                        if let onComplete = onComplete {
                            dismiss()
                            onComplete(hotelCity)
                        } else if let room = room, let hotel = hotel {
                            saveTrip(withTransport: false, transportType: .none)
                        }
                    }) {
                        TravelOptionCard(
                            title: "Ohne Anreise",
                            subtitle: "Nur Hotel zur Reise hinzufügen",
                            icon: "bed.double.fill",
                            color: .orange
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reise planen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showFlightSearch) {
            FlightSearchSheet(
                destination: hotelCity, 
                room: room, 
                hotel: hotel, 
                checkInDate: checkInDate ?? Date().addingTimeInterval(86400 * 7), // Use real dates
                checkOutDate: checkOutDate ?? Date().addingTimeInterval(86400 * 10) // Use real dates
            )
        }
        .sheet(isPresented: $showMapView) {
            if let hotel = hotel {
                CarRouteSheet(hotel: hotel, room: room, checkInDate: checkInDate ?? Date().addingTimeInterval(86400 * 7), checkOutDate: checkOutDate ?? Date().addingTimeInterval(86400 * 10))
            }
        }
    }
    
    private func saveTrip(withTransport: Bool, transportType: TransportType = .none) {
        guard let room = room, let hotel = hotel else {
            print("❌ Cannot save trip: missing room or hotel data")
            return
        }
        
        let tripTitle = switch transportType {
        case .flight: "Flugreise nach \(hotelCity)"
        case .car: "Roadtrip nach \(hotelCity)"
        case .none: "Reise nach \(hotelCity)"
        }
        print("💾 Saving trip: \(tripTitle)")
        
        Task {
            do {
                // Create hotel booking with real dates
                let nights = Calendar.current.dateComponents([.day], from: checkInDate ?? Date().addingTimeInterval(86400 * 7), to: checkOutDate ?? Date().addingTimeInterval(86400 * 10)).day ?? 3
                let hotelBooking = HotelBooking(
                    id: UUID(),
                    hotel: hotel,
                    checkInDate: checkInDate ?? Date().addingTimeInterval(86400 * 7),
                    checkOutDate: checkOutDate ?? Date().addingTimeInterval(86400 * 10),
                    roomType: room,
                    numberOfRooms: 1,
                    totalPrice: Price(amount: room.price.amount * Double(nights), currency: "EUR"),
                    confirmationNumber: "HTL-\(UUID().uuidString.prefix(8))",
                    status: .pending
                )
                
                // Create trip with hotel image and real dates
                let trip = Trip(
                    title: tripTitle,
                    destination: hotelCity,
                    startDate: checkInDate ?? Date().addingTimeInterval(86400 * 7),
                    endDate: checkOutDate ?? Date().addingTimeInterval(86400 * 10),
                    imageName: hotel.images.first, // Use hotel's first image
                    hotelBookings: [hotelBooking],
                    destinationCoordinates: hotel.coordinates
                )
                
                // Save to repository
                try await env.tripRepository.add(trip)
                print("✅ Trip saved successfully: \(trip.title)")
                
                await MainActor.run {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        env.selectedTab = 0 // Switch to Trips tab
                    }
                }
            } catch {
                print("❌ Error saving trip: \(error)")
            }
        }
    }
}

// MARK: - Travel Option Card
struct TravelOptionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}


// MARK: - Flight Search Sheet
struct FlightSearchSheet: View {
    let destination: String
    let room: RoomType?
    let hotel: Hotel?
    let checkInDate: Date
    let checkOutDate: Date
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var env
    @State private var selectedFlight: Flight?
    @State private var availableFlights: [Flight] = []
    @State private var isLoadingFlights = false
    @State private var flightSearchError: String?
    @State private var departureDate: Date
    @State private var returnDate: Date
    @State private var isOneWay = false
    
    init(destination: String = "Paris", room: RoomType? = nil, hotel: Hotel? = nil, checkInDate: Date = Date().addingTimeInterval(86400 * 7), checkOutDate: Date = Date().addingTimeInterval(86400 * 10)) {
        self.destination = destination
        self.room = room
        self.hotel = hotel
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self._departureDate = State(initialValue: checkInDate)
        self._returnDate = State(initialValue: checkOutDate)
    }
    
    var tripDurationText: String {
        if isOneWay {
            return "Nur Hinflug"
        }
        let days = Calendar.current.dateComponents([.day], from: departureDate, to: returnDate).day ?? 0
        return days == 1 ? "1 Tag" : "\(days) Tage"
    }
    
    var isValidForSearch: Bool {
        !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        departureDate > Date() &&
        (isOneWay || returnDate >= departureDate || Calendar.current.isDate(returnDate, inSameDayAs: departureDate))
    }
    
    private func searchFlights() {
        guard !isLoadingFlights else { return }
        
        isLoadingFlights = true
        flightSearchError = nil
        
        Task {
            do {
                print("🛫 Starting real API flight search: Berlin → \(destination)")
                
                let searchParameters = FlightSearchParameters(
                    origin: "Berlin", // User's home city - FIXED: was hardcoded to Frankfurt
                    destination: destination,
                    departureDate: departureDate,
                    returnDate: isOneWay ? nil : returnDate,
                    numberOfAdults: 2,
                    numberOfChildren: 0,
                    numberOfInfants: 0,
                    cabinClass: .economy,
                    maxPrice: nil,
                    directFlightsOnly: false
                )
                
                let flights = try await env.flightSearchService.searchFlights(parameters: searchParameters)
                
                await MainActor.run {
                    self.availableFlights = flights
                    self.isLoadingFlights = false
                    print("✅ Got \(flights.count) real flights from API")
                }
            } catch {
                await MainActor.run {
                    self.isLoadingFlights = false
                    self.flightSearchError = "Fehler beim Laden der Flüge: \(error.localizedDescription)"
                    print("❌ Flight API failed: \(error)")
                    
                    // Don't show any flights on error - user should see the error message
                    self.availableFlights = []
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Modern Flight Search Form
                    VStack(spacing: 20) {
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "airplane")
                                .font(.system(size: 32))
                                .foregroundStyle(.blue)
                            Text("Flug nach \(destination)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("Finden Sie den perfekten Flug für Ihre Reise")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top)
                        
                        // Flight Search Cards
                        VStack(spacing: 16) {
                            // Origin & Destination Card
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "airplane.departure")
                                        .foregroundStyle(.blue)
                                    Text("Flugroute")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                HStack(spacing: 12) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Von")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text("Berlin (BER)")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.quaternary)
                                            .cornerRadius(12)
                                    }
                                    
                                    Image(systemName: "arrow.right")
                                        .font(.title3)
                                        .foregroundStyle(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Nach")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        Text(destination)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .padding(.vertical, 12)
                                            .padding(.horizontal, 16)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(.blue.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(16)
                            
                            // Dates Card
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "calendar")
                                        .foregroundStyle(.green)
                                    Text("Reisedaten")
                                        .font(.headline)
                                    Spacer()
                                    
                                    // One-way toggle
                                    Toggle("Nur Hinflug", isOn: $isOneWay)
                                        .toggleStyle(.switch)
                                        .scaleEffect(0.8)
                                }
                                
                                VStack(spacing: 12) {
                                    // Hinflug DatePicker
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Hinflug")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        DatePicker("", selection: $departureDate, displayedComponents: .date)
                                            .datePickerStyle(.compact)
                                            .padding(.vertical, 8)
                                            .padding(.horizontal, 16)
                                            .background(.green.opacity(0.1))
                                            .cornerRadius(12)
                                    }
                                    
                                    // Rückflug DatePicker (conditional)
                                    if !isOneWay {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Rückflug")
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                            DatePicker("", selection: $returnDate, displayedComponents: .date)
                                                .datePickerStyle(.compact)
                                                .padding(.vertical, 8)
                                                .padding(.horizontal, 16)
                                                .background(.quaternary)
                                                .cornerRadius(12)
                                        }
                                        .transition(.opacity)
                                    }
                                }
                                .animation(.easeInOut(duration: 0.3), value: isOneWay)
                                
                                // Trip Duration
                                HStack {
                                    Image(systemName: "clock")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Text("Reisedauer: \(tripDurationText)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                }
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(16)
                            
                            // Passengers Card
                            VStack(spacing: 16) {
                                HStack {
                                    Image(systemName: "person.2.fill")
                                        .foregroundStyle(.orange)
                                    Text("Reisende")
                                        .font(.headline)
                                    Spacer()
                                }
                                
                                HStack(spacing: 16) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("2 Erwachsene")
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        Text("Economy Class")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("€450-€850")
                                        .font(.headline)
                                        .foregroundStyle(.blue)
                                }
                            }
                            .padding()
                            .background(.regularMaterial)
                            .cornerRadius(16)
                            
                            // Available Flights
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Verfügbare Flüge")
                                        .font(.headline)
                                    Spacer()
                                    if isLoadingFlights {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                    } else {
                                        Text("\(availableFlights.count) Ergebnisse")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                
                                // Show search button if not auto-searched
                                if !isValidForSearch && availableFlights.isEmpty && !isLoadingFlights && flightSearchError == nil {
                                    VStack(spacing: 12) {
                                        Image(systemName: "airplane.circle")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.blue)
                                        Text("Bereit für die Flugsuche")
                                            .font(.headline)
                                        Text("Stellen Sie sicher, dass Ihr Reiseziel und die Daten korrekt sind")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                        
                                        if isValidForSearch {
                                            Button("Jetzt Flüge suchen") {
                                                searchFlights()
                                            }
                                            .buttonStyle(.borderedProminent)
                                        }
                                    }
                                    .padding()
                                }
                                
                                if let error = flightSearchError {
                                    VStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.orange)
                                        Text("Flugsuche nicht verfügbar")
                                            .font(.headline)
                                        Text(error)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                            .multilineTextAlignment(.center)
                                        Button("Erneut versuchen") {
                                            searchFlights()
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                    .padding()
                                    .background(.orange.opacity(0.1))
                                    .cornerRadius(12)
                                } else if isLoadingFlights {
                                    VStack(spacing: 16) {
                                        ProgressView()
                                        Text("Flüge werden gesucht...")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(40)
                                } else if availableFlights.isEmpty {
                                    VStack(spacing: 12) {
                                        Image(systemName: "airplane.circle")
                                            .font(.system(size: 40))
                                            .foregroundStyle(.blue)
                                        Text("Keine Flüge gefunden")
                                            .font(.headline)
                                        Text("Versuchen Sie es mit einem anderen Datum")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                        Button("Erneut suchen") {
                                            searchFlights()
                                        }
                                        .buttonStyle(.borderedProminent)
                                    }
                                    .padding()
                                } else {
                                    ForEach(availableFlights) { flight in
                                        SelectableFlightCard(
                                            flight: flight,
                                            isSelected: selectedFlight?.id == flight.id
                                        )
                                        .onTapGesture {
                                            withAnimation(.easeInOut(duration: 0.2)) {
                                                selectedFlight = flight
                                            }
                                        }
                                    }
                                    
                                    if selectedFlight != nil {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.green)
                                            Text("Flug ausgewählt")
                                                .font(.subheadline)
                                                .foregroundStyle(.green)
                                            Spacer()
                                        }
                                        .padding(.top, 8)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8) // Additional top padding to prevent navigation bar overlap
                    .padding(.bottom, 100) // Space for floating button
                }
            }
            .ignoresSafeArea(.keyboard, edges: []) // Allow keyboard to push content naturally
            .safeAreaInset(edge: .bottom) {
                // Floating Action Button
                Button(action: {
                    saveTripWithFlight()
                }) {
                    HStack {
                        Image(systemName: selectedFlight != nil ? "checkmark.circle.fill" : "plus.circle.fill")
                        Text(selectedFlight != nil ? "Reise mit \(selectedFlight!.airline.name) Flug hinzufügen" : "Bitte Flug auswählen")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedFlight != nil ? .green : .blue.opacity(0.6))
                    .foregroundStyle(.white)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(.regularMaterial)
                .disabled(selectedFlight == nil)
            }
            .dismissKeyboardOnScroll()
            .navigationTitle("Flüge finden")
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .interactiveDismissDisabled(false)
        .onAppear {
            // Only start flight search if destination and dates are valid
            if isValidForSearch {
                searchFlights()
            }
        }
    }
    
    private func saveTripWithFlight() {
        print("✈️ Saving trip with flight to \(destination)")
        
        guard let selectedFlight = selectedFlight else {
            print("❌ No flight selected")
            return
        }
        
        Task {
            do {
                let trip: Trip
                
                // Check if we have hotel data (combined booking) or just flight
                if let room = room, let hotel = hotel {
                    // Combined hotel + flight booking
                    let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 3
                    
                    let hotelBooking = HotelBooking(
                        id: UUID(),
                        hotel: hotel,
                        checkInDate: checkInDate,
                        checkOutDate: checkOutDate,
                        roomType: room,
                        numberOfRooms: 1,
                        totalPrice: Price(amount: room.price.amount * Double(nights), currency: "EUR"),
                        confirmationNumber: "HTL-\(UUID().uuidString.prefix(8))",
                        status: .pending
                    )
                    
                    let flightBooking = FlightBooking(
                        id: UUID(),
                        outboundFlight: selectedFlight,
                        returnFlight: nil,
                        passengers: [
                            Passenger(
                                id: UUID(),
                                firstName: "Max",
                                lastName: "Mustermann",
                                dateOfBirth: Date(),
                                passportNumber: nil,
                                type: .adult
                            )
                        ],
                        totalPrice: selectedFlight.price,
                        bookingReference: "FLT-\(UUID().uuidString.prefix(8))",
                        status: .pending
                    )
                    
                    trip = Trip(
                        title: "Reise nach \(destination) mit \(selectedFlight.airline.name)",
                        destination: destination,
                        startDate: checkInDate,
                        endDate: checkOutDate,
                        imageName: hotel.images.first,
                        hotelBookings: [hotelBooking],
                        flightBookings: [flightBooking],
                        destinationCoordinates: hotel.coordinates
                    )
                } else {
                    // Flight-only booking
                    let flightBooking = FlightBooking(
                        id: UUID(),
                        outboundFlight: selectedFlight,
                        returnFlight: nil,
                        passengers: [
                            Passenger(
                                id: UUID(),
                                firstName: "Max",
                                lastName: "Mustermann",
                                dateOfBirth: Date(),
                                passportNumber: nil,
                                type: .adult
                            )
                        ],
                        totalPrice: selectedFlight.price,
                        bookingReference: "FLT-\(UUID().uuidString.prefix(8))",
                        status: .pending
                    )
                    
                    // Use flight destination coordinates
                    let destinationCoords = Coordinates(
                        latitude: selectedFlight.arrival.airport.coordinates.latitude,
                        longitude: selectedFlight.arrival.airport.coordinates.longitude
                    )
                    
                    trip = Trip(
                        title: "Flugreise nach \(destination) mit \(selectedFlight.airline.name)",
                        destination: destination,
                        startDate: selectedFlight.departure.dateTime,
                        endDate: selectedFlight.arrival.dateTime,
                        imageName: "https://images.unsplash.com/photo-1436491865332-7a61a109cc05?w=400",
                        hotelBookings: [],
                        flightBookings: [flightBooking],
                        destinationCoordinates: destinationCoords
                    )
                }
                
                try await env.tripRepository.add(trip)
                print("✅ Trip saved successfully: \(trip.title)")
                print("✈️ Selected flight: \(selectedFlight.airline.name) \(selectedFlight.flightNumber)")
                
                await MainActor.run {
                    // Dismiss first, then navigate to avoid conflicts
                    dismiss()
                    // Small delay to ensure dismiss completes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        env.selectedTab = 0 // Switch to Trips tab
                    }
                }
            } catch {
                print("❌ Error saving trip: \(error)")
            }
        }
    }
}

// MARK: - Car Route Sheet
struct CarRouteSheet: View {
    let hotel: Hotel
    let room: RoomType?
    let checkInDate: Date
    let checkOutDate: Date
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appEnvironment) private var env
    
    var hotelName: String {
        return hotel.name
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "car.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(.green)
                    
                    Text("Route zu \(hotelName)")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                
                // Route Options
                VStack(spacing: 16) {
                    Button("Route in Apple Karten öffnen") {
                        openInAppleMaps()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Rastpausen anzeigen") {
                        showRestStopsAndOvernight()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Übernachtungsmöglichkeiten") {
                        showOvernightOptions()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Auto-Route")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Zurück") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Reise hinzufügen") {
                        saveTripWithCar()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
    
    private func openInAppleMaps() {
        let latitude = hotel.coordinates.latitude
        let longitude = hotel.coordinates.longitude
        
        // Check if trip is longer than 10 hours (600km at 60km/h average)
        let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
        
        dismiss()
    }
    
    private func showRestStopsAndOvernight() {
        // Create URL for Apple Maps with waypoints for rest stops
        let latitude = hotel.coordinates.latitude
        let longitude = hotel.coordinates.longitude
        
        // This could be enhanced to calculate actual distance and suggest stops
        let urlString = "http://maps.apple.com/?daddr=\(latitude),\(longitude)&dirflg=d&t=m"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
        
        // Show alert about rest stops
        print("💡 Für Reisen über 10 Stunden empfehlen wir Rastpausen alle 2 Stunden")
    }
    
    private func showOvernightOptions() {
        // This could search for hotels along the route
        // For now, just show info
        print("🏨 Übernachtungsmöglichkeiten für längere Reisen werden geprüft...")
        
        // Could integrate with hotel search for cities along the route
        let latitude = hotel.coordinates.latitude
        let longitude = hotel.coordinates.longitude
        
        // Open maps to explore area around the destination
        let urlString = "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=hotels&t=m"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    private func saveTripWithCar() {
        print("🚗 Saving trip with car route to \(hotelName)")
        
        guard let room = room else {
            print("❌ Missing room data")
            dismiss()
            return
        }
        
        Task {
            do {
                // Create hotel booking with real dates
                let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 3
                let hotelBooking = HotelBooking(
                    id: UUID(),
                    hotel: hotel,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    roomType: room,
                    numberOfRooms: 1,
                    totalPrice: Price(amount: room.price.amount * Double(nights), currency: "EUR"),
                    confirmationNumber: "HTL-\(UUID().uuidString.prefix(8))",
                    status: .pending
                )
                
                // Create trip with car route and hotel image using real dates
                let trip = Trip(
                    title: "Roadtrip nach \(hotel.address.city)",
                    destination: hotel.address.city,
                    startDate: checkInDate,
                    endDate: checkOutDate,
                    imageName: hotel.images.first, // Use hotel's first image
                    hotelBookings: [hotelBooking],
                    destinationCoordinates: hotel.coordinates
                )
                
                try await env.tripRepository.add(trip)
                print("✅ Car trip saved successfully: \(trip.title)")
                
                await MainActor.run {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        env.selectedTab = 0 // Switch to Trips tab
                    }
                }
            } catch {
                print("❌ Error saving car trip: \(error)")
            }
        }
    }
}

// MARK: - Mock Flight Result Card
struct MockFlightResultCard: View {
    let airline: String
    let price: String
    let duration: String
    let stops: Int
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Airline Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(airline)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(duration)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text(price)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text(stops == 0 ? "Direktflug" : "\(stops) Stopp\(stops > 1 ? "s" : "")")
                        .font(.caption)
                        .foregroundStyle(stops == 0 ? .green : .orange)
                }
            }
            
            // Flight Route Visual
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("08:30")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("BER")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(.blue)
                        .frame(width: 6, height: 6)
                    Rectangle()
                        .fill(.blue.opacity(0.3))
                        .frame(height: 2)
                    if stops > 0 {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                        Rectangle()
                            .fill(.blue.opacity(0.3))
                            .frame(height: 2)
                    }
                    Circle()
                        .fill(.blue)
                        .frame(width: 6, height: 6)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(stops > 0 ? "12:15" : "10:45")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text("LHR")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Selectable Flight Card
struct SelectableFlightCard: View {
    let flight: Flight
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Airline Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.airline.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(flight.flightNumber)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Selection Indicator
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.green)
                }
                
                // Price
                VStack(alignment: .trailing, spacing: 4) {
                    Text("€\(Int(flight.price.amount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(isSelected ? .green : .blue)
                    Text("pro Person")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Flight Route Visual
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flight.departure.dateTime.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(flight.departure.airport.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(isSelected ? .green : .blue)
                        .frame(width: 6, height: 6)
                    Rectangle()
                        .fill((isSelected ? Color.green : Color.blue).opacity(0.3))
                        .frame(height: 2)
                    if flight.stops > 0 {
                        Circle()
                            .fill(.orange)
                            .frame(width: 6, height: 6)
                        Rectangle()
                            .fill((isSelected ? Color.green : Color.blue).opacity(0.3))
                            .frame(height: 2)
                    }
                    Circle()
                        .fill(isSelected ? .green : .blue)
                        .frame(width: 6, height: 6)
                }
                .frame(maxWidth: .infinity)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(flight.arrival.dateTime.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(flight.arrival.airport.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Flight Details
            HStack {
                Text(formatDuration(flight.duration))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(flight.stops == 0 ? "Direktflug" : "\(flight.stops) Stopp\(flight.stops > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundStyle(flight.stops == 0 ? .green : .orange)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .stroke(isSelected ? .green : Color.clear, lineWidth: 2)
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration / 3600)
        let minutes = Int((duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
}

// MARK: - Moderne Filter Sheet
struct ModernFiltersSheet: View {
    @Binding var maxPrice: Double
    @Binding var minRating: Double
    @Binding var sortOption: HotelSearchView.SortOption
    @Binding var selectedAccommodationType: AccommodationType
    @Binding var hasWiFi: Bool
    @Binding var hasKitchen: Bool
    @Binding var hasParking: Bool
    @Binding var hasWashingMachine: Bool
    @Binding var isPetFriendly: Bool
    @Binding var hasAirConditioning: Bool
    @Binding var hasPool: Bool
    @Binding var hasGym: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Unterkunftsart Picker
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unterkunftsart")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Unterkunftsart", selection: $selectedAccommodationType) {
                            ForEach(AccommodationType.allCases, id: \.self) { type in
                                Text(type.displayName).tag(type)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Preis & Bewertung
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Preis & Bewertung")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Max. Preis pro Nacht: \(Int(maxPrice))€")
                                .foregroundStyle(.secondary)
                            Slider(value: $maxPrice, in: 20...500, step: 10)
                                .accentColor(.blue)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Min. Bewertung: \(minRating, specifier: "%.1f") Sterne")
                                .foregroundStyle(.secondary)
                            Slider(value: $minRating, in: 1...5, step: 0.5)
                                .accentColor(.blue)
                        }
                    }
                    
                    // Ausstattung & Services
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ausstattung & Services")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            FilterToggle(title: "WLAN", icon: "wifi", isOn: $hasWiFi)
                            FilterToggle(title: "Küche", icon: "oven.fill", isOn: $hasKitchen)
                            FilterToggle(title: "Parkplatz", icon: "car.fill", isOn: $hasParking)
                            FilterToggle(title: "Waschmaschine", icon: "washer.fill", isOn: $hasWashingMachine)
                            FilterToggle(title: "Haustierfreundlich", icon: "pawprint.fill", isOn: $isPetFriendly)
                            FilterToggle(title: "Klimaanlage", icon: "snowflake", isOn: $hasAirConditioning)
                            FilterToggle(title: "Pool", icon: "figure.pool.swim", isOn: $hasPool)
                            FilterToggle(title: "Fitnessstudio", icon: "dumbbell.fill", isOn: $hasGym)
                        }
                    }
                    
                    // Sortierung
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Sortierung")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Picker("Sortierung", selection: $sortOption) {
                            ForEach(HotelSearchView.SortOption.allCases, id: \.self) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
                .padding()
            }
            .navigationTitle("Filter")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Zurücksetzen") {
                        resetFilters()
                    }
                }
            }
        }
    }
    
    private func resetFilters() {
        maxPrice = 500
        minRating = 3.0
        selectedAccommodationType = .all
        hasWiFi = false
        hasKitchen = false
        hasParking = false
        hasWashingMachine = false
        isPetFriendly = false
        hasAirConditioning = false
        hasPool = false
        hasGym = false
        sortOption = .priceAscending
    }
}

struct FilterToggle: View {
    let title: String
    let icon: String
    @Binding var isOn: Bool
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(isOn ? .white : .blue)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isOn ? .white : .primary)
                
                Spacer()
                
                Image(systemName: isOn ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 16))
                    .foregroundStyle(isOn ? .white : .blue)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOn ? .blue : .blue.opacity(0.1))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Accommodations Map View
struct AccommodationsMapView: View {
    let accommodations: [Hotel]
    let destination: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        NavigationStack {
            ZStack {
                Map {
                    ForEach(accommodationsForMap, id: \.id) { accommodation in
                        Annotation(accommodation.name, coordinate: CLLocationCoordinate2D(
                            latitude: accommodation.coordinates.latitude,
                            longitude: accommodation.coordinates.longitude
                        )) {
                            AccommodationMapPin(accommodation: accommodation)
                        }
                    }
                }
                .mapStyle(.standard)
                .onAppear {
                    updateMapRegion()
                }
                
                // Map Controls
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(spacing: 12) {
                            Button(action: updateMapRegion) {
                                Image(systemName: "location.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(.blue)
                                    .background(.regularMaterial, in: Circle())
                            }
                        }
                        .padding(.trailing)
                    }
                    .padding(.bottom)
                }
            }
            .navigationTitle("\(accommodations.count) Unterkünfte in \(destination)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var accommodationsForMap: [Hotel] {
        accommodations
    }
    
    private func updateMapRegion() {
        guard !accommodationsForMap.isEmpty else { return }
        
        let coordinates = accommodationsForMap.compactMap { $0.coordinates }
        let latitudes = coordinates.map { $0.latitude }
        let longitudes = coordinates.map { $0.longitude }
        
        guard let minLat = latitudes.min(),
              let maxLat = latitudes.max(),
              let minLon = longitudes.min(),
              let maxLon = longitudes.max() else { return }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLon = (minLon + maxLon) / 2
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(maxLat - minLat, 0.01) * 1.3,
            longitudeDelta: max(maxLon - minLon, 0.01) * 1.3
        )
        
        withAnimation(.easeInOut(duration: 1)) {
            region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
                span: span
            )
        }
    }
}

struct AccommodationMapPin: View {
    let accommodation: Hotel
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Price Badge
            Text("€\(Int(accommodation.pricePerNight.amount))")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundStyle(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                .onTapGesture {
                    showDetails.toggle()
                }
            
            // Pin
            Image(systemName: "mappin.circle.fill")
                .font(.title)
                .foregroundStyle(.blue)
                .background(.white, in: Circle())
        }
        .sheet(isPresented: $showDetails) {
            AccommodationQuickView(accommodation: accommodation)
        }
    }
}

struct AccommodationQuickView: View {
    let accommodation: Hotel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Image
                    if let imageUrl = accommodation.images.first,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.secondary.opacity(0.3))
                        }
                        .frame(height: 200)
                        .clipped()
                        .cornerRadius(12)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text(accommodation.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        if let rating = accommodation.rating {
                            HStack {
                                ForEach(0..<Int(rating), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .foregroundStyle(.yellow)
                                }
                                Text("\(rating, specifier: "%.1f")")
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)
                        }
                        
                        Text("€\(Int(accommodation.pricePerNight.amount)) pro Nacht")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Unterkunft")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}


#Preview {
    HotelSearchView()
}
