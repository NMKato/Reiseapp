//
//  MapComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI
import MapKit
import Foundation

// MARK: - Hotel Map View

struct HotelMapView: View {
    let hotels: [Hotel]
    let destination: String
    @Environment(\.dismiss) private var dismiss
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var selectedHotel: Hotel?
    
    var body: some View {
        NavigationStack {
            ZStack {
                mapView
                selectedHotelOverlay
                topControls
            }
            .navigationBarHidden(true)
            .onAppear(perform: setupMapRegion)
        }
    }
    
    private var mapView: some View {
        Map {
            ForEach(hotels, id: \.id) { hotel in
                Annotation(hotel.name, coordinate: CLLocationCoordinate2D(
                    latitude: hotel.coordinates.latitude,
                    longitude: hotel.coordinates.longitude
                )) {
                    HotelMapPin(
                        hotel: hotel,
                        onTap: { handleHotelSelection(hotel) }
                    )
                }
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private var selectedHotelOverlay: some View {
        VStack {
            Spacer()
            if let selectedHotel = selectedHotel {
                HotelMapCard(hotel: selectedHotel)
                    .padding()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
    
    private var topControls: some View {
        VStack {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(.primary)
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(hotels.count) Hotels")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(destination)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(.regularMaterial)
                .cornerRadius(20)
            }
            .padding()
            
            Spacer()
        }
    }
    
    private func setupMapRegion() {
        guard !hotels.isEmpty else { return }
        
        let coordinates = hotels.map { hotel in
            CLLocationCoordinate2D(
                latitude: hotel.coordinates.latitude,
                longitude: hotel.coordinates.longitude
            )
        }
        
        let minLat = coordinates.map { $0.latitude }.min() ?? 52.5200
        let maxLat = coordinates.map { $0.latitude }.max() ?? 52.5200
        let minLon = coordinates.map { $0.longitude }.min() ?? 13.4050
        let maxLon = coordinates.map { $0.longitude }.max() ?? 13.4050
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (maxLat - minLat) * 1.3),
            longitudeDelta: max(0.01, (maxLon - minLon) * 1.3)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    private func handleHotelSelection(_ hotel: Hotel) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            selectedHotel = selectedHotel?.id == hotel.id ? nil : hotel
        }
    }
}

// MARK: - Hotel Map Card

struct HotelMapCard: View {
    let hotel: Hotel
    
    var body: some View {
        HStack(spacing: 16) {
            // Hotel Image
            AsyncImage(url: URL(string: hotel.images.first ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipped()
                    .cornerRadius(12)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.quaternary)
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "building.2.fill")
                            .foregroundStyle(.secondary)
                    )
            }
            
            // Hotel Info
            VStack(alignment: .leading, spacing: 6) {
                Text(hotel.name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .lineLimit(2)
                
                Text("\(hotel.address.street ?? "Straße nicht verfügbar"), \(hotel.address.city)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    // Rating
                    HStack(spacing: 2) {
                        ForEach(0..<5, id: \.self) { star in
                            Image(systemName: star < Int(hotel.rating ?? 0) ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundStyle(star < Int(hotel.rating ?? 0) ? .yellow : .secondary)
                        }
                    }
                    
                    Text("(\(hotel.rating ?? 0, specifier: "%.1f"))")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    // Distance (mock)
                    Text("1.2 km")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Price & Actions
            VStack(alignment: .trailing, spacing: 8) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(hotel.pricePerNight.formatted)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    Text("/Nacht")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Button("Route") {
                    // Open in Apple Maps
                    openInAppleMaps(hotel: hotel)
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.blue)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(.regularMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
    
    private func openInAppleMaps(hotel: Hotel) {
        let coordinate = CLLocationCoordinate2D(
            latitude: hotel.coordinates.latitude,
            longitude: hotel.coordinates.longitude
        )
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = hotel.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Accommodation Map View

struct AccommodationMapView: View {
    let hotels: [Hotel]
    let destination: String
    let onHotelSelected: (Hotel) -> Void
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 52.520008, longitude: 13.404954), // Berlin default
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, annotationItems: hotels) { hotel in
                MapAnnotation(coordinate: CLLocationCoordinate2D(
                    latitude: hotel.coordinates.latitude,
                    longitude: hotel.coordinates.longitude
                )) {
                    HotelMapPin(hotel: hotel) {
                        onHotelSelected(hotel)
                    }
                }
            }
            
            // Map Controls Overlay
            VStack {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(hotels.count) Unterkünfte")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text("in \(destination)")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.regularMaterial)
                    .cornerRadius(20)
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .onAppear {
            setupMapRegion()
        }
    }
    
    private func setupMapRegion() {
        guard !hotels.isEmpty else { return }
        
        let coordinates = hotels.map { hotel in
            CLLocationCoordinate2D(
                latitude: hotel.coordinates.latitude,
                longitude: hotel.coordinates.longitude
            )
        }
        
        // Calculate bounds to show all hotels
        let minLat = coordinates.map { $0.latitude }.min() ?? 52.520008
        let maxLat = coordinates.map { $0.latitude }.max() ?? 52.520008
        let minLon = coordinates.map { $0.longitude }.min() ?? 13.404954
        let maxLon = coordinates.map { $0.longitude }.max() ?? 13.404954
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.01, (maxLat - minLat) * 1.3),
            longitudeDelta: max(0.01, (maxLon - minLon) * 1.3)
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
}

// MARK: - Hotel Map Pin

struct HotelMapPin: View {
    let hotel: Hotel
    let onTap: () -> Void
    @State private var showDetails = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Pin
            Button(action: {
                showDetails.toggle()
                onTap()
            }) {
                ZStack {
                    Circle()
                        .fill(.blue)
                        .frame(width: 32, height: 32)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: "building.2.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
            
            // Price Label
            VStack(spacing: 2) {
                Text(hotel.pricePerNight.formatted)
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.blue)
                    .cornerRadius(6)
            }
            .offset(y: -4)
        }
    }
}

// MARK: - Hotel Map Detail View

struct HotelMapDetailView: View {
    let hotel: Hotel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TripMapView(
                destination: hotel.address.city,
                coordinates: hotel.coordinates
            )
            .navigationTitle("Hotel Lage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Hotel Contact Sheet

struct HotelContactSheet: View {
    let hotel: Hotel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.blue)
                    
                    Text(hotel.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 16) {
                    ContactRow(
                        icon: "location.fill", 
                        title: "Adresse", 
                        content: "\(hotel.address.street ?? "Straße nicht verfügbar")\n\(hotel.address.postalCode ?? "") \(hotel.address.city)\n\(hotel.address.country)"
                    )
                    
                    if let phone = hotel.contact?.phone {
                        ContactRow(icon: "phone.fill", title: "Telefon", content: phone)
                    }
                    
                    if let email = hotel.contact?.email {
                        ContactRow(icon: "envelope.fill", title: "E-Mail", content: email)
                    }
                    
                    if let website = hotel.contact?.website {
                        ContactRow(icon: "globe", title: "Website", content: website)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Kontakt")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Contact Row

struct ContactRow: View {
    let icon: String
    let title: String
    let content: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(content)
                    .font(.subheadline)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(.quaternary.opacity(0.5))
        .cornerRadius(12)
    }
}

// MARK: - Previews

#if DEBUG
struct MapComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HotelMapPin(hotel: Hotel.sampleHotel, onTap: {})
                .previewDisplayName("Hotel Map Pin")
            
            ContactRow(
                icon: "location.fill",
                title: "Adresse",
                content: "Musterstraße 123\n12345 Berlin\nDeutschland"
            )
            .previewDisplayName("Contact Row")
        }
    }
}

// Sample data extension for preview
extension Hotel {
    static var sampleHotel: Hotel {
        Hotel(
            id: "sample",
            name: "Sample Hotel",
            address: Address(
                street: "Musterstraße 123",
                city: "Berlin",
                postalCode: "12345",
                country: "Deutschland"
            ),
            rating: 4.5,
            pricePerNight: Price(amount: 99.99, currency: "EUR"),
            amenities: [],
            images: ["https://example.com/hotel.jpg"],
            description: "Sample hotel for preview",
            distanceFromCenter: 1.2,
            coordinates: Coordinates(
                latitude: 52.520008,
                longitude: 13.404954
            ),
            availability: true,
            roomTypes: [],
            contact: HotelContact(
                phone: "+49 30 12345678",
                email: "info@samplehotel.com",
                website: "https://www.samplehotel.com"
            )
        )
    }
}
#endif