//
//  ModelConverters.swift
//  Reiseapp
//
//  Created by Claude on 11.09.25.
//

import Foundation
import SwiftData

// MARK: - Trip Conversion Extensions

extension Trip {
    /// Konvertiert einen Trip zu einem PersistentTrip für SwiftData
    func toPersistent() -> PersistentTrip {
        let persistentTrip = PersistentTrip(
            id: self.id,
            title: self.title,
            destination: self.destination,
            startDate: self.startDate,
            endDate: self.endDate,
            imageName: self.imageName,
            numberOfAdults: self.numberOfAdults,
            numberOfChildren: self.numberOfChildren,
            budget: self.budget,
            currency: self.currency
        )
        
        // Days konvertieren
        persistentTrip.days = self.days.map { $0.toPersistent() }
        
        // Hotel Bookings konvertieren
        persistentTrip.hotelBookings = self.hotelBookings.map { $0.toPersistent() }
        
        // Flight Bookings konvertieren
        persistentTrip.flightBookings = self.flightBookings.map { $0.toPersistent() }
        
        // Weather Forecast konvertieren
        if let weatherForecast = self.weatherForecast {
            persistentTrip.weatherForecast = weatherForecast.toPersistent()
        }
        
        // Destination Coordinates konvertieren
        if let coordinates = self.destinationCoordinates {
            persistentTrip.destinationCoordinates = coordinates.toPersistent()
        }
        
        return persistentTrip
    }
}

extension PersistentTrip {
    /// Konvertiert einen PersistentTrip zurück zu einem Trip
    func toTrip() -> Trip {
        Trip(
            id: self.id,
            title: self.title,
            destination: self.destination,
            startDate: self.startDate,
            endDate: self.endDate,
            imageName: self.imageName,
            days: self.days.map { $0.toDayPlan() },
            numberOfAdults: self.numberOfAdults,
            numberOfChildren: self.numberOfChildren,
            budget: self.budget,
            currency: self.currency,
            hotelBookings: self.hotelBookings.map { $0.toHotelBooking() },
            flightBookings: self.flightBookings.map { $0.toFlightBooking() },
            weatherForecast: self.weatherForecast?.toWeatherForecast(),
            destinationCoordinates: self.destinationCoordinates?.toCoordinates()
        )
    }
}

// MARK: - Coordinates Conversion

extension Coordinates {
    func toPersistent() -> PersistentCoordinates {
        PersistentCoordinates(latitude: self.latitude, longitude: self.longitude)
    }
}

extension PersistentCoordinates {
    func toCoordinates() -> Coordinates {
        Coordinates(latitude: self.latitude, longitude: self.longitude)
    }
}

// MARK: - Weather Conversion

extension WeatherForecast {
    func toPersistent() -> PersistentWeatherForecast {
        let persistent = PersistentWeatherForecast(
            location: self.location,
            lastUpdated: self.lastUpdated
        )
        persistent.forecasts = self.forecasts.map { $0.toPersistent() }
        return persistent
    }
}

extension PersistentWeatherForecast {
    func toWeatherForecast() -> WeatherForecast {
        WeatherForecast(
            location: self.location,
            forecasts: self.forecasts.map { $0.toDailyWeather() },
            lastUpdated: self.lastUpdated
        )
    }
}

extension DailyWeather {
    func toPersistent() -> PersistentDailyWeather {
        PersistentDailyWeather(
            id: UUID(), // Note: DailyWeather hat eine automatische ID
            date: self.date,
            temperatureMin: self.temperatureMin,
            temperatureMax: self.temperatureMax,
            temperatureCurrent: self.temperatureCurrent,
            conditionRawValue: self.condition.rawValue,
            humidity: self.humidity,
            windSpeed: self.windSpeed,
            precipitation: self.precipitation,
            icon: self.icon
        )
    }
}

extension PersistentDailyWeather {
    func toDailyWeather() -> DailyWeather {
        DailyWeather(
            date: self.date,
            temperatureMin: self.temperatureMin,
            temperatureMax: self.temperatureMax,
            temperatureCurrent: self.temperatureCurrent,
            condition: WeatherCondition(rawValue: self.conditionRawValue) ?? .clear,
            humidity: self.humidity,
            windSpeed: self.windSpeed,
            precipitation: self.precipitation,
            icon: self.icon
        )
    }
}

// MARK: - Hotel Conversion

extension HotelBooking {
    func toPersistent() -> PersistentHotelBooking {
        let persistent = PersistentHotelBooking(
            id: self.id,
            checkInDate: self.checkInDate,
            checkOutDate: self.checkOutDate,
            numberOfRooms: self.numberOfRooms,
            confirmationNumber: self.confirmationNumber,
            statusRawValue: self.status.rawValue
        )
        persistent.hotel = self.hotel.toPersistent()
        persistent.roomType = self.roomType.toPersistent()
        persistent.totalPrice = self.totalPrice.toPersistent()
        return persistent
    }
}

extension PersistentHotelBooking {
    func toHotelBooking() -> HotelBooking {
        HotelBooking(
            id: self.id,
            hotel: self.hotel?.toHotel() ?? Hotel(id: "", name: "Unknown", address: Address(street: nil, city: "Unknown", postalCode: nil, country: "Unknown"), rating: nil, pricePerNight: Price(amount: 0, currency: "EUR"), amenities: [], images: [], description: nil, distanceFromCenter: nil, coordinates: Coordinates(latitude: 0, longitude: 0), availability: false, roomTypes: [], contact: nil),
            checkInDate: self.checkInDate,
            checkOutDate: self.checkOutDate,
            roomType: self.roomType?.toRoomType() ?? RoomType(id: "", name: "Unknown", maxOccupancy: 1, price: Price(amount: 0, currency: "EUR"), amenities: [], available: false, images: []),
            numberOfRooms: self.numberOfRooms,
            totalPrice: self.totalPrice?.toPrice() ?? Price(amount: 0, currency: "EUR"),
            confirmationNumber: self.confirmationNumber,
            status: BookingStatus(rawValue: self.statusRawValue) ?? .pending
        )
    }
}

extension Hotel {
    func toPersistent() -> PersistentHotel {
        let persistent = PersistentHotel(
            id: self.id,
            name: self.name,
            rating: self.rating,
            amenities: self.amenities,
            images: self.images,
            hotelDescription: self.description,
            distanceFromCenter: self.distanceFromCenter,
            availability: self.availability
        )
        persistent.address = self.address.toPersistent()
        persistent.pricePerNight = self.pricePerNight.toPersistent()
        persistent.coordinates = self.coordinates.toPersistent()
        persistent.contact = self.contact?.toPersistent()
        persistent.roomTypes = self.roomTypes.map { $0.toPersistent() }
        return persistent
    }
}

extension PersistentHotel {
    func toHotel() -> Hotel {
        Hotel(
            id: self.id,
            name: self.name,
            address: self.address?.toAddress() ?? Address(street: nil, city: "Unknown", postalCode: nil, country: "Unknown"),
            rating: self.rating,
            pricePerNight: self.pricePerNight?.toPrice() ?? Price(amount: 0, currency: "EUR"),
            amenities: self.amenities,
            images: self.images,
            description: self.hotelDescription,
            distanceFromCenter: self.distanceFromCenter,
            coordinates: self.coordinates?.toCoordinates() ?? Coordinates(latitude: 0, longitude: 0),
            availability: self.availability,
            roomTypes: self.roomTypes.map { $0.toRoomType() },
            contact: self.contact?.toHotelContact()
        )
    }
}

extension Address {
    func toPersistent() -> PersistentAddress {
        PersistentAddress(
            street: self.street,
            city: self.city,
            postalCode: self.postalCode,
            country: self.country
        )
    }
}

extension PersistentAddress {
    func toAddress() -> Address {
        Address(
            street: self.street,
            city: self.city,
            postalCode: self.postalCode,
            country: self.country
        )
    }
}

extension HotelContact {
    func toPersistent() -> PersistentHotelContact {
        PersistentHotelContact(
            phone: self.phone,
            email: self.email,
            website: self.website
        )
    }
}

extension PersistentHotelContact {
    func toHotelContact() -> HotelContact {
        HotelContact(
            phone: self.phone,
            email: self.email,
            website: self.website
        )
    }
}

extension RoomType {
    func toPersistent() -> PersistentRoomType {
        let persistent = PersistentRoomType(
            id: self.id,
            name: self.name,
            maxOccupancy: self.maxOccupancy,
            amenities: self.amenities,
            available: self.available,
            images: self.images
        )
        persistent.price = self.price.toPersistent()
        return persistent
    }
}

extension PersistentRoomType {
    func toRoomType() -> RoomType {
        RoomType(
            id: self.id,
            name: self.name,
            maxOccupancy: self.maxOccupancy,
            price: self.price?.toPrice() ?? Price(amount: 0, currency: "EUR"),
            amenities: self.amenities,
            available: self.available,
            images: self.images
        )
    }
}

extension Price {
    func toPersistent() -> PersistentPrice {
        PersistentPrice(amount: self.amount, currency: self.currency)
    }
}

extension PersistentPrice {
    func toPrice() -> Price {
        Price(amount: self.amount, currency: self.currency)
    }
}

// MARK: - Flight Conversion

extension FlightBooking {
    func toPersistent() -> PersistentFlightBooking {
        let persistent = PersistentFlightBooking(
            id: self.id,
            bookingReference: self.bookingReference,
            statusRawValue: self.status.rawValue
        )
        persistent.outboundFlight = self.outboundFlight.toPersistent()
        persistent.returnFlight = self.returnFlight?.toPersistent()
        persistent.passengers = self.passengers.map { $0.toPersistent() }
        persistent.totalPrice = self.totalPrice.toPersistent()
        return persistent
    }
}

extension PersistentFlightBooking {
    func toFlightBooking() -> FlightBooking {
        FlightBooking(
            id: self.id,
            outboundFlight: self.outboundFlight?.toFlight() ?? Flight(id: "", airline: Airline(code: "", name: "", logo: nil), flightNumber: "", departure: FlightEndpoint(airport: Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)), dateTime: Date(), terminal: nil, gate: nil), arrival: FlightEndpoint(airport: Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)), dateTime: Date(), terminal: nil, gate: nil), duration: 0, isEstimatedDuration: false, price: Price(amount: 0, currency: "EUR"), availableSeats: 0, cabinClass: .economy, stops: 0, segments: []),
            returnFlight: self.returnFlight?.toFlight(),
            passengers: self.passengers.map { $0.toPassenger() },
            totalPrice: self.totalPrice?.toPrice() ?? Price(amount: 0, currency: "EUR"),
            bookingReference: self.bookingReference,
            status: BookingStatus(rawValue: self.statusRawValue) ?? .pending
        )
    }
}

extension Flight {
    func toPersistent() -> PersistentFlight {
        let persistent = PersistentFlight(
            id: self.id,
            flightNumber: self.flightNumber,
            duration: self.duration,
            availableSeats: self.availableSeats,
            cabinClassRawValue: self.cabinClass.rawValue,
            stops: self.stops
        )
        persistent.airline = self.airline.toPersistent()
        persistent.departure = self.departure.toPersistent()
        persistent.arrival = self.arrival.toPersistent()
        persistent.price = self.price.toPersistent()
        persistent.segments = self.segments.map { $0.toPersistent() }
        return persistent
    }
}

extension PersistentFlight {
    func toFlight() -> Flight {
        Flight(
            id: self.id,
            airline: self.airline?.toAirline() ?? Airline(code: "", name: "Unknown", logo: nil),
            flightNumber: self.flightNumber,
            departure: self.departure?.toFlightEndpoint() ?? FlightEndpoint(airport: Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)), dateTime: Date(), terminal: nil, gate: nil),
            arrival: self.arrival?.toFlightEndpoint() ?? FlightEndpoint(airport: Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)), dateTime: Date(), terminal: nil, gate: nil),
            duration: self.duration,
            isEstimatedDuration: false, // Default to false for persisted flights
            price: self.price?.toPrice() ?? Price(amount: 0, currency: "EUR"),
            availableSeats: self.availableSeats,
            cabinClass: CabinClass(rawValue: self.cabinClassRawValue) ?? .economy,
            stops: self.stops,
            segments: self.segments.map { $0.toFlightSegment() }
        )
    }
}

extension Airline {
    func toPersistent() -> PersistentAirline {
        PersistentAirline(code: self.code, name: self.name, logo: self.logo)
    }
}

extension PersistentAirline {
    func toAirline() -> Airline {
        Airline(code: self.code, name: self.name, logo: self.logo)
    }
}

extension FlightEndpoint {
    func toPersistent() -> PersistentFlightEndpoint {
        let persistent = PersistentFlightEndpoint(
            dateTime: self.dateTime,
            terminal: self.terminal,
            gate: self.gate
        )
        persistent.airport = self.airport.toPersistent()
        return persistent
    }
}

extension PersistentFlightEndpoint {
    func toFlightEndpoint() -> FlightEndpoint {
        FlightEndpoint(
            airport: self.airport?.toAirport() ?? Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)),
            dateTime: self.dateTime,
            terminal: self.terminal,
            gate: self.gate
        )
    }
}

extension Airport {
    func toPersistent() -> PersistentAirport {
        let persistent = PersistentAirport(
            code: self.code,
            name: self.name,
            city: self.city,
            country: self.country
        )
        persistent.coordinates = self.coordinates.toPersistent()
        return persistent
    }
}

extension PersistentAirport {
    func toAirport() -> Airport {
        Airport(
            code: self.code,
            name: self.name,
            city: self.city,
            country: self.country,
            coordinates: self.coordinates?.toCoordinates() ?? Coordinates(latitude: 0, longitude: 0)
        )
    }
}

extension FlightSegment {
    func toPersistent() -> PersistentFlightSegment {
        let persistent = PersistentFlightSegment(
            id: self.id,
            flightNumber: self.flightNumber,
            duration: self.duration,
            aircraft: self.aircraft
        )
        persistent.departure = self.departure.toPersistent()
        persistent.arrival = self.arrival.toPersistent()
        return persistent
    }
}

extension PersistentFlightSegment {
    func toFlightSegment() -> FlightSegment {
        FlightSegment(
            id: self.id,
            departure: self.departure?.toFlightEndpoint() ?? FlightEndpoint(airport: Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)), dateTime: Date(), terminal: nil, gate: nil),
            arrival: self.arrival?.toFlightEndpoint() ?? FlightEndpoint(airport: Airport(code: "", name: "", city: "", country: "", coordinates: Coordinates(latitude: 0, longitude: 0)), dateTime: Date(), terminal: nil, gate: nil),
            flightNumber: self.flightNumber,
            duration: self.duration,
            aircraft: self.aircraft
        )
    }
}

extension Passenger {
    func toPersistent() -> PersistentPassenger {
        PersistentPassenger(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            dateOfBirth: self.dateOfBirth,
            passportNumber: self.passportNumber,
            typeRawValue: self.type.rawValue
        )
    }
}

extension PersistentPassenger {
    func toPassenger() -> Passenger {
        Passenger(
            id: self.id,
            firstName: self.firstName,
            lastName: self.lastName,
            dateOfBirth: self.dateOfBirth,
            passportNumber: self.passportNumber,
            type: PassengerType(rawValue: self.typeRawValue) ?? .adult
        )
    }
}

// MARK: - Day Plan Conversion

extension DayPlan {
    func toPersistent() -> PersistentDayPlan {
        let persistent = PersistentDayPlan(id: self.id.hashValue, date: self.date)
        persistent.activities = self.activities.map { $0.toPersistent() }
        persistent.checklist = self.checklist.map { $0.toPersistent() }
        return persistent
    }
}

extension PersistentDayPlan {
    func toDayPlan() -> DayPlan {
        DayPlan(
            id: UUID(),
            date: self.date,
            activities: self.activities.map { $0.toActivity() },
            checklist: self.checklist.map { $0.toChecklistItem() }
        )
    }
}

extension Activity {
    func toPersistent() -> PersistentActivity {
        PersistentActivity(
            id: self.id,
            title: self.title,
            activityDescription: self.notes,
            time: self.time
        )
    }
}

extension PersistentActivity {
    func toActivity() -> Activity {
        Activity(
            id: self.id,
            title: self.title,
            notes: self.activityDescription,
            time: self.time
        )
    }
}

extension ChecklistItem {
    func toPersistent() -> PersistentChecklistItem {
        PersistentChecklistItem(
            id: self.id,
            title: self.title,
            isDone: self.isDone
        )
    }
}

extension PersistentChecklistItem {
    func toChecklistItem() -> ChecklistItem {
        ChecklistItem(
            id: self.id,
            title: self.title,
            isDone: self.isDone
        )
    }
}