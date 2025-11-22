//
//  MockData.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import Foundation

// MARK: - Mock Data for Previews and Testing

struct MockData {
    
    // MARK: - Mock Hotels
    
    static let sampleHotels: [Hotel] = [
        Hotel(
            id: "hotel-1",
            name: "Grand Hotel Berlin",
            address: Address(
                street: "Unter den Linden 77",
                city: "Berlin",
                postalCode: "10117",
                country: "Deutschland"
            ),
            rating: 4.8,
            pricePerNight: Price(amount: 149, currency: "EUR"),
            amenities: ["WLAN", "Fitness", "Restaurant", "Bar", "Parkplatz"],
            images: [
                "https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=400",
                "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400",
                "https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400"
            ],
            description: "Luxuriöses Hotel im Herzen Berlins mit erstklassigem Service und modernen Annehmlichkeiten. Perfekt für Business- und Urlaubsreisen.",
            distanceFromCenter: 0.5,
            coordinates: Coordinates(latitude: 52.5170, longitude: 13.3888),
            availability: true,
            roomTypes: [
                RoomType(
                    id: "standard",
                    name: "Standard Zimmer",
                    maxOccupancy: 2,
                    price: Price(amount: 149, currency: "EUR"),
                    amenities: ["WLAN", "Minibar", "Safe"],
                    available: true,
                    images: ["https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400"]
                )
            ],
            contact: HotelContact(
                phone: "+49 30 2023456",
                email: "info@grandhotelberlin.de",
                website: "www.grandhotelberlin.de"
            )
        ),
        
        Hotel(
            id: "hotel-2",
            name: "Boutique Hotel München",
            address: Address(
                street: "Maximilianstraße 15",
                city: "München",
                postalCode: "80539",
                country: "Deutschland"
            ),
            rating: 4.6,
            pricePerNight: Price(amount: 125, currency: "EUR"),
            amenities: ["WLAN", "Klimaanlage", "Restaurant", "Concierge"],
            images: [
                "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400",
                "https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400"
            ],
            description: "Charmantes Boutique-Hotel in der Münchner Innenstadt mit individuell gestalteten Zimmern und persönlichem Service.",
            distanceFromCenter: 1.2,
            coordinates: Coordinates(latitude: 48.1351, longitude: 11.5820),
            availability: true,
            roomTypes: [
                RoomType(
                    id: "deluxe",
                    name: "Deluxe Zimmer",
                    maxOccupancy: 2,
                    price: Price(amount: 125, currency: "EUR"),
                    amenities: ["WLAN", "Balkon", "Nespresso"],
                    available: true,
                    images: ["https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400"]
                )
            ],
            contact: nil
        ),
        
        Hotel(
            id: "hotel-3",
            name: "Barcelona Beach Resort",
            address: Address(
                street: "Passeig Marítim 32",
                city: "Barcelona",
                postalCode: "08003",
                country: "Spanien"
            ),
            rating: 4.9,
            pricePerNight: Price(amount: 189, currency: "EUR"),
            amenities: ["WLAN", "Pool", "Spa", "Strand", "Restaurant", "Bar"],
            images: [
                "https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400",
                "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400",
                "https://images.unsplash.com/photo-1578898886393-9aa0bfd4d531?w=400"
            ],
            description: "Luxuriöses Strandresort mit direktem Zugang zum Meer, Spa-Bereich und mehreren Restaurants. Perfekt für einen entspannten Urlaub.",
            distanceFromCenter: 3.8,
            coordinates: Coordinates(latitude: 41.3851, longitude: 2.1734),
            availability: true,
            roomTypes: [
                RoomType(
                    id: "ocean-view",
                    name: "Meerblick Suite",
                    maxOccupancy: 4,
                    price: Price(amount: 189, currency: "EUR"),
                    amenities: ["WLAN", "Meerblick", "Balkon", "Minibar"],
                    available: true,
                    images: ["https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=400"]
                )
            ],
            contact: HotelContact(
                phone: "+34 93 225 8000",
                email: "reservas@barcelonabeach.com",
                website: "www.barcelonabeachresort.com"
            )
        ),
        
        Hotel(
            id: "hotel-4",
            name: "Cozy Apartment Paris",
            address: Address(
                street: "Rue de Rivoli 45",
                city: "Paris",
                postalCode: "75001",
                country: "Frankreich"
            ),
            rating: 4.3,
            pricePerNight: Price(amount: 95, currency: "EUR"),
            amenities: ["WLAN", "Küche", "Waschmaschine"],
            images: [
                "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?w=400",
                "https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?w=400"
            ],
            description: "Gemütliches Apartment im Zentrum von Paris, perfekt für Selbstversorger. Nahegelegene Metro-Stationen.",
            distanceFromCenter: 0.8,
            coordinates: Coordinates(latitude: 48.8566, longitude: 2.3522),
            availability: true,
            roomTypes: [
                RoomType(
                    id: "apartment",
                    name: "Studio Apartment",
                    maxOccupancy: 2,
                    price: Price(amount: 95, currency: "EUR"),
                    amenities: ["WLAN", "Küche", "Waschmaschine"],
                    available: true,
                    images: ["https://images.unsplash.com/photo-1560448204-61ef4d3675b7?w=400"]
                )
            ],
            contact: nil
        ),
        
        Hotel(
            id: "hotel-5",
            name: "London City Hotel",
            address: Address(
                street: "Oxford Street 123",
                city: "London",
                postalCode: "W1D 2HX",
                country: "Vereinigtes Königreich"
            ),
            rating: 4.4,
            pricePerNight: Price(amount: 135, currency: "EUR"),
            amenities: ["WLAN", "Gym", "Restaurant", "24h Service"],
            images: [
                "https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400",
                "https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=400"
            ],
            description: "Modernes Hotel im Herzen Londons, nur wenige Minuten von den wichtigsten Sehenswürdigkeiten entfernt.",
            distanceFromCenter: 0.3,
            coordinates: Coordinates(latitude: 51.5074, longitude: -0.1278),
            availability: true,
            roomTypes: [
                RoomType(
                    id: "city-view",
                    name: "City View Room",
                    maxOccupancy: 2,
                    price: Price(amount: 135, currency: "EUR"),
                    amenities: ["WLAN", "Stadtblick", "Safe"],
                    available: true,
                    images: ["https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=400"]
                )
            ],
            contact: HotelContact(
                phone: "+44 20 7123 4567",
                email: "info@londoncityhotel.co.uk",
                website: "www.londoncityhotel.co.uk"
            )
        ),
        
        Hotel(
            id: "hotel-6",
            name: "Amsterdam Canal House",
            address: Address(
                street: "Prinsengracht 263",
                city: "Amsterdam",
                postalCode: "1016 GV",
                country: "Niederlande"
            ),
            rating: 4.7,
            pricePerNight: Price(amount: 110, currency: "EUR"),
            amenities: ["WLAN", "Grachtenblick", "Fahrradverleih", "Frühstück"],
            images: [
                "https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=400",
                "https://images.unsplash.com/photo-1578898886393-9aa0bfd4d531?w=400"
            ],
            description: "Historisches Kanalhaus mit authentischem Charme und modernem Komfort. Perfekt gelegen für Stadtbesichtigungen.",
            distanceFromCenter: 1.5,
            coordinates: Coordinates(latitude: 52.3676, longitude: 4.8797),
            availability: true,
            roomTypes: [
                RoomType(
                    id: "canal-view",
                    name: "Grachten Zimmer",
                    maxOccupancy: 2,
                    price: Price(amount: 110, currency: "EUR"),
                    amenities: ["WLAN", "Grachtenblick", "Minibar"],
                    available: true,
                    images: ["https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=400"]
                )
            ],
            contact: nil
        )
    ]
    
    // MARK: - Mock Flights
    
    static let sampleFlights: [Flight] = [
        Flight(
            id: "flight-1",
            airline: Airline(code: "LH", name: "Lufthansa", logo: nil),
            flightNumber: "LH123",
            departure: FlightEndpoint(
                airport: Airport(
                    code: "BER", 
                    name: "Berlin Brandenburg", 
                    city: "Berlin",
                    country: "Deutschland",
                    coordinates: Coordinates(latitude: 52.3667, longitude: 13.5033)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
                terminal: "1",
                gate: "A12"
            ),
            arrival: FlightEndpoint(
                airport: Airport(
                    code: "BCN", 
                    name: "Barcelona-El Prat", 
                    city: "Barcelona",
                    country: "Spanien",
                    coordinates: Coordinates(latitude: 41.2971, longitude: 2.0785)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 7, to: Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()) ?? Date(),
                terminal: "1",
                gate: "B34"
            ),
            duration: 7200,
            isEstimatedDuration: false,
            price: Price(amount: 89, currency: "EUR"),
            availableSeats: 45,
            cabinClass: .economy,
            stops: 0,
            segments: []
        ),
        
        Flight(
            id: "flight-2",
            airline: Airline(code: "EW", name: "Eurowings", logo: nil),
            flightNumber: "EW456",
            departure: FlightEndpoint(
                airport: Airport(
                    code: "MUC", 
                    name: "München Franz Josef Strauß", 
                    city: "München",
                    country: "Deutschland", 
                    coordinates: Coordinates(latitude: 48.3538, longitude: 11.7861)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 8, to: Date()) ?? Date(),
                terminal: "2",
                gate: "G15"
            ),
            arrival: FlightEndpoint(
                airport: Airport(
                    code: "CDG", 
                    name: "Charles de Gaulle", 
                    city: "Paris",
                    country: "Frankreich",
                    coordinates: Coordinates(latitude: 49.0097, longitude: 2.5479)
                ),
                dateTime: Calendar.current.date(byAdding: .day, value: 8, to: Calendar.current.date(byAdding: .minute, value: 90, to: Date()) ?? Date()) ?? Date(),
                terminal: "2E",
                gate: "L42"
            ),
            duration: 5400,
            isEstimatedDuration: false,
            price: Price(amount: 120, currency: "EUR"),
            availableSeats: 23,
            cabinClass: .economy,
            stops: 0,
            segments: []
        )
    ]
    
    // MARK: - Mock Search Parameters
    
    static let defaultSearchParameters = HotelSearchParameters(
        destination: "Berlin",
        checkInDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        checkOutDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
        numberOfAdults: 2,
        numberOfChildren: 0,
        numberOfRooms: 1,
        maxPrice: 500,
        minRating: 0,
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
    
    // MARK: - Mock Trip
    
    static let sampleTrip = Trip(
        id: UUID(),
        title: "Barcelona Urlaub",
        destination: "Barcelona",
        startDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()) ?? Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 17, to: Date()) ?? Date(),
        imageName: "https://images.unsplash.com/photo-1539037116277-4db20889f2d4?w=400",
        days: [],
        numberOfAdults: 2,
        numberOfChildren: 0,
        budget: 2000,
        currency: "EUR",
        hotelBookings: [],
        flightBookings: []
    )
    
    // MARK: - Mock Weather Data
    
    static let sampleWeatherData = [
        DailyWeather(
            date: Date(),
            temperatureMin: 18,
            temperatureMax: 25,
            temperatureCurrent: 22,
            condition: .clear,
            humidity: 65,
            windSpeed: 12,
            precipitation: 0,
            icon: "sun.max"
        ),
        DailyWeather(
            date: Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date(),
            temperatureMin: 16,
            temperatureMax: 23,
            temperatureCurrent: 20,
            condition: .clouds,
            humidity: 70,
            windSpeed: 15,
            precipitation: 10,
            icon: "cloud.sun"
        )
    ]
    
    // MARK: - Helper Methods
    
    /// Returns a subset of sample hotels for testing different scenarios
    static func hotels(count: Int = 6) -> [Hotel] {
        return Array(sampleHotels.prefix(count))
    }
    
    /// Returns hotels filtered by city
    static func hotels(for city: String) -> [Hotel] {
        return sampleHotels.filter { $0.address.city.lowercased().contains(city.lowercased()) }
    }
    
    /// Returns a random selection of hotels
    static func randomHotels(count: Int = 3) -> [Hotel] {
        return Array(sampleHotels.shuffled().prefix(count))
    }
    
    /// Creates mock search parameters for a specific destination
    static func searchParameters(for destination: String) -> HotelSearchParameters {
        return HotelSearchParameters(
            destination: destination,
            checkInDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
            checkOutDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
            numberOfAdults: 2,
            numberOfChildren: 0,
            numberOfRooms: 1,
            maxPrice: 500,
            minRating: 0,
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
    }
}

// MARK: - ⚠️ DEPRECATED: Use PreviewMockData for SwiftUI Previews!
// This MockData should only be used for unit testing and development
// For SwiftUI Previews, use PreviewMockData instead to keep preview data separate from test data
