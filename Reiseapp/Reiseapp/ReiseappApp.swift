//
//  ReiseappApp.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.



import SwiftUI
import SwiftData

final class AuthStore: ObservableObject {
    @Published var isLoggedIn = false
}

@main
struct TravelPlannerApp: App {
    @StateObject private var auth = AuthStore()
    @StateObject private var themeManager = ThemeManager.shared
    
    // SwiftData Container
    let modelContainer: ModelContainer
    
    // AppEnvironment als StateObject
    @StateObject private var appEnvironment: AppEnvironment
    
    init() {
        do {
            // Konfiguriere SwiftData Model Container
            modelContainer = try ModelContainer(for: 
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
                PersistentChecklistItem.self
            )
            
            // Erstelle AppEnvironment mit SwiftData
            let modelContext = modelContainer.mainContext
            let tripRepository = SwiftDataTripRepository(modelContext: modelContext)
            
            let env = AppEnvironment(
                tripRepository: tripRepository,
                weatherService: RealWeatherService(),
                hotelSearchService: HotelSearchService(),
                flightSearchService: FlightSearchService(),
                networkManager: NetworkManager.shared
            )
            
            _appEnvironment = StateObject(wrappedValue: env)
            
            print("✅ SwiftData: Model container initialized successfully")
        } catch {
            print("❌ SwiftData: Failed to create model container: \(error)")
            fatalError("Failed to create SwiftData model container: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn {
                    RootView(appEnvironment: appEnvironment)
                        .themedBackground()
                } else {
                    LoginView()
                        .themedBackground()
                }
            }
            .modelContainer(modelContainer)
            .environment(\.appEnvironment, appEnvironment)
            .environment(\.themeManager, themeManager)
            .environmentObject(auth)
            .environmentObject(themeManager)
            .preferredColorScheme(themeManager.currentTheme == .system ? nil : 
                                (themeManager.isDarkMode ? .dark : .light))
        }
    }
}
