//
//  MapView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import SwiftUI
import MapKit

// MARK: - Identifiable MapItem Wrapper
struct IdentifiableMapItem: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    
    init(_ mapItem: MKMapItem) {
        self.mapItem = mapItem
    }
}

// MARK: - Map View for Trip Destinations
struct TripMapView: View {
    let destination: String
    let coordinates: Coordinates?
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050), // Berlin default
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    @State private var searchResults: [IdentifiableMapItem] = []
    @State private var selectedLocation: MKMapItem?
    @State private var showingDirections = false
    @State private var routePolyline: MKPolyline?
    
    var body: some View {
        Map {
            ForEach(searchResults) { location in
                Annotation(location.mapItem.name ?? destination, 
                         coordinate: location.mapItem.placemark.coordinate) {
                    VStack {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                        
                        Text(location.mapItem.name ?? destination)
                            .font(.caption)
                            .padding(4)
                            .background(.regularMaterial)
                            .cornerRadius(4)
                    }
                    .onTapGesture {
                        selectedLocation = location.mapItem
                        showingDirections = true
                    }
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .overlay(alignment: .topTrailing) {
            VStack(spacing: 12) {
                // Search Button
                Button(action: searchDestination) {
                    Label("Suchen", systemImage: "magnifyingglass")
                        .padding(8)
                        .background(.regularMaterial)
                        .cornerRadius(8)
                }
                
                // Directions Button
                if selectedLocation != nil {
                    Button(action: openInMaps) {
                        Label("Route", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                            .padding(8)
                            .background(.regularMaterial)
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
        }
        .onAppear {
            if let coords = coordinates {
                region.center = CLLocationCoordinate2D(
                    latitude: coords.latitude,
                    longitude: coords.longitude
                )
                
                // Create a pin for the specific coordinates
                let placemark = MKPlacemark(coordinate: CLLocationCoordinate2D(
                    latitude: coords.latitude,
                    longitude: coords.longitude
                ))
                let mapItem = MKMapItem(placemark: placemark)
                mapItem.name = destination
                self.searchResults = [IdentifiableMapItem(mapItem)]
                self.selectedLocation = mapItem
            } else {
                searchDestination()
            }
        }
    }
    
    private func searchDestination() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = destination
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else { return }
            
            self.searchResults = response.mapItems.map { IdentifiableMapItem($0) }
            
            if let first = response.mapItems.first {
                self.region.center = first.placemark.coordinate
                self.selectedLocation = first
            }
        }
    }
    
    private func openInMaps() {
        guard let location = selectedLocation else { return }
        
        let mapItem = MKMapItem(placemark: location.placemark)
        mapItem.name = destination
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Route Planning View
struct RoutePlanningView: View {
    let trip: Trip
    @State private var transportMode: TransportMode = .car
    @State private var showingMap = false
    
    enum TransportMode: String, CaseIterable {
        case car = "Auto"
        case train = "Bahn"
        case plane = "Flugzeug"
        case walking = "Zu Fuß"
        
        var icon: String {
            switch self {
            case .car: return "car.fill"
            case .train: return "tram.fill"
            case .plane: return "airplane"
            case .walking: return "figure.walk"
            }
        }
        
        var mapMode: String {
            switch self {
            case .car: return MKLaunchOptionsDirectionsModeDriving
            case .train: return MKLaunchOptionsDirectionsModeTransit
            case .plane: return MKLaunchOptionsDirectionsModeDefault
            case .walking: return MKLaunchOptionsDirectionsModeWalking
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Route planen")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Wähle dein Transportmittel nach \(trip.destination)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Transport Mode Selection
            HStack(spacing: 16) {
                ForEach(TransportMode.allCases, id: \.self) { mode in
                    TransportModeButton(
                        mode: mode,
                        isSelected: transportMode == mode,
                        action: { transportMode = mode }
                    )
                }
            }
            
            // Map Preview
            RoundedRectangle(cornerRadius: 16)
                .fill(.quaternary)
                .frame(height: 200)
                .overlay(
                    ZStack {
                        if let coordinates = trip.destinationCoordinates {
                            TripMapView(
                                destination: trip.destination,
                                coordinates: coordinates
                            )
                            .cornerRadius(16)
                            .allowsHitTesting(false)
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "map.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(.secondary)
                                Text("Karte wird geladen...")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                )
                .onTapGesture {
                    showingMap = true
                }
            
            // Route Info Cards
            VStack(spacing: 12) {
                RouteInfoCard(
                    icon: "clock.fill",
                    title: "Geschätzte Reisezeit",
                    value: estimatedTime(),
                    color: .blue
                )
                
                RouteInfoCard(
                    icon: "location.fill",
                    title: "Entfernung",
                    value: "~\(Int.random(in: 200...1500)) km",
                    color: .green
                )
                
                if transportMode == .car {
                    RouteInfoCard(
                        icon: "fuelpump.fill",
                        title: "Geschätzte Kosten",
                        value: "~€\(Int.random(in: 30...150))",
                        color: .orange
                    )
                }
            }
            
            // Open in Maps Button
            Button(action: openInMaps) {
                HStack {
                    Image(systemName: "map.fill")
                    Text("In Karten öffnen")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundStyle(.white)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
        )
        .sheet(isPresented: $showingMap) {
            NavigationStack {
                TripMapView(
                    destination: trip.destination,
                    coordinates: trip.destinationCoordinates
                )
                .navigationTitle(trip.destination)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Fertig") {
                            showingMap = false
                        }
                    }
                }
            }
        }
    }
    
    private func estimatedTime() -> String {
        switch transportMode {
        case .car:
            return "\(Int.random(in: 3...12)) Stunden"
        case .train:
            return "\(Int.random(in: 4...10)) Stunden"
        case .plane:
            return "\(Int.random(in: 1...4)) Stunden"
        case .walking:
            return "\(Int.random(in: 50...200)) Stunden"
        }
    }
    
    private func openInMaps() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = trip.destination
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, _ in
            guard let response = response,
                  let location = response.mapItems.first else { return }
            
            location.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: transportMode.mapMode
            ])
        }
    }
}

// MARK: - Transport Mode Button
struct TransportModeButton: View {
    let mode: RoutePlanningView.TransportMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: mode.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .secondary)
                
                Text(mode.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? .white : .secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue : Color.secondary.opacity(0.1))
            )
        }
    }
}

// MARK: - Route Info Card
struct RouteInfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(.quaternary)
        .cornerRadius(12)
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            TripMapView(
                destination: "Barcelona",
                coordinates: Coordinates(latitude: 41.3851, longitude: 2.1734)
            )
            .frame(height: 300)
            .cornerRadius(16)
            .padding()
            
            RoutePlanningView(
                trip: Trip.demo(title: "Sommerurlaub", destination: "Barcelona")
            )
            .padding()
        }
    }
}