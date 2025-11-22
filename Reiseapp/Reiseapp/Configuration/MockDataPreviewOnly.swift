//
//  MockDataPreviewOnly.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import Foundation

// MARK: - PREVIEW ONLY Mock Data
// ⚠️ WARNING: This file is ONLY for SwiftUI Previews
// ⚠️ Simulator and production MUST use real API data!

#if DEBUG

struct PreviewMockData {
    
    // MARK: - Preview-Only Hotels (Simplified)
    
    static let previewHotels: [Hotel] = [
        Hotel(
            id: "preview-hotel-1",
            name: "Berlin Preview Hotel",
            address: Address(
                street: "Unter den Linden 1",
                city: "Berlin",
                postalCode: "10117",
                country: "Deutschland"
            ),
            rating: 4.5,
            pricePerNight: Price(amount: 120, currency: "EUR"),
            amenities: ["WLAN", "Fitness", "Restaurant"],
            images: ["https://via.placeholder.com/300x200?text=Hotel+Berlin"],
            description: "Preview Hotel für SwiftUI Previews",
            distanceFromCenter: 1.0,
            coordinates: Coordinates(latitude: 52.5200, longitude: 13.4050),
            availability: true,
            roomTypes: [],
            contact: nil
        ),
        
        Hotel(
            id: "preview-hotel-2",
            name: "München Preview Hotel",
            address: Address(
                street: "Maximilianstraße 1",
                city: "München",
                postalCode: "80539",
                country: "Deutschland"
            ),
            rating: 4.2,
            pricePerNight: Price(amount: 95, currency: "EUR"),
            amenities: ["WLAN", "Parkplatz"],
            images: ["https://via.placeholder.com/300x200?text=Hotel+München"],
            description: "Preview Hotel für SwiftUI Previews",
            distanceFromCenter: 0.8,
            coordinates: Coordinates(latitude: 48.1351, longitude: 11.5820),
            availability: true,
            roomTypes: [],
            contact: nil
        ),
        
        Hotel(
            id: "preview-hotel-3",
            name: "Barcelona Preview Hotel",
            address: Address(
                street: "Las Ramblas 1",
                city: "Barcelona",
                postalCode: "08002",
                country: "Spanien"
            ),
            rating: 4.8,
            pricePerNight: Price(amount: 150, currency: "EUR"),
            amenities: ["WLAN", "Pool", "Strand"],
            images: ["https://via.placeholder.com/300x200?text=Hotel+Barcelona"],
            description: "Preview Hotel für SwiftUI Previews",
            distanceFromCenter: 2.0,
            coordinates: Coordinates(latitude: 41.3851, longitude: 2.1734),
            availability: true,
            roomTypes: [],
            contact: nil
        )
    ]
    
    // MARK: - Preview-Only Search Parameters
    
    static let previewSearchParameters = HotelSearchParameters(
        destination: "Berlin",
        checkInDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        checkOutDate: Calendar.current.date(byAdding: .day, value: 10, to: Date()) ?? Date(),
        numberOfAdults: 2,
        numberOfChildren: 0,
        numberOfRooms: 1,
        maxPrice: 300,
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

// MARK: - Preview Extensions

extension Hotel {
    /// ONLY for SwiftUI Previews - DO NOT use in simulator!
    static var preview: Hotel {
        PreviewMockData.previewHotels.first!
    }
    
    /// ONLY for SwiftUI Previews - DO NOT use in simulator!
    static var previewList: [Hotel] {
        PreviewMockData.previewHotels
    }
}

extension HotelSearchParameters {
    /// ONLY for SwiftUI Previews - DO NOT use in simulator!
    static var preview: HotelSearchParameters {
        PreviewMockData.previewSearchParameters
    }
}

#endif