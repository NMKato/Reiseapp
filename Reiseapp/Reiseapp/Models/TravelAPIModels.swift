//
//  TravelAPIModels.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import Foundation

// MARK: - Coordinates
struct Coordinates: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}

// MARK: - Weather Models
struct WeatherForecast: Codable, Hashable {
    let location: String
    let forecasts: [DailyWeather]
    let lastUpdated: Date
}

struct DailyWeather: Codable, Hashable, Identifiable {
    let id = UUID()
    let date: Date
    let temperatureMin: Double
    let temperatureMax: Double
    let temperatureCurrent: Double?
    let condition: WeatherCondition
    let humidity: Int
    let windSpeed: Double
    let precipitation: Double
    let icon: String
    
    var temperatureMinCelsius: String {
        "\(Int(temperatureMin))°C"
    }
    
    var temperatureMaxCelsius: String {
        "\(Int(temperatureMax))°C"
    }
    
    private enum CodingKeys: String, CodingKey {
        case date, temperatureMin, temperatureMax, temperatureCurrent
        case condition, humidity, windSpeed, precipitation, icon
    }
}

enum WeatherCondition: String, Codable {
    case clear = "Clear"
    case clouds = "Clouds"
    case rain = "Rain"
    case snow = "Snow"
    case thunderstorm = "Thunderstorm"
    case drizzle = "Drizzle"
    case mist = "Mist"
    
    var emoji: String {
        switch self {
        case .clear: return "☀️"
        case .clouds: return "☁️"
        case .rain: return "🌧️"
        case .snow: return "❄️"
        case .thunderstorm: return "⛈️"
        case .drizzle: return "🌦️"
        case .mist: return "🌫️"
        }
    }
}

// MARK: - Hotel Models
struct Hotel: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let address: Address
    let rating: Double?
    let pricePerNight: Price
    let amenities: [String]
    let images: [String]
    let description: String?
    let distanceFromCenter: Double?
    let coordinates: Coordinates
    let availability: Bool
    let roomTypes: [RoomType]
    let contact: HotelContact?
}

struct HotelContact: Codable, Hashable {
    let phone: String?
    let email: String?
    let website: String?
}

struct Address: Codable, Hashable {
    let street: String?
    let city: String
    let postalCode: String?
    let country: String
    
    var fullAddress: String {
        [street, city, postalCode, country]
            .compactMap { $0 }
            .joined(separator: ", ")
    }
}

struct RoomType: Codable, Hashable, Identifiable {
    let id: String
    let name: String
    let maxOccupancy: Int
    let price: Price
    let amenities: [String]
    let available: Bool
    let images: [String]
}

struct Price: Codable, Hashable {
    let amount: Double
    let currency: String
    
    var formatted: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount) \(currency)"
    }
}

struct HotelBooking: Codable, Hashable, Identifiable {
    let id: UUID
    let hotel: Hotel
    let checkInDate: Date
    let checkOutDate: Date
    let roomType: RoomType
    let numberOfRooms: Int
    let totalPrice: Price
    let confirmationNumber: String?
    let status: BookingStatus
}

// MARK: - Flight Models
struct Flight: Codable, Hashable, Identifiable {
    let id: String
    let airline: Airline
    let flightNumber: String
    let departure: FlightEndpoint
    let arrival: FlightEndpoint
    let duration: TimeInterval
    let isEstimatedDuration: Bool // true if duration is estimated due to parsing fallback
    let price: Price
    let availableSeats: Int
    let cabinClass: CabinClass
    let stops: Int
    let segments: [FlightSegment]
}

struct Airline: Codable, Hashable {
    let code: String
    let name: String
    let logo: String?
}

struct FlightEndpoint: Codable, Hashable {
    let airport: Airport
    let dateTime: Date
    let terminal: String?
    let gate: String?
}

struct Airport: Codable, Hashable {
    let code: String
    let name: String
    let city: String
    let country: String
    let coordinates: Coordinates
}

struct FlightSegment: Codable, Hashable, Identifiable {
    let id: String
    let departure: FlightEndpoint
    let arrival: FlightEndpoint
    let flightNumber: String
    let duration: TimeInterval
    let aircraft: String?
}

enum CabinClass: String, Codable {
    case economy = "ECONOMY"
    case premiumEconomy = "PREMIUM_ECONOMY"
    case business = "BUSINESS"
    case first = "FIRST"
    
    var displayName: String {
        switch self {
        case .economy: return "Economy"
        case .premiumEconomy: return "Premium Economy"
        case .business: return "Business"
        case .first: return "First Class"
        }
    }
}

struct FlightBooking: Codable, Hashable, Identifiable {
    let id: UUID
    let outboundFlight: Flight
    let returnFlight: Flight?
    let passengers: [Passenger]
    let totalPrice: Price
    let bookingReference: String?
    let status: BookingStatus
}

struct Passenger: Codable, Hashable, Identifiable {
    let id: UUID
    let firstName: String
    let lastName: String
    let dateOfBirth: Date
    let passportNumber: String?
    let type: PassengerType
}

enum PassengerType: String, Codable {
    case adult = "ADULT"
    case child = "CHILD"
    case infant = "INFANT"
}

enum BookingStatus: String, Codable {
    case pending = "PENDING"
    case confirmed = "CONFIRMED"
    case cancelled = "CANCELLED"
    case completed = "COMPLETED"
    
    var displayName: String {
        switch self {
        case .pending: return "Vorgemerkt"
        case .confirmed: return "Bestätigt"
        case .cancelled: return "Storniert"
        case .completed: return "Abgeschlossen"
        }
    }
}

// MARK: - Search Parameters
struct HotelSearchParameters {
    let destination: String
    let checkInDate: Date
    let checkOutDate: Date
    let numberOfAdults: Int
    let numberOfChildren: Int
    let numberOfRooms: Int
    let maxPrice: Double?
    let minRating: Double?
    
    // Moderne Filter Parameter
    let accommodationType: String?
    let hasWiFi: Bool
    let hasKitchen: Bool
    let hasParking: Bool
    let hasWashingMachine: Bool
    let isPetFriendly: Bool
    let hasAirConditioning: Bool
    let hasPool: Bool
    let hasGym: Bool
    let hasCrib: Bool
}

struct FlightSearchParameters {
    let origin: String
    let destination: String
    let departureDate: Date
    let returnDate: Date?
    let numberOfAdults: Int
    let numberOfChildren: Int
    let numberOfInfants: Int
    let cabinClass: CabinClass
    let maxPrice: Double?
    let directFlightsOnly: Bool
}

// MARK: - Accommodation Type
enum AccommodationType: String, CaseIterable {
    case all = "Alle"
    case apartment = "Wohnung"
    case house = "Haus"
    case hotel = "Hotel"
    case room = "Zimmer"
    case cabin = "Hütte"
    
    var displayName: String {
        return self.rawValue
    }
}