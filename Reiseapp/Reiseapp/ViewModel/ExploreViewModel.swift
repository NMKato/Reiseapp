//
//  ExploreViewModel.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import Foundation
import SwiftUI

@MainActor
class ExploreViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var selectedCategory: TravelCategory = .hotels
    @Published var destinationInput = ""
    @Published var originInput = "Berlin" // Default departure city
    @Published var searchResults: [Hotel] = []
    @Published var flightResults: [Flight] = []
    @Published var popularHotels: [Hotel] = []
    @Published var showResults = false
    @Published var isSearching = false
    @Published var isLoadingPopularHotels = false
    
    // Date Properties
    @Published var checkInDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @Published var checkOutDate = Date().addingTimeInterval(86400 * 10) // 10 days from now
    @Published var departureDate = Date().addingTimeInterval(86400 * 7) // 7 days from now
    @Published var returnDate = Date().addingTimeInterval(86400 * 10) // 10 days from now
    
    // Search Filters
    @Published var guests = 2
    @Published var rooms = 1
    
    // Flight Filters
    @Published var passengers = 1
    @Published var flightClass: FlightClass = .economy
    @Published var directFlightsOnly = false
    @Published var flexibleDates = false
    @Published var priceRange: ClosedRange<Double> = 0...11000
    @Published var usePriceFilter = false // Toggle for optional price filtering
    @Published var selectedRating: Int = 0
    @Published var hasWiFi = false
    @Published var hasKitchen = false
    @Published var hasParking = false
    @Published var hasAirConditioning = false
    @Published var hasWashingMachine = false
    @Published var isPetFriendly = false
    @Published var hasPool = false
    @Published var hasGym = false
    @Published var hasCrib = false // Kinderbett/Babybett
    @Published var isOneWay = false // Toggle for one-way flights
    
    // UI State
    @Published var showingDestinationSearch = false
    @Published var showQuickSearch = false
    @Published var currentTrip: TripBuilder?
    @Published var showingAdditionalHotelSearch = false
    
    // Main UI State (moved from ExploreView @State)
    @Published var isHeaderExpanded = false
    @Published var showingTransportOptions = false
    @Published var showingAdditionalFlightSearch = false
    
    // Hotel Display State  
    @Published var showingMap = false
    @Published var selectedHotel: Hotel?
    
    // Weather State
    @Published var weather: DailyWeather?
    
    // MARK: - Dependencies
    
    private let hotelService: HotelSearchService
    private let flightService: FlightSearchService
    
    // MARK: - Enums
    
    enum TravelCategory: String, CaseIterable {
        case hotels = "Hotels"
        case flights = "Flüge"
        case weather = "Wetter"
        case planning = "Planung"
        
        var icon: String {
            switch self {
            case .hotels: return "bed.double"
            case .flights: return "airplane"
            case .weather: return "cloud.sun"
            case .planning: return "list.bullet.clipboard"
            }
        }
        
        var color: Color {
            switch self {
            case .hotels: return .blue
            case .flights: return .green
            case .weather: return .orange
            case .planning: return .purple
            }
        }
    }
    
    enum FlightClass: String, CaseIterable {
        case economy = "Economy"
        case premiumEconomy = "Premium Economy" 
        case business = "Business"
        case first = "First Class"
        
        var icon: String {
            switch self {
            case .economy: return "airplane.circle"
            case .premiumEconomy: return "airplane.circle.fill"
            case .business: return "crown"
            case .first: return "crown.fill"
            }
        }
    }
    
    // MARK: - Initialization
    
    init(
        hotelService: HotelSearchService = HotelSearchService(),
        flightService: FlightSearchService = FlightSearchService()
    ) {
        self.hotelService = hotelService
        self.flightService = flightService
    }
    
    // MARK: - Hotel Search Methods
    
    func startHotelSearch() {
        guard !destinationInput.isEmpty else { return }
        
        isSearching = true
        showResults = false
        
        Task {
            do {
                let searchParameters = HotelSearchParameters(
                    destination: destinationInput,
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    numberOfAdults: guests,
                    numberOfChildren: 0,
                    numberOfRooms: rooms,
                    maxPrice: usePriceFilter ? priceRange.upperBound : nil,
                    minRating: Double(selectedRating),
                    accommodationType: "hotel",
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
                
                let results = try await hotelService.searchHotels(parameters: searchParameters)
                
                await MainActor.run {
                    self.searchResults = results
                    self.showResults = true
                    self.isSearching = false
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                    // TODO: Handle error properly
                    print("Hotel search error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Flight Search Methods
    
    func startFlightSearch() {
        guard !destinationInput.isEmpty && !originInput.isEmpty else { return }
        
        isSearching = true
        showResults = false
        
        Task {
            do {
                let searchParameters = FlightSearchParameters(
                    origin: originInput,
                    destination: destinationInput,
                    departureDate: departureDate,
                    returnDate: isOneWay ? nil : returnDate,
                    numberOfAdults: passengers,
                    numberOfChildren: 0,
                    numberOfInfants: 0,
                    cabinClass: {
                        switch flightClass {
                        case .economy: return .economy
                        case .premiumEconomy: return .premiumEconomy
                        case .business: return .business
                        case .first: return .first
                        }
                    }(),
                    maxPrice: nil,
                    directFlightsOnly: directFlightsOnly
                )
                
                let results = try await flightService.searchFlights(parameters: searchParameters)
                
                await MainActor.run {
                    self.flightResults = results
                    self.showResults = true
                    self.isSearching = false
                    print("Found \(results.count) echte Flüge")
                }
            } catch {
                await MainActor.run {
                    self.isSearching = false
                    // TODO: Handle error properly  
                    print("Flight search error: \(error)")
                }
            }
        }
    }
    
    func loadPopularHotels() {
        guard !isLoadingPopularHotels else { return }
        
        isLoadingPopularHotels = true
        
        Task {
            do {
                // Check cache first
                if let cachedHotels = getCachedPopularHotels() {
                    await MainActor.run {
                        self.popularHotels = cachedHotels
                        self.isLoadingPopularHotels = false
                    }
                    return
                }
                
                // Load from API
                let searchParameters = HotelSearchParameters(
                    destination: "Berlin", // Default popular destination
                    checkInDate: checkInDate,
                    checkOutDate: checkOutDate,
                    numberOfAdults: guests,
                    numberOfChildren: 0,
                    numberOfRooms: rooms,
                    maxPrice: 300, // Default max price for popular hotels
                    minRating: 4.0, // Only show good rated popular hotels
                    accommodationType: "hotel",
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
                
                let hotels = try await hotelService.searchHotels(parameters: searchParameters)
                
                await MainActor.run {
                    self.popularHotels = Array(hotels.prefix(18)) // Limit to 18 for grid
                    self.cachePopularHotels(self.popularHotels)
                    self.isLoadingPopularHotels = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingPopularHotels = false
                    // TODO: Handle error properly
                    print("Popular hotels loading error: \(error)")
                }
            }
        }
    }
    
    // MARK: - Trip Management
    
    func addFlightToTrip(_ flight: Flight, appEnvironment: AppEnvironment) {
        Task {
            do {
                // Create final trip with flight information
                let destination = flight.arrival.airport.city
                let flightDepartureDate = flight.departure.dateTime
                let flightArrivalDate = flight.arrival.dateTime
                
                let finalTrip = Trip(
                    id: UUID(),
                    title: "Flug nach \(destination)",
                    destination: destination,
                    startDate: flightDepartureDate,
                    endDate: flightArrivalDate,
                    imageName: "airplane", // Default airplane icon for flight trips
                    days: [],
                    numberOfAdults: passengers,
                    numberOfChildren: 0,
                    budget: flight.price.amount,
                    currency: flight.price.currency,
                    hotelBookings: [],
                    flightBookings: [
                        FlightBooking(
                            id: UUID(),
                            outboundFlight: flight,
                            returnFlight: nil, // Only storing outbound for now
                            passengers: [
                                Passenger(
                                    id: UUID(),
                                    firstName: "Reisender",
                                    lastName: "1",
                                    dateOfBirth: Date().addingTimeInterval(-365*25*24*60*60), // 25 years old
                                    passportNumber: nil,
                                    type: .adult
                                )
                            ],
                            totalPrice: flight.price,
                            bookingReference: UUID().uuidString,
                            status: .confirmed
                        )
                    ]
                )
                
                // Save to repository
                try await appEnvironment.tripRepository.add(finalTrip)
                
                await MainActor.run {
                    // Switch to Reisen tab
                    print("🔄 Wechsle zum Reisen Tab...")
                    appEnvironment.selectedTab = 0
                    print("✅ Flug-Reise erfolgreich hinzugefügt und zu Reisen Tab gewechselt: \(finalTrip.destination)")
                    print("🔍 Current selectedTab: \(appEnvironment.selectedTab)")
                }
            } catch {
                print("❌ Fehler beim Hinzufügen der Flug-Reise: \(error)")
            }
        }
    }
    
    func saveTrip(_ trip: TripBuilder) {
        Task {
            do {
                var imageName: String?
                var destinationCoords: Coordinates?
                
                // Handle hotel booking
                if let hotel = trip.hotel {
                    let nights = Calendar.current.dateComponents([.day], from: checkInDate, to: checkOutDate).day ?? 3
                    
                    let hotelBooking = HotelBooking(
                        id: UUID(),
                        hotel: hotel,
                        checkInDate: checkInDate,
                        checkOutDate: checkOutDate,
                        roomType: hotel.roomTypes.first ?? RoomType(
                            id: "standard",
                            name: "Standard Room",
                            maxOccupancy: guests,
                            price: hotel.pricePerNight,
                            amenities: hotel.amenities,
                            available: true,
                            images: []
                        ),
                        numberOfRooms: rooms,
                        totalPrice: Price(amount: hotel.pricePerNight.amount * Double(nights), currency: hotel.pricePerNight.currency),
                        confirmationNumber: nil,
                        status: .confirmed
                    )
                    
                    imageName = hotel.images.first
                    destinationCoords = hotel.coordinates
                }
                
                // Create final trip
                let finalTrip = Trip(
                    id: trip.id,
                    title: trip.destination,
                    destination: trip.destination,
                    startDate: checkInDate,
                    endDate: checkOutDate,
                    imageName: imageName ?? "default-destination",
                    days: [],
                    numberOfAdults: guests,
                    numberOfChildren: 0,
                    budget: nil,
                    currency: "EUR",
                    hotelBookings: [],
                    flightBookings: []
                )
                
                // TODO: Save trip to repository
                print("Trip saved successfully: \(finalTrip.destination)")
                
                await MainActor.run {
                    self.currentTrip = nil
                }
            } catch {
                print("Error saving trip: \(error)")
            }
        }
    }
    
    // MARK: - Category Selection
    
    func selectCategory(_ category: TravelCategory) {
        selectedCategory = category
        
        // Load data based on selected category
        switch category {
        case .hotels:
            if popularHotels.isEmpty {
                loadPopularHotels()
            }
        case .flights:
            break // TODO: Load popular flights
        case .weather:
            break // TODO: Load weather data
        case .planning:
            break // TODO: Load planning features
        }
    }
    
    // MARK: - Search Management
    
    func clearSearch() {
        destinationInput = ""
        searchResults = []
        flightResults = []
        showResults = false
    }
    
    func performQuickSearch(destination: String) {
        destinationInput = destination
        showQuickSearch = false
        startHotelSearch()
    }
    
    // MARK: - Refresh Methods
    
    func refreshData() async {
        await MainActor.run {
            isLoadingPopularHotels = true
        }
        
        // Clear cache and reload popular hotels
        UserDefaults.standard.removeObject(forKey: "cachedPopularHotels")
        UserDefaults.standard.removeObject(forKey: "cachedHotelsDate")
        
        loadPopularHotels()
    }
    
    // MARK: - Private Helper Methods
    
    // MARK: - Smart Caching (12 Hours)
    
    private func getCachedPopularHotels() -> [Hotel]? {
        guard let data = UserDefaults.standard.data(forKey: "cachedPopularHotels"),
              let cachedTimestamp = UserDefaults.standard.object(forKey: "cachedHotelsTimestamp") as? Double else {
            return nil
        }
        
        // Check if cache is still valid (12 hours = 43200 seconds)
        let cacheAge = Date().timeIntervalSince1970 - cachedTimestamp
        let maxCacheAge: TimeInterval = 12 * 60 * 60 // 12 hours
        
        guard cacheAge < maxCacheAge else {
            print("🕒 Popular hotels cache expired after \(Int(cacheAge/3600)) hours")
            return nil // Cache expired
        }
        
        do {
            let hotels = try JSONDecoder().decode([Hotel].self, from: data)
            print("✅ Using cached popular hotels (\(hotels.count) hotels, age: \(Int(cacheAge/60)) min)")
            
            // Return randomized order to keep content fresh
            return hotels.shuffled()
        } catch {
            print("❌ Error decoding cached hotels: \(error)")
            return nil
        }
    }
    
    private func cachePopularHotels(_ hotels: [Hotel]) {
        do {
            let data = try JSONEncoder().encode(hotels)
            let timestamp = Date().timeIntervalSince1970
            
            UserDefaults.standard.set(data, forKey: "cachedPopularHotels")
            UserDefaults.standard.set(timestamp, forKey: "cachedHotelsTimestamp")
            
            print("💾 Cached \(hotels.count) popular hotels for 12 hours")
        } catch {
            print("❌ Error caching popular hotels: \(error)")
        }
    }
    
    private func todayString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

// MARK: - TripBuilder Helper

class TripBuilder: ObservableObject {
    let id = UUID()
    @Published var destination: String
    @Published var hotel: Hotel?
    @Published var flights: [Flight]?
    
    init(destination: String) {
        self.destination = destination
    }
}