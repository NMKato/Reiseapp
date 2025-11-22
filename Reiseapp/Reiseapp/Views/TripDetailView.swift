//
//  TripDetailView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 08.09.25.
//

import SwiftUI

struct TripDetailView: View {
    let trip: Trip
    @State private var showingEditSheet = false
    @State private var selectedTab = 0
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Modern Hero Header
                modernHeroHeader
                
                // Tab Selector
                modernTabSelector
                
                // Tab Content
                modernTabContent
            }
        }
        .dismissKeyboardOnScroll()
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: { showingEditSheet = true }) {
                    Image(systemName: "ellipsis.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                        .background(.regularMaterial, in: Circle())
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            ModernEditTripSheet(trip: trip)
        }
    }
    
    // MARK: - Hero Header with Accommodation Images
    private var modernHeroHeader: some View {
        ZStack {
            // Accommodation Image Background
            accommodationImageBackground
            
            // Darker overlay for better text contrast
            LinearGradient(
                colors: [
                    Color.black.opacity(0.5),
                    Color.black.opacity(0.3)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 280)
            
            VStack(spacing: 16) {
                Spacer()
                
                // Destination Icon & Title
                VStack(spacing: 8) {
                    ZStack {
                        Circle()
                            .fill(.white.opacity(0.2))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: trip.imageName ?? "airplane.departure")
                            .font(.system(size: 36))
                            .foregroundStyle(.white)
                    }
                    
                    VStack(spacing: 4) {
                        Text(trip.destination)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text(trip.dateRangeText)
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.9))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8) 
                    .background(
                        // Milky transparent background for better readability
                        .regularMaterial.opacity(0.3), 
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
                
                // Key Stats Row
                HStack(spacing: 24) {
                    modernStatItem(
                        icon: "calendar",
                        value: "\(trip.duration ?? 0)",
                        label: "Tage"
                    )
                    
                    modernStatItem(
                        icon: "person.2.fill",
                        value: "\(trip.totalTravelers)",
                        label: "Personen"
                    )
                    
                    if let budget = trip.formattedBudget {
                        modernStatItem(
                            icon: "eurosign.circle.fill",
                            value: budget.replacingOccurrences(of: "€", with: ""),
                            label: "Budget"
                        )
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }
    
    private func modernStatItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white.opacity(0.9))
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.white)
            
            Text(label)
                .font(.caption)
                .foregroundStyle(.white.opacity(0.8))
        }
    }
    
    // MARK: - Accommodation Image Background
    private var accommodationImageBackground: some View {
        Group {
            if let firstHotel = trip.hotelBookings.first?.hotel,
               let firstImage = firstHotel.images.first {
                // Use real accommodation image from API
                AsyncImage(url: URL(string: firstImage)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 280)
                            .clipped()
                    case .failure(_), .empty:
                        // Fallback to gradient if image loading fails
                        LinearGradient(
                            colors: [
                                Color.blue.opacity(0.8),
                                Color.cyan.opacity(0.6),
                                Color.teal.opacity(0.4)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                        .frame(height: 280)
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                // Fallback gradient if no accommodation images available
                LinearGradient(
                    colors: [
                        Color.blue.opacity(0.8),
                        Color.cyan.opacity(0.6),
                        Color.teal.opacity(0.4)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 280)
            }
        }
    }
    
    // MARK: - Tab Selector
    private var modernTabSelector: some View {
        HStack(spacing: 0) {
            modernTabButton(title: "Übersicht", index: 0, icon: "info.circle.fill")
            modernTabButton(title: "Buchungen", index: 1, icon: "doc.text.fill")
            modernTabButton(title: "Planung", index: 2, icon: "list.bullet.clipboard.fill")
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .background(.regularMaterial)
    }
    
    private func modernTabButton(title: String, index: Int, icon: String) -> some View {
        Button(action: { selectedTab = index }) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundStyle(selectedTab == index ? .blue : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                selectedTab == index 
                    ? .blue.opacity(0.1) 
                    : Color.clear,
                in: RoundedRectangle(cornerRadius: 12)
            )
        }
    }
    
    // MARK: - Tab Content
    private var modernTabContent: some View {
        VStack(spacing: 24) {
            switch selectedTab {
            case 0:
                modernOverviewTab
            case 1:
                modernBookingsTab
            case 2:
                modernPlanningTab
            default:
                modernOverviewTab
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 24)
        .background(.regularMaterial)
    }
    
    private var modernOverviewTab: some View {
        VStack(spacing: 20) {
            // Weather Widget
            WeatherWidgetView(
                destination: trip.destination,
                startDate: trip.startDate
            )
            
            // Key Information Cards
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                modernInfoCard(
                    title: "Aktivitäten",
                    value: "\(trip.totalActivities)",
                    icon: "star.fill",
                    color: .orange
                )
                
                modernInfoCard(
                    title: "Buchungen",
                    value: "\(trip.hotelBookings.count + trip.flightBookings.count)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                modernInfoCard(
                    title: "Tage",
                    value: "\(trip.duration ?? 0)",
                    icon: "calendar",
                    color: .blue
                )
                
                modernInfoCard(
                    title: "Status",
                    value: trip.hasActivities ? "Geplant" : "Offen",
                    icon: trip.hasActivities ? "checkmark.seal.fill" : "clock.fill",
                    color: trip.hasActivities ? .green : .orange
                )
            }
        }
    }
    
    private func modernInfoCard(title: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }
            
            VStack(spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
    
    private var modernBookingsTab: some View {
        VStack(spacing: 16) {
            // Buchungsanfrage Sektion
            buchungsanfrageSection
            
            if !trip.hotelBookings.isEmpty || !trip.flightBookings.isEmpty {
                BookingsSection(trip: trip)
            } else {
                modernEmptyState(
                    icon: "doc.text.fill",
                    title: "Keine Buchungen",
                    message: "Füge Hotels oder Flüge hinzu"
                )
            }
        }
    }
    
    private var modernPlanningTab: some View {
        VStack(spacing: 16) {
            if !trip.days.isEmpty {
                ForEach(trip.days, id: \.id) { day in
                    ModernDayPlanCard(dayPlan: day)
                }
            } else {
                modernEmptyState(
                    icon: "list.bullet.clipboard.fill",
                    title: "Keine Planung",
                    message: "Erstelle deinen Reiseplan"
                )
            }
        }
    }
    
    private func modernEmptyState(icon: String, title: String, message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(.secondary.opacity(0.6))
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.secondary.opacity(0.2), lineWidth: 1)
        )
    }
    
    // MARK: - Buchungsanfrage Section
    private var buchungsanfrageSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Buchungsanfrage stellen")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Text(bookingActionSubtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: bookingActionIcon)
                    .font(.title2)
                    .foregroundStyle(.blue)
            }
            
            // Smart buttons based on booking types
            VStack(spacing: 12) {
                // Hotel booking button (if exists)
                if !trip.hotelBookings.isEmpty {
                    Button(action: openAirbnbWebsite) {
                        HStack {
                            Image(systemName: "building.2.fill")
                                .font(.headline)
                            Text("Unterkunft bei Airbnb buchen")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
                
                // Flight booking button (if exists)
                if !trip.flightBookings.isEmpty {
                    Button(action: openAirlineWebsite) {
                        HStack {
                            Image(systemName: "airplane")
                                .font(.headline)
                            Text("Flug bei \(airlineName) buchen")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.cyan, in: RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // Computed properties for dynamic content
    private var bookingActionSubtitle: String {
        let hasHotel = !trip.hotelBookings.isEmpty
        let hasFlight = !trip.flightBookings.isEmpty
        
        if hasHotel && hasFlight {
            return "Buche deine Unterkunft und Flug separat"
        } else if hasHotel {
            return "Besuche Airbnb, um deine Unterkunft zu buchen"
        } else if hasFlight {
            return "Besuche \(airlineName), um deinen Flug zu buchen"
        } else {
            return "Keine Buchungen verfügbar"
        }
    }
    
    private var bookingActionIcon: String {
        let hasHotel = !trip.hotelBookings.isEmpty
        let hasFlight = !trip.flightBookings.isEmpty
        
        if hasHotel && hasFlight {
            return "square.stack.3d.up.fill"
        } else if hasHotel {
            return "building.2.fill"
        } else if hasFlight {
            return "airplane"
        } else {
            return "heart.circle.fill"
        }
    }
    
    private var airlineName: String {
        trip.flightBookings.first?.outboundFlight.airline.name ?? "Fluggesellschaft"
    }
    
    private func openAirbnbWebsite() {
        var targetURL = "https://www.airbnb.de"
        
        // Try to find hotel booking and create better search URL
        if let hotelBooking = trip.hotelBookings.first {
            let city = hotelBooking.hotel.address.city
            
            // Create simple city-based search URL that should work reliably
            if let encodedCity = city.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                targetURL = "https://www.airbnb.de/s/\(encodedCity)/homes"
                
                print("🏨 Opening Airbnb search for city: \(city)")
                print("📍 Hotel name: \(hotelBooking.hotel.name)")
                print("🔗 URL: \(targetURL)")
            }
        }
        
        if let url = URL(string: targetURL) {
            openURL(url)
        } else {
            // Fallback to main Airbnb page if URL creation fails
            if let fallbackURL = URL(string: "https://www.airbnb.de") {
                openURL(fallbackURL)
            }
        }
    }
    
    private func openAirlineWebsite() {
        guard let flightBooking = trip.flightBookings.first else { return }
        
        let airline = flightBooking.outboundFlight.airline
        var targetURL = "https://www.google.com/flights"
        
        // Create airline-specific URLs or search URLs
        switch airline.code.uppercased() {
        case "LH":
            targetURL = "https://www.lufthansa.com"
        case "BA":
            targetURL = "https://www.britishairways.com"
        case "AF":
            targetURL = "https://www.airfrance.com"
        case "KL":
            targetURL = "https://www.klm.com"
        case "D8":
            targetURL = "https://www.norwegian.com"
        case "EW":
            targetURL = "https://www.eurowings.com"
        case "4U":
            targetURL = "https://www.eurowings.com"
        default:
            // Generic airline search with flight details
            let origin = flightBooking.outboundFlight.departure.airport.code
            let destination = flightBooking.outboundFlight.arrival.airport.code
            targetURL = "https://www.google.com/flights?q=flights+from+\(origin)+to+\(destination)"
        }
        
        print("✈️ Opening airline website: \(airline.name) (\(airline.code))")
        print("🔗 URL: \(targetURL)")
        
        if let url = URL(string: targetURL) {
            openURL(url)
        } else {
            // Fallback to Google Flights
            if let fallbackURL = URL(string: "https://www.google.com/flights") {
                openURL(fallbackURL)
            }
        }
    }
}

// MARK: - Modern Components

struct ModernDayPlanCard: View {
    let dayPlan: DayPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayPlan.date, style: .date)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Tag \(dayPlan.id)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Activity Count Badge
                if !dayPlan.activities.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text("\(dayPlan.activities.count)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.orange)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.orange.opacity(0.1), in: Capsule())
                }
            }
            
            // Activities List
            if !dayPlan.activities.isEmpty {
                VStack(spacing: 12) {
                    ForEach(Array(dayPlan.activities.enumerated()), id: \.offset) { index, activity in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(.blue)
                                .frame(width: 8, height: 8)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(activity)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                
                                Text("Aktivität \(index + 1)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Text("09:00")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.blue.opacity(0.1), in: RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
            }
            
            // Checklist
            if !dayPlan.checklist.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Checklist")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(Array(dayPlan.checklist.enumerated()), id: \.offset) { index, item in
                        HStack(spacing: 10) {
                            Image(systemName: index % 2 == 0 ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(index % 2 == 0 ? .green : .secondary)
                            
                            Text("\(item)")
                                .font(.caption)
                                .strikethrough(index % 2 == 0)
                                .foregroundStyle(index % 2 == 0 ? .secondary : .primary)
                            
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}

struct ModernEditTripSheet: View {
    let trip: Trip
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Coming Soon Content
                VStack(spacing: 16) {
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    VStack(spacing: 8) {
                        Text("Bearbeitung in Entwicklung")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Diese Funktion wird bald verfügbar sein")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, 60)
                
                Spacer()
            }
            .dismissKeyboardOnScroll()
            .padding(20)
            .navigationTitle("Reise bearbeiten")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct DayPlanCard: View {
    let dayPlan: DayPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayPlan.date, style: .date)
                .font(.headline)
            
            if !dayPlan.activities.isEmpty {
                ForEach(dayPlan.activities) { activity in
                    HStack {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.blue)
                        Text(activity.title)
                            .font(.subheadline)
                        Spacer()
                        if let time = activity.time {
                            Text(time, style: .time)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if !dayPlan.checklist.isEmpty {
                Divider()
                ForEach(dayPlan.checklist) { item in
                    HStack {
                        Image(systemName: item.isDone ? "checkmark.square.fill" : "square")
                            .foregroundColor(item.isDone ? .green : .gray)
                        Text(item.title)
                            .font(.caption)
                            .strikethrough(item.isDone)
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Bookings Section
struct BookingsSection: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buchungen")
                .font(.title2)
                .bold()
            
            // Hotel Bookings
            if !trip.hotelBookings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Hotels", systemImage: "building.2.fill")
                        .font(.headline)
                        .foregroundStyle(.blue)
                    
                    ForEach(trip.hotelBookings) { booking in
                        HotelBookingCard(booking: booking)
                    }
                }
            }
            
            // Flight Bookings
            if !trip.flightBookings.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Label("Flüge", systemImage: "airplane")
                        .font(.headline)
                        .foregroundStyle(.cyan)
                    
                    ForEach(trip.flightBookings) { booking in
                        FlightBookingCard(booking: booking)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.regularMaterial)
        )
    }
}

// MARK: - Hotel Booking Card
struct HotelBookingCard: View {
    let booking: HotelBooking
    
    var body: some View {
        HStack(spacing: 12) {
            // Hotel Icon
            RoundedRectangle(cornerRadius: 8)
                .fill(.blue.opacity(0.2))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "building.2.fill")
                        .foregroundStyle(.blue)
                )
            
            // Hotel Details
            VStack(alignment: .leading, spacing: 4) {
                Text(booking.hotel.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                Text("\(booking.checkInDate.formatted(date: .abbreviated, time: .omitted)) - \(booking.checkOutDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(booking.roomType.name)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Price & Status
            VStack(alignment: .trailing, spacing: 4) {
                Text(booking.totalPrice.formatted)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                StatusBadge(status: booking.status)
            }
        }
        .padding()
        .background(.quaternary)
        .cornerRadius(12)
    }
}

// MARK: - Flight Booking Card
struct FlightBookingCard: View {
    let booking: FlightBooking
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                // Flight Icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(.cyan.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "airplane")
                            .foregroundStyle(.cyan)
                    )
                
                // Flight Details
                VStack(alignment: .leading, spacing: 4) {
                    Text(booking.outboundFlight.airline.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("\(booking.outboundFlight.departure.airport.code) → \(booking.outboundFlight.arrival.airport.code)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(booking.outboundFlight.departure.dateTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Price & Status
                VStack(alignment: .trailing, spacing: 4) {
                    Text(booking.totalPrice.formatted)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    StatusBadge(status: booking.status)
                }
            }
            
            // Return Flight (if exists)
            if let returnFlight = booking.returnFlight {
                Divider()
                
                HStack {
                    Text("Rückflug:")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text("\(returnFlight.departure.airport.code) → \(returnFlight.arrival.airport.code)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text(returnFlight.departure.dateTime.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(.quaternary)
        .cornerRadius(12)
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let status: BookingStatus
    
    var body: some View {
        Text(status.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(backgroundColor)
            .foregroundStyle(foregroundColor)
            .cornerRadius(12)
    }
    
    private var backgroundColor: Color {
        switch status {
        case .pending: return .orange.opacity(0.2)
        case .confirmed: return .green.opacity(0.2)
        case .cancelled: return .red.opacity(0.2)
        case .completed: return .blue.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch status {
        case .pending: return .orange
        case .confirmed: return .green
        case .cancelled: return .red
        case .completed: return .blue
        }
    }
}

#Preview {
    NavigationStack {
        TripDetailView(trip: Trip.demo(title: "Sommerurlaub", destination: "Barcelona"))
    }
}
