//
//  AppEnvironment.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import SwiftData
import Foundation

// Dependency Container
final class AppEnvironment: ObservableObject {
    let tripRepository: TripRepository
    let weatherService: WeatherService
    let hotelSearchService: HotelSearching
    let flightSearchService: FlightSearching
    let networkManager: NetworkManaging
    let aiAssistant: AIAssistantService
    @Published var selectedTab: Int = 0

    init(
        tripRepository: TripRepository,
        weatherService: WeatherService = RealWeatherService(),
        hotelSearchService: HotelSearching = HotelSearchService(),
        flightSearchService: FlightSearching = FlightSearchService(),
        networkManager: NetworkManaging = NetworkManager.shared,
        aiAssistant: AIAssistantService? = nil
    ) {
        self.tripRepository = tripRepository
        self.weatherService = weatherService
        self.hotelSearchService = hotelSearchService
        self.flightSearchService = flightSearchService
        self.networkManager = networkManager
        self.aiAssistant = aiAssistant ?? AIAssistantService()
    }
    
    @MainActor
    func configureAIAssistant(with exploreViewModel: ExploreViewModel) {
        aiAssistant.configure(exploreViewModel: exploreViewModel, appEnvironment: self)
    }

    // Deprecated: Use createAppEnvironment in App instead
    static var live: AppEnvironment {
        let aiAssistant = AIAssistantService()
        let environment = AppEnvironment(
            tripRepository: LocalTripRepository(seed: SeedData.trips),
            weatherService: RealWeatherService(),
            hotelSearchService: HotelSearchService(),
            flightSearchService: FlightSearchService(),
            aiAssistant: aiAssistant
        )
        return environment
    }
    
    static var preview: AppEnvironment {
        let aiAssistant = AIAssistantService()
        let environment = AppEnvironment(
            tripRepository: MockTripRepository(),
            weatherService: DummyWeatherService(),
            hotelSearchService: HotelSearchService(),
            flightSearchService: FlightSearchService(),
            aiAssistant: aiAssistant
        )
        return environment
    }
    
    // MARK: - SwiftData Factory Methods
    
    /// Erstellt ein AppEnvironment für SwiftUI Previews mit In-Memory SwiftData
    @MainActor
    static func previewWithSwiftData() -> AppEnvironment {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: 
                PersistentTrip.self,
                PersistentCoordinates.self,
                PersistentWeatherForecast.self,
                PersistentDailyWeather.self,
                PersistentHotelBooking.self,
                PersistentHotel.self,
                PersistentAddress.self,
                PersistentHotelContact.self,
                PersistentRoomType.self,
                PersistentPrice.self,
                PersistentFlightBooking.self,
                PersistentFlight.self,
                PersistentAirline.self,
                PersistentFlightEndpoint.self,
                PersistentAirport.self,
                PersistentFlightSegment.self,
                PersistentPassenger.self,
                PersistentDayPlan.self,
                PersistentActivity.self,
                PersistentChecklistItem.self,
                configurations: config
            )
            
            let tripRepository = SwiftDataTripRepository(modelContext: container.mainContext)
            
            // Add some preview data
            Task {
                do {
                    let previewTrips = SeedData.trips
                    for trip in previewTrips {
                        try await tripRepository.add(trip)
                    }
                    print("✅ SwiftData Preview: Added \(previewTrips.count) sample trips")
                } catch {
                    print("❌ SwiftData Preview: Failed to add sample data: \(error)")
                }
            }
            
            let aiAssistant = AIAssistantService()
            let environment = AppEnvironment(
                tripRepository: tripRepository,
                weatherService: DummyWeatherService(),
                hotelSearchService: HotelSearchService(),
                flightSearchService: FlightSearchService(),
                aiAssistant: aiAssistant
            )
            return environment
        } catch {
            print("❌ SwiftData Preview: Failed to create preview environment: \(error)")
            // Fallback to MockTripRepository
            return preview
        }
    }
}


private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: AppEnvironment = .live
}

extension EnvironmentValues {
    var appEnvironment: AppEnvironment {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}
