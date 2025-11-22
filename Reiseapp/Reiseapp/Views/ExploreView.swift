//
//  ExploreView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//  Refactored on 11.09.25 - Components extracted for better performance
//

import SwiftUI
import MapKit
import Foundation

struct ExploreView: View {
    // MVVM Architecture - Business Logic moved to ViewModel
    @StateObject private var viewModel = ExploreViewModel()
    
    // UI State moved to ViewModel for central management
    @Environment(\.appEnvironment) private var env
    @EnvironmentObject private var themeManager: ThemeManager
    
    // AI Assistant Service
    @StateObject private var aiAssistant = AIAssistantService()
    
    // Use configuration instead of hardcoded data
    private var popularDestinations: [String] {
        AppConfiguration.Destinations.popularDestinations
    }
    
    // TravelCategory moved to ExploreViewModel - use ViewModel's definition
    typealias TravelCategory = ExploreViewModel.TravelCategory
    
    var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVStack(spacing: 20) {
                        // Header Section
                        headerSection
                            .id("top")
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    proxy.scrollTo("top", anchor: .top)
                                }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        
                        // Category Selection  
                        categorySelectionSection
                            .transition(.scale.combined(with: .opacity))
                        
                        // Search Card
                        searchSection
                            .transition(.move(edge: .leading).combined(with: .opacity))
                        
                        // Results or Popular Content
                        if !viewModel.destinationInput.isEmpty {
                            // Show search results when user has entered destination
                            searchResultsSection
                                .transition(.asymmetric(
                                    insertion: .move(edge: .bottom).combined(with: .opacity),
                                    removal: .move(edge: .top).combined(with: .opacity)
                                ))
                        } else {
                            // Show popular content when no search
                            popularContentSection
                                .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    .animation(.easeInOut(duration: 0.3), value: viewModel.destinationInput.isEmpty)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.selectedCategory)
                }
                .navigationBarHidden(true)
                .refreshable {
                    // Add pull-to-refresh functionality
                    await refreshContent()
                }
                .onAppear {
                    // Load popular hotels on first appearance if hotels category is selected
                    if viewModel.selectedCategory == .hotels && viewModel.popularHotels.isEmpty && !viewModel.isLoadingPopularHotels {
                        viewModel.loadPopularHotels()
                    }
                    // Configure AI Assistant
                    aiAssistant.configure(exploreViewModel: viewModel, appEnvironment: env)
                }
                .alert("AI Assistant Fehler", isPresented: .constant(aiAssistant.lastError != nil)) {
                    Button("OK") {
                        aiAssistant.lastError = nil
                    }
                } message: {
                    if let error = aiAssistant.lastError {
                        Text(error)
                    }
                }
            }
            .overlay(alignment: .bottomTrailing) {
                VStack(spacing: 12) {
                    // Test button (remove in production)
                    if ProcessInfo.processInfo.environment["DEBUG_AI"] == "1" {
                        Button(action: {
                            Task {
                                let success = await aiAssistant.testAIIntegration()
                                print("AI Test Result: \(success)")
                            }
                        }) {
                            Text("Test AI")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue, in: RoundedRectangle(cornerRadius: 6))
                                .foregroundColor(.white)
                        }
                    }
                    
                    voiceAssistantButton
                }
            }
            .overlay(alignment: .top) {
                if aiAssistant.isActive {
                    voiceStatusBar
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .sheet(isPresented: $viewModel.showingTransportOptions) {
                if let trip = viewModel.currentTrip {
                    TravelOptionsSheet(
                        destination: trip.destination,
                        onComplete: { destination in
                            viewModel.saveTrip(trip)
                            viewModel.currentTrip = nil
                            viewModel.showingTransportOptions = false
                        },
                        onNeedFlightSearch: { destination in
                            viewModel.currentTrip = trip
                            viewModel.showingTransportOptions = false
                            viewModel.showingAdditionalFlightSearch = true
                        }
                    )
                } else {
                    Text("Fehler: Keine Reisedaten verfügbar")
                        .padding()
                }
            }
            .sheet(isPresented: $viewModel.showingAdditionalFlightSearch) {
                if let trip = viewModel.currentTrip {
                    NavigationStack {
                        FlightSearchSheet(
                            destination: trip.destination,
                            room: nil,
                            hotel: nil,
                            checkInDate: viewModel.checkInDate,
                            checkOutDate: viewModel.checkOutDate
                        )
                        .navigationTitle("Flug hinzufügen")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Abbrechen") {
                                    viewModel.showingAdditionalFlightSearch = false
                                }
                            }
                        }
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAdditionalHotelSearch) {
                if let trip = viewModel.currentTrip {
                    NavigationStack {
                        HotelSearchExpandedView(
                            destination: trip.destination, 
                            checkInDate: viewModel.checkInDate, 
                            checkOutDate: viewModel.checkOutDate
                        ) { hotel in
                            trip.hotel = hotel
                            viewModel.showingAdditionalHotelSearch = false
                            // Complete the trip directly
                            viewModel.saveTrip(trip)
                            viewModel.currentTrip = nil
                        }
                        .navigationTitle("Hotel hinzufügen")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("Abbrechen") {
                                    viewModel.showingAdditionalHotelSearch = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - View Sections
    
    private var headerSection: some View {
        VStack(spacing: 0) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.8),
                        Color.cyan.opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                
                VStack(spacing: 8) {
                    Text("Entdecke dein nächstes Abenteuer")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Hotels, Flüge & mehr")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding()
            }
            .padding(.bottom, 8)
        }
    }
    
    private var categorySelectionSection: some View {
        VStack(spacing: 16) {
            Text("Was möchtest du planen?")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ForEach(TravelCategory.allCases, id: \.self) { category in
                    CategoryTabButton(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        // Add haptic feedback for better interaction
                        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                        impactFeedback.impactOccurred()
                        
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
        }
    }
    
    private var searchSection: some View {
        VStack(spacing: 16) {
            // Main search input
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.title3)
                
                TextField("Wohin geht die Reise?", text: $viewModel.destinationInput)
                    .font(.body)
                    .onSubmit {
                        if !viewModel.destinationInput.isEmpty {
                            viewModel.isHeaderExpanded = true
                        }
                    }
                
                if !viewModel.destinationInput.isEmpty {
                    Button(action: {
                        viewModel.destinationInput = ""
                        viewModel.isHeaderExpanded = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(.regularMaterial)
            .cornerRadius(16)
            
            // Date selection when destination is entered
            if !viewModel.destinationInput.isEmpty {
                dateSelectionForCategory
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
    
    private var dateSelectionForCategory: some View {
        VStack(spacing: 16) {
            if viewModel.selectedCategory == .flights {
                // Origin and Destination Input
                HStack(spacing: 12) {
                    // Origin City
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Von")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "airplane.departure")
                                .foregroundStyle(.blue)
                                .font(.caption)
                            
                            TextField("Abflugort", text: $viewModel.originInput)
                                .font(.subheadline)
                                .textFieldStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.regularMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    // Swap button
                    Button(action: {
                        let temp = viewModel.originInput
                        viewModel.originInput = viewModel.destinationInput
                        viewModel.destinationInput = temp
                    }) {
                        Image(systemName: "arrow.left.arrow.right")
                            .foregroundStyle(.blue)
                            .font(.title3)
                    }
                    .padding(.top, 16)
                    
                    // Destination City  
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Nach")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 8) {
                            Image(systemName: "airplane.arrival")
                                .foregroundStyle(.green)
                                .font(.caption)
                            
                            TextField("Zielort", text: $viewModel.destinationInput)
                                .font(.subheadline)
                                .textFieldStyle(.plain)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.regularMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
                    }
                }
                
                // Flight Date Selection
                HStack(spacing: 12) {
                    ModernDateField(title: "Hinflug", date: $viewModel.departureDate)
                    if !viewModel.isOneWay {
                        ModernDateField(title: "Rückflug", date: $viewModel.returnDate)
                    }
                }
                
                // Flight Options
                VStack(spacing: 8) {
                    HStack {
                        Button(action: { viewModel.isOneWay.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.isOneWay ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.blue)
                                Text("Nur Hinflug")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Button(action: { viewModel.directFlightsOnly.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.directFlightsOnly ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.blue)
                                Text("Nur Direktflüge")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                    }
                    
                    HStack {
                        Button(action: { viewModel.flexibleDates.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.flexibleDates ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.blue)
                                Text("Flexible Daten (±3 Tage)")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                    }
                }
                .padding(.horizontal, 4)
                
                // Passengers and Flight Class Selection
                HStack(spacing: 12) {
                    // Passengers
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Passagiere")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if viewModel.passengers > 1 {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.passengers -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(viewModel.passengers > 1 ? .blue : .gray)
                            }
                            .disabled(viewModel.passengers <= 1)
                            
                            Text("\(viewModel.passengers)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                if viewModel.passengers < 9 {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.passengers += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(viewModel.passengers < 9 ? .blue : .gray)
                            }
                            .disabled(viewModel.passengers >= 9)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                    
                    Spacer(minLength: 5)
                    
                    // Flight Class
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Klasse")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        Menu {
                            ForEach(ExploreViewModel.FlightClass.allCases, id: \.self) { flightClass in
                                Button(action: {
                                    viewModel.flightClass = flightClass
                                }) {
                                    HStack {
                                        Image(systemName: flightClass.icon)
                                        Text(flightClass.rawValue)
                                        if viewModel.flightClass == flightClass {
                                            Spacer()
                                            Image(systemName: "checkmark")
                                        }
                                    }
                                }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.flightClass.icon)
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                
                                Text(viewModel.flightClass.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.primary)
                                
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                }
                
                // Flight Search Button
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    viewModel.startFlightSearch()
                }) {
                    HStack(spacing: 8) {
                        if viewModel.isSearching {
                            ProgressView()
                                .scaleEffect(0.8)
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Image(systemName: "airplane")
                                .font(.headline)
                        }
                        
                        Text(viewModel.isSearching ? "Wird gesucht..." : "Flüge suchen")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [.green, .green.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .disabled(viewModel.destinationInput.isEmpty || viewModel.originInput.isEmpty || viewModel.isSearching)
            } else if viewModel.selectedCategory == .hotels {
                // Date Selection
                HStack(spacing: 12) {
                    ModernDateField(title: "Check-in", date: $viewModel.checkInDate)
                        .frame(maxWidth: .infinity)
                    ModernDateField(title: "Check-out", date: $viewModel.checkOutDate)
                        .frame(maxWidth: .infinity)
                }
                
                // Guest and Room Selection (positioned directly under date fields for symmetry)
                HStack(spacing: 12) {
                    // Guests
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Gäste")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if viewModel.guests > 1 {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.guests -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(viewModel.guests > 1 ? .blue : .gray)
                            }
                            .disabled(viewModel.guests <= 1)
                            
                            Text("\(viewModel.guests)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                if viewModel.guests < 8 {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.guests += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(viewModel.guests < 8 ? .blue : .gray)
                            }
                            .disabled(viewModel.guests >= 8)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                    
                    Spacer(minLength: 5)
                    
                    // Rooms
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Zimmer")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Button(action: {
                                if viewModel.rooms > 1 {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.rooms -= 1
                                }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(viewModel.rooms > 1 ? .blue : .gray)
                            }
                            .disabled(viewModel.rooms <= 1)
                            
                            Text("\(viewModel.rooms)")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(minWidth: 30)
                            
                            Button(action: {
                                if viewModel.rooms < 4 {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.rooms += 1
                                }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(viewModel.rooms < 4 ? .blue : .gray)
                            }
                            .disabled(viewModel.rooms >= 4)
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(.regularMaterial.opacity(0.7), in: RoundedRectangle(cornerRadius: 10))
                }
                .padding(40
                )
            }
            
            // Filter Section
            if viewModel.selectedCategory == .hotels {
                filtersSection
            }
        }
    }
    
    private var filtersSection: some View {
        VStack(spacing: 20) {
            
            // Modern Search Parameters Section
            VStack(spacing: 16) {
                // Header
                HStack {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    
                    Text("Suchfilter")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                
                // Price Filter Section  
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "eurosign.circle")
                            .foregroundStyle(.secondary)
                            .font(.title3)
                        
                        Text("Preisfilter")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Toggle("", isOn: $viewModel.usePriceFilter)
                            .labelsHidden()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    if viewModel.usePriceFilter {
                        RangeSlider(
                            range: $viewModel.priceRange,
                            bounds: 0...11000,
                            step: 50
                        )
                        .padding(.horizontal, 20)
                    }
                }
                
                // Rating Filter
                ModernRatingPicker(
                    selectedRating: $viewModel.selectedRating
                )
                .padding(.horizontal, 20)
                
                // Spacer for visual separation
                Spacer()
                    .frame(height: 8)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 1)
            )
            
            // Amenities Filter - Modern Design
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(.blue)
                        .font(.title2)
                    
                    Text("Ausstattung")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                    AmenityToggle(
                        isOn: $viewModel.hasWiFi,
                        icon: "wifi",
                        title: "WLAN"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasKitchen,
                        icon: "cooktop",
                        title: "Küche"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasAirConditioning,
                        icon: "wind",
                        title: "Klima"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasWashingMachine,
                        icon: "washer",
                        title: "Waschm."
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasParking,
                        icon: "car",
                        title: "Parkplatz"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasPool,
                        icon: "figure.pool.swim",
                        title: "Pool"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasGym,
                        icon: "dumbbell",
                        title: "Fitness"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.isPetFriendly,
                        icon: "pawprint",
                        title: "Haustiere"
                    )
                    
                    AmenityToggle(
                        isOn: $viewModel.hasCrib,
                        icon: "bed.double.circle",
                        title: "Kinderbett"
                    )
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.tertiary, lineWidth: 1)
            )
            
            
            // Search Button
            Button(action: {
                performSearch()
            }) {
                HStack {
                    Image(systemName: "bed.double")
                        .font(.headline)
                    Text("Unterkunft suchen")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(LinearGradient(
                    colors: [.blue, .cyan],
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .cornerRadius(16)
            }
        }
        .padding(.horizontal)
    }
    
    private var searchResultsSection: some View {
        VStack(spacing: 20) {
            // Search Results based on category
            switch viewModel.selectedCategory {
            case .hotels:
                HotelResultsSection(
                    hotels: viewModel.searchResults,
                    checkInDate: viewModel.checkInDate,
                    checkOutDate: viewModel.checkOutDate
                )
            case .flights:
                FlightResultsSection(
                    flights: viewModel.flightResults, 
                    onAddFlightToTrip: { flight in
                        viewModel.addFlightToTrip(flight, appEnvironment: env)
                    },
                    directFlightsOnly: viewModel.directFlightsOnly
                )
            case .weather:
                WeatherSearchExpandedView(destination: viewModel.destinationInput)
            case .planning:
                PlanningExpandedView(destination: viewModel.destinationInput)
            }
            
            // Travel Essentials for the destination
            TravelEssentialsSection(destination: viewModel.destinationInput)
            
            // Local Experiences
            LocalExperiencesSection(destination: viewModel.destinationInput)
            
            // Travel Tips
            TravelTipsSection(destination: viewModel.destinationInput)
        }
    }
    
    private var popularContentSection: some View {
        VStack(spacing: 20) {
            // Content based on selected category
            switch viewModel.selectedCategory {
            case .hotels:
                PopularHotelsSection(
                    checkInDate: viewModel.checkInDate,
                    checkOutDate: viewModel.checkOutDate,
                    viewModel: viewModel
                )
            case .flights:
                PopularRoutesSection()
            case .weather:
                WeatherExploreSection(globalSearch: viewModel.destinationInput)
            case .planning:
                PlanningSection()
            }
        }
    }
    
    // MARK: - AI Voice Assistant UI Components
    
    private var voiceAssistantButton: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            aiAssistant.toggleVoiceAssistant()
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                aiAssistant.getVoiceStateColor().opacity(0.9),
                                aiAssistant.getVoiceStateColor().opacity(0.7)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 64, height: 64)
                    .shadow(color: aiAssistant.getVoiceStateColor().opacity(0.3), radius: 8, x: 0, y: 4)
                
                // Pulse animation for listening state
                if aiAssistant.voiceState == .listening {
                    Circle()
                        .stroke(aiAssistant.getVoiceStateColor().opacity(0.5), lineWidth: 2)
                        .frame(width: 80, height: 80)
                        .scaleEffect(aiAssistant.voiceState == .listening ? 1.2 : 1.0)
                        .opacity(aiAssistant.voiceState == .listening ? 0.0 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5).repeatForever(autoreverses: false),
                            value: aiAssistant.voiceState == .listening
                        )
                }
                
                Image(systemName: aiAssistant.getVoiceStateIcon())
                    .font(.title2)
                    .foregroundColor(.white)
                    .scaleEffect(aiAssistant.voiceState == .processing ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: aiAssistant.voiceState)
            }
        }
        .padding(.trailing, 20)
        .padding(.bottom, 100)
    }
    
    private var voiceStatusBar: some View {
        HStack(spacing: 12) {
            // Voice state icon
            Image(systemName: aiAssistant.getVoiceStateIcon())
                .font(.title3)
                .foregroundColor(aiAssistant.getVoiceStateColor())
            
            VStack(alignment: .leading, spacing: 2) {
                // Voice state description
                Text(aiAssistant.getVoiceStateDescription())
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                // Current transcript or response
                if !aiAssistant.currentTranscript.isEmpty && aiAssistant.voiceState == .listening {
                    Text(aiAssistant.currentTranscript)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else if !aiAssistant.assistantResponse.isEmpty && aiAssistant.voiceState == .speaking {
                    Text(aiAssistant.assistantResponse)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                } else if aiAssistant.isProcessingCommand {
                    Text("Verarbeite Anfrage...")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Close button
            Button(action: {
                aiAssistant.stopVoiceAssistant()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(aiAssistant.getVoiceStateColor().opacity(0.3), lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 50)
    }
    
    // MARK: - Helper Functions
    
    private func refreshContent() async {
        // Implement pull-to-refresh logic
        await viewModel.refreshData()
    }
    
    private func performSearch() {
        viewModel.startHotelSearch()
    }
    
}

// MARK: - SwiftUI Previews

#if DEBUG

struct ExploreView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Standard Hotels View
            ExploreView()
                .environment(\.appEnvironment, AppEnvironment.preview)
                .previewDisplayName("Standard - Hotels")
            
            // Mit Suchergebnissen
            ExploreViewWithSearchResults()
                .previewDisplayName("Mit Suchergebnissen")
            
            // Loading State  
            ExploreViewLoading()
                .previewDisplayName("Laden...")
                
            // Flüge Kategorie
            ExploreViewFlights()
                .previewDisplayName("Flüge Kategorie")
        }
    }
}

// MARK: - Preview Helper Views

private struct ExploreViewWithSearchResults: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        ExploreView()
            .environment(\.appEnvironment, AppEnvironment.preview)
            .onAppear {
                viewModel.destinationInput = "Berlin"
                viewModel.searchResults = Hotel.previewList
                viewModel.showResults = true
                viewModel.popularHotels = Hotel.previewList
            }
    }
}

private struct ExploreViewLoading: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        ExploreView()
            .environment(\.appEnvironment, AppEnvironment.preview)
            .onAppear {
                viewModel.isSearching = true
                viewModel.destinationInput = "München"
            }
    }
}

private struct ExploreViewFlights: View {
    @StateObject private var viewModel = ExploreViewModel()
    
    var body: some View {
        ExploreView()
            .environment(\.appEnvironment, AppEnvironment.preview)
            .onAppear {
                viewModel.selectedCategory = .flights
            }
    }
}

#endif
