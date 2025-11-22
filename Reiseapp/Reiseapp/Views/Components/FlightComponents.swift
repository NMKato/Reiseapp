//
//  FlightComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI
import MapKit
import Foundation

// MARK: - Popular Routes Section

struct PopularRoutesSection: View {
    private let popularRoutes = [
        ("BER", "BCN", "€89"),
        ("MUC", "CDG", "€120"),
        ("HAM", "LHR", "€95")
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Beliebte Routen")
                    .font(.headline)
                Spacer()
                Button("Alle anzeigen") {}
                    .font(.caption)
                    .foregroundStyle(.cyan)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<popularRoutes.count, id: \.self) { index in
                        let route = popularRoutes[index]
                        
                        VStack(spacing: 12) {
                            HStack {
                                Text(route.0)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                
                                Image(systemName: "airplane")
                                    .foregroundStyle(.cyan)
                                
                                Text(route.1)
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                            
                            Text("ab \(route.2)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.cyan)
                        }
                        .frame(width: 140)
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Flight Results Section

struct FlightResultsSection: View {
    let flights: [Flight]
    var onAddFlightToTrip: ((Flight) -> Void)?
    var directFlightsOnly: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Verfügbare Flüge")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Text("\(flights.count) gefunden")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            
            if flights.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: directFlightsOnly ? "airplane.slash" : "airplane")
                        .font(.system(size: 40))
                        .foregroundStyle(directFlightsOnly ? .orange : .secondary)
                    
                    if directFlightsOnly {
                        Text("Keine Direktflüge verfügbar")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text("Deaktiviere 'Nur Direktflüge' um Flüge mit Zwischenstopps zu sehen")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        Text("Keine Flüge gefunden")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(40)
            } else {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 16) {
                        ForEach(flights.prefix(10), id: \.id) { flight in
                            FlightResultCard(flight: flight, onAddToTrip: onAddFlightToTrip)
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: 400)
            }
        }
    }
}

// MARK: - Flight Result Card

struct FlightResultCard: View {
    let flight: Flight
    var onAddToTrip: ((Flight) -> Void)?
    
    var body: some View {
        VStack(spacing: 12) {
            // Flight route
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departure.dateTime.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(flight.departure.airport.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 4) {
                    // Stop indicator
                    if flight.stops > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundStyle(.orange)
                            Text("\(flight.stops) \(flight.stops == 1 ? "Stopp" : "Stopps")")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(.orange)
                            Image(systemName: "circle.fill")
                                .font(.system(size: 4))
                                .foregroundStyle(.orange)
                        }
                    }
                    
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(flight.stops > 0 ? .orange : .green)
                            .frame(height: 1)
                        Image(systemName: "airplane")
                            .font(.caption)
                            .foregroundStyle(flight.stops > 0 ? .orange : .green)
                        Rectangle()
                            .fill(flight.stops > 0 ? .orange : .green)
                            .frame(height: 1)
                    }
                    
                    // Direct flight indicator
                    if flight.stops == 0 {
                        Text("Direktflug")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundStyle(.green)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrival.dateTime.formatted(date: .omitted, time: .shortened))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(flight.arrival.airport.code)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Flight details
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.airline.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 4) {
                        if flight.isEstimatedDuration {
                            Image(systemName: "clock.badge.questionmark")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        Text(flight.isEstimatedDuration ? "~\(formatDuration(Int(flight.duration)))" : formatDuration(Int(flight.duration)))
                            .font(.caption)
                            .foregroundStyle(flight.isEstimatedDuration ? .orange : .secondary)
                    }
                    
                    if flight.isEstimatedDuration {
                        Text("Geschätzte Flugzeit")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                            .italic()
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text(flight.price.formatted)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    
                    if let onAddToTrip = onAddToTrip {
                        Button("Reise hinzufügen") {
                            onAddToTrip(flight)
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let mins = (seconds % 3600) / 60
        return "\(hours)h \(mins)m"
    }
}

// MARK: - Flight Detail View

struct FlightDetailView: View {
    let flight: Flight
    let onBookFlight: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var showingRouteMap = false
    
    private var departureTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter.string(from: flight.departure.dateTime)
    }
    
    private var arrivalTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        return formatter.string(from: flight.arrival.dateTime)
    }
    
    private var durationText: String {
        let hours = Int(flight.duration / 3600)
        let minutes = Int((flight.duration.truncatingRemainder(dividingBy: 3600)) / 60)
        return "\(hours)h \(minutes)m"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Flight Header Card
                VStack(spacing: 16) {
                    HStack {
                        Circle()
                            .fill(.blue.opacity(0.1))
                            .frame(width: 60, height: 60)
                            .overlay(
                                Text(flight.airline.code)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.blue)
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(flight.airline.name)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Flug \(flight.flightNumber)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("€\(Int(flight.price.amount))")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                            Text("pro Person")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
                
                // Modern Flight Route Card
                VStack(spacing: 0) {
                    // Header with gradient background
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "airplane.departure")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Text("Flugroute")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                            Spacer()
                            
                            // Flight type badge
                            HStack(spacing: 4) {
                                Image(systemName: flight.stops > 0 ? "point.3.connected.trianglepath.dotted" : "arrow.right")
                                    .font(.caption)
                                Text(flight.stops > 0 ? "\(flight.stops) Stopp" : "Direktflug")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.white.opacity(0.2))
                            .clipShape(Capsule())
                            .foregroundStyle(.white)
                        }
                        
                        // Modern Route Visualization
                        HStack(spacing: 0) {
                            // Departure
                            VStack(spacing: 6) {
                                Text(flight.departure.airport.code)
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .foregroundStyle(.white)
                                Text(flight.departure.airport.city)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Animated Flight Path
                            HStack(spacing: 4) {
                                Circle()
                                    .fill(.white)
                                    .frame(width: 6, height: 6)
                                
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(.white.opacity(0.6))
                                        .frame(width: 8, height: 2)
                                }
                                
                                Image(systemName: "airplane")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                
                                ForEach(0..<3, id: \.self) { _ in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(.white.opacity(0.6))
                                        .frame(width: 8, height: 2)
                                }
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: 6, height: 6)
                            }
                            .frame(maxWidth: .infinity)
                            
                            // Arrival
                            VStack(spacing: 6) {
                                Text(flight.arrival.airport.code)
                                    .font(.title2)
                                    .fontWeight(.black)
                                    .foregroundStyle(.white)
                                Text(flight.arrival.airport.city)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        // Time and Duration Info
                        VStack(spacing: 8) {
                            HStack {
                                Text(departureTime)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white.opacity(0.9))
                                
                                Spacer()
                                
                                VStack(spacing: 2) {
                                    Text(durationText)
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.white)
                                    Text("Flugzeit")
                                        .font(.caption2)
                                        .foregroundStyle(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Text(arrivalTime)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.white.opacity(0.9))
                            }
                        }
                    }
                    .padding(24)
                    .background(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: { showingRouteMap = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "map")
                                Text("Route anzeigen")
                            }
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(.blue)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(.blue.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Button(action: onBookFlight) {
                            Text("Flug buchen")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(16)
                    .background(Color(.systemBackground))
                }
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
            }
            .padding()
        }
        .navigationTitle("Flugdetails")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Schließen") {
                    dismiss()
                }
                .foregroundStyle(.blue)
            }
        }
        .sheet(isPresented: $showingRouteMap) {
            FlightRouteMapView(flight: flight)
        }
    }
}

// MARK: - Flight Route Map View

struct FlightRouteMapView: View {
    let flight: Flight
    @Environment(\.dismiss) private var dismiss
    
    @State private var region: MKCoordinateRegion
    
    init(flight: Flight) {
        self.flight = flight
        
        // Calculate center point between departure and arrival
        let centerLat = (flight.departure.airport.coordinates.latitude + flight.arrival.airport.coordinates.latitude) / 2
        let centerLon = (flight.departure.airport.coordinates.longitude + flight.arrival.airport.coordinates.longitude) / 2
        
        // Calculate span to fit both airports
        let latDelta = abs(flight.departure.airport.coordinates.latitude - flight.arrival.airport.coordinates.latitude) * 1.5
        let lonDelta = abs(flight.departure.airport.coordinates.longitude - flight.arrival.airport.coordinates.longitude) * 1.5
        
        self._region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: max(latDelta, 0.1), longitudeDelta: max(lonDelta, 0.1))
        ))
    }
    
    var body: some View {
        NavigationStack {
            Map {
                // Departure airport
                Annotation(flight.departure.airport.name, coordinate: CLLocationCoordinate2D(
                    latitude: flight.departure.airport.coordinates.latitude,
                    longitude: flight.departure.airport.coordinates.longitude
                )) {
                    VStack(spacing: 4) {
                        Image(systemName: "airplane.departure")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.green)
                            .clipShape(Circle())
                        Text(flight.departure.airport.code)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                }
                
                // Arrival airport
                Annotation(flight.arrival.airport.name, coordinate: CLLocationCoordinate2D(
                    latitude: flight.arrival.airport.coordinates.latitude,
                    longitude: flight.arrival.airport.coordinates.longitude
                )) {
                    VStack(spacing: 4) {
                        Image(systemName: "airplane.arrival")
                            .font(.title2)
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.red)
                            .clipShape(Circle())
                        Text(flight.arrival.airport.code)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .mapStyle(.standard)
            .navigationTitle("Flugroute")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Schließen") {
                        dismiss()
                    }
                }
            }
            .overlay(alignment: .bottom) {
                // Flight info card
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(flight.departure.airport.city) → \(flight.arrival.airport.city)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("\(flight.airline.name) • \(flight.flightNumber)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Text(flight.price.formatted)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(16)
                .padding()
            }
        }
    }
}

// MARK: - Previews

#if DEBUG
struct FlightComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PopularRoutesSection()
                .previewDisplayName("Popular Routes Section")
            
            FlightResultsSection(flights: [])
                .previewDisplayName("Flight Results Section")
        }
    }
}
#endif