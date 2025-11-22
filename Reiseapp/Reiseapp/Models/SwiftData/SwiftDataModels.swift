//
//  SwiftDataModels.swift
//  Reiseapp
//
//  Created by Claude on 11.09.25.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - SwiftData Trip Model
@Model
final class PersistentTrip {
    var id: UUID
    var title: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var imageName: String?
    var numberOfAdults: Int
    var numberOfChildren: Int
    var budget: Double?
    var currency: String
    
    // Relationships
    @Relationship(deleteRule: .cascade) var days: [PersistentDayPlan] = []
    @Relationship(deleteRule: .cascade) var hotelBookings: [PersistentHotelBooking] = []
    @Relationship(deleteRule: .cascade) var flightBookings: [PersistentFlightBooking] = []
    @Relationship(deleteRule: .cascade) var weatherForecast: PersistentWeatherForecast?
    @Relationship(deleteRule: .cascade) var destinationCoordinates: PersistentCoordinates?
    
    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        imageName: String? = nil,
        numberOfAdults: Int = 1,
        numberOfChildren: Int = 0,
        budget: Double? = nil,
        currency: String = "EUR"
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.imageName = imageName
        self.numberOfAdults = numberOfAdults
        self.numberOfChildren = numberOfChildren
        self.budget = budget
        self.currency = currency
    }
}

// MARK: - SwiftData Coordinates Model
@Model
final class PersistentCoordinates {
    var latitude: Double
    var longitude: Double
    
    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

// MARK: - SwiftData Weather Models
@Model
final class PersistentWeatherForecast {
    var location: String
    var lastUpdated: Date
    
    @Relationship(deleteRule: .cascade) var forecasts: [PersistentDailyWeather] = []
    
    init(location: String, lastUpdated: Date) {
        self.location = location
        self.lastUpdated = lastUpdated
    }
}

@Model
final class PersistentDailyWeather {
    var id: UUID
    var date: Date
    var temperatureMin: Double
    var temperatureMax: Double
    var temperatureCurrent: Double?
    var conditionRawValue: String
    var humidity: Int
    var windSpeed: Double
    var precipitation: Double
    var icon: String
    
    init(
        id: UUID = UUID(),
        date: Date,
        temperatureMin: Double,
        temperatureMax: Double,
        temperatureCurrent: Double? = nil,
        conditionRawValue: String,
        humidity: Int,
        windSpeed: Double,
        precipitation: Double,
        icon: String
    ) {
        self.id = id
        self.date = date
        self.temperatureMin = temperatureMin
        self.temperatureMax = temperatureMax
        self.temperatureCurrent = temperatureCurrent
        self.conditionRawValue = conditionRawValue
        self.humidity = humidity
        self.windSpeed = windSpeed
        self.precipitation = precipitation
        self.icon = icon
    }
}

// MARK: - SwiftData Hotel Models
@Model
final class PersistentHotelBooking {
    var id: UUID
    var checkInDate: Date
    var checkOutDate: Date
    var numberOfRooms: Int
    var confirmationNumber: String?
    var statusRawValue: String
    
    @Relationship(deleteRule: .cascade) var hotel: PersistentHotel?
    @Relationship(deleteRule: .cascade) var roomType: PersistentRoomType?
    @Relationship(deleteRule: .cascade) var totalPrice: PersistentPrice?
    
    init(
        id: UUID = UUID(),
        checkInDate: Date,
        checkOutDate: Date,
        numberOfRooms: Int,
        confirmationNumber: String? = nil,
        statusRawValue: String
    ) {
        self.id = id
        self.checkInDate = checkInDate
        self.checkOutDate = checkOutDate
        self.numberOfRooms = numberOfRooms
        self.confirmationNumber = confirmationNumber
        self.statusRawValue = statusRawValue
    }
}

@Model
final class PersistentHotel {
    var id: String
    var name: String
    var rating: Double?
    var amenities: [String]
    var images: [String]
    var hotelDescription: String?
    var distanceFromCenter: Double?
    var availability: Bool
    
    @Relationship(deleteRule: .cascade) var address: PersistentAddress?
    @Relationship(deleteRule: .cascade) var pricePerNight: PersistentPrice?
    @Relationship(deleteRule: .cascade) var coordinates: PersistentCoordinates?
    @Relationship(deleteRule: .cascade) var contact: PersistentHotelContact?
    @Relationship(deleteRule: .cascade) var roomTypes: [PersistentRoomType] = []
    
    init(
        id: String,
        name: String,
        rating: Double? = nil,
        amenities: [String] = [],
        images: [String] = [],
        hotelDescription: String? = nil,
        distanceFromCenter: Double? = nil,
        availability: Bool = true
    ) {
        self.id = id
        self.name = name
        self.rating = rating
        self.amenities = amenities
        self.images = images
        self.hotelDescription = hotelDescription
        self.distanceFromCenter = distanceFromCenter
        self.availability = availability
    }
}

@Model
final class PersistentAddress {
    var street: String?
    var city: String
    var postalCode: String?
    var country: String
    
    init(street: String?, city: String, postalCode: String?, country: String) {
        self.street = street
        self.city = city
        self.postalCode = postalCode
        self.country = country
    }
}

@Model
final class PersistentHotelContact {
    var phone: String?
    var email: String?
    var website: String?
    
    init(phone: String?, email: String?, website: String?) {
        self.phone = phone
        self.email = email
        self.website = website
    }
}

@Model
final class PersistentRoomType {
    var id: String
    var name: String
    var maxOccupancy: Int
    var amenities: [String]
    var available: Bool
    var images: [String]
    
    @Relationship(deleteRule: .cascade) var price: PersistentPrice?
    
    init(
        id: String,
        name: String,
        maxOccupancy: Int,
        amenities: [String] = [],
        available: Bool = true,
        images: [String] = []
    ) {
        self.id = id
        self.name = name
        self.maxOccupancy = maxOccupancy
        self.amenities = amenities
        self.available = available
        self.images = images
    }
}

@Model
final class PersistentPrice {
    var amount: Double
    var currency: String
    
    init(amount: Double, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}

// MARK: - SwiftData Flight Models
@Model
final class PersistentFlightBooking {
    var id: UUID
    var bookingReference: String?
    var statusRawValue: String
    
    @Relationship(deleteRule: .cascade) var outboundFlight: PersistentFlight?
    @Relationship(deleteRule: .cascade) var returnFlight: PersistentFlight?
    @Relationship(deleteRule: .cascade) var passengers: [PersistentPassenger] = []
    @Relationship(deleteRule: .cascade) var totalPrice: PersistentPrice?
    
    init(
        id: UUID = UUID(),
        bookingReference: String? = nil,
        statusRawValue: String
    ) {
        self.id = id
        self.bookingReference = bookingReference
        self.statusRawValue = statusRawValue
    }
}

@Model
final class PersistentFlight {
    var id: String
    var flightNumber: String
    var duration: TimeInterval
    var availableSeats: Int
    var cabinClassRawValue: String
    var stops: Int
    
    @Relationship(deleteRule: .cascade) var airline: PersistentAirline?
    @Relationship(deleteRule: .cascade) var departure: PersistentFlightEndpoint?
    @Relationship(deleteRule: .cascade) var arrival: PersistentFlightEndpoint?
    @Relationship(deleteRule: .cascade) var price: PersistentPrice?
    @Relationship(deleteRule: .cascade) var segments: [PersistentFlightSegment] = []
    
    init(
        id: String,
        flightNumber: String,
        duration: TimeInterval,
        availableSeats: Int,
        cabinClassRawValue: String,
        stops: Int
    ) {
        self.id = id
        self.flightNumber = flightNumber
        self.duration = duration
        self.availableSeats = availableSeats
        self.cabinClassRawValue = cabinClassRawValue
        self.stops = stops
    }
}

@Model
final class PersistentAirline {
    var code: String
    var name: String
    var logo: String?
    
    init(code: String, name: String, logo: String? = nil) {
        self.code = code
        self.name = name
        self.logo = logo
    }
}

@Model
final class PersistentFlightEndpoint {
    var dateTime: Date
    var terminal: String?
    var gate: String?
    
    @Relationship(deleteRule: .cascade) var airport: PersistentAirport?
    
    init(dateTime: Date, terminal: String? = nil, gate: String? = nil) {
        self.dateTime = dateTime
        self.terminal = terminal
        self.gate = gate
    }
}

@Model
final class PersistentAirport {
    var code: String
    var name: String
    var city: String
    var country: String
    
    @Relationship(deleteRule: .cascade) var coordinates: PersistentCoordinates?
    
    init(code: String, name: String, city: String, country: String) {
        self.code = code
        self.name = name
        self.city = city
        self.country = country
    }
}

@Model
final class PersistentFlightSegment {
    var id: String
    var flightNumber: String
    var duration: TimeInterval
    var aircraft: String?
    
    @Relationship(deleteRule: .cascade) var departure: PersistentFlightEndpoint?
    @Relationship(deleteRule: .cascade) var arrival: PersistentFlightEndpoint?
    
    init(
        id: String,
        flightNumber: String,
        duration: TimeInterval,
        aircraft: String? = nil
    ) {
        self.id = id
        self.flightNumber = flightNumber
        self.duration = duration
        self.aircraft = aircraft
    }
}

@Model
final class PersistentPassenger {
    var id: UUID
    var firstName: String
    var lastName: String
    var dateOfBirth: Date
    var passportNumber: String?
    var typeRawValue: String
    
    init(
        id: UUID = UUID(),
        firstName: String,
        lastName: String,
        dateOfBirth: Date,
        passportNumber: String? = nil,
        typeRawValue: String
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.dateOfBirth = dateOfBirth
        self.passportNumber = passportNumber
        self.typeRawValue = typeRawValue
    }
}

// MARK: - SwiftData Day Plan Models
@Model
final class PersistentDayPlan {
    var id: Int
    var date: Date
    
    @Relationship(deleteRule: .cascade) var activities: [PersistentActivity] = []
    @Relationship(deleteRule: .cascade) var checklist: [PersistentChecklistItem] = []
    
    init(id: Int, date: Date) {
        self.id = id
        self.date = date
    }
}

@Model
final class PersistentActivity {
    var id: UUID
    var title: String
    var activityDescription: String?
    var time: Date?
    
    init(
        id: UUID = UUID(),
        title: String,
        activityDescription: String? = nil,
        time: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.activityDescription = activityDescription
        self.time = time
    }
}

@Model
final class PersistentChecklistItem {
    var id: UUID
    var title: String
    var isDone: Bool
    
    init(id: UUID = UUID(), title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}