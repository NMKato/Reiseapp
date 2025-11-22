//
//  HotelSearchComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Hotel Search Components

struct HotelSearchEmbedded: View {
    @ObservedObject var viewModel: ExploreViewModel
    let globalSearch: String
    @State private var showingFullSearch = false
    
    var body: some View {
        VStack(spacing: 24) {
            // Beautiful Hotel Search Card
            VStack(spacing: 20) {
                // Header with Icon
                HStack {
                    HStack(spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.title2)
                            .foregroundStyle(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hotels finden")
                                .font(.title3)
                                .fontWeight(.bold)
                            Text("Unterkünfte für deine Reise")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Button("Erweitert") {
                        showingFullSearch = true
                    }
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.blue)
                }
                
                // Quick Search Input
                VStack(spacing: 16) {
                    ModernTextField(
                        icon: "magnifyingglass",
                        placeholder: "Wohin geht die Reise?",
                        text: $viewModel.destinationInput
                    )
                    
                    HStack(spacing: 12) {
                        ModernDateField(
                            title: "Anreise",
                            date: $viewModel.checkInDate
                        )
                        
                        ModernDateField(
                            title: "Abreise", 
                            date: $viewModel.checkOutDate
                        )
                    }
                    
                    HStack(spacing: 12) {
                        InteractiveCounterField(
                            title: "Gäste",
                            value: $viewModel.guests,
                            range: 1...10
                        )
                        
                        InteractiveCounterField(
                            title: "Zimmer",
                            value: $viewModel.rooms,
                            range: 1...5
                        )
                    }
                }
                
                // Search Button
                Button(action: {
                    viewModel.startHotelSearch()
                }) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.subheadline)
                        Text("Hotels suchen")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.blue)
                    .cornerRadius(12)
                }
                .disabled(viewModel.destinationInput.isEmpty || viewModel.isSearching)
                .opacity(viewModel.destinationInput.isEmpty ? 0.6 : 1.0)
                
                if viewModel.isSearching {
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Suche nach Hotels...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                    .cornerRadius(8)
                }
            }
            .padding(24)
            .background(.regularMaterial)
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .sheet(isPresented: $showingFullSearch) {
            HotelSearchFullView(viewModel: viewModel)
        }
    }
}

// MARK: - Hotel Search Full View

struct HotelSearchFullView: View {
    @ObservedObject var viewModel: ExploreViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Basic Search Fields
                    VStack(spacing: 16) {
                        ModernTextField(
                            icon: "magnifyingglass",
                            placeholder: "Wohin geht die Reise?",
                            text: $viewModel.destinationInput
                        )
                        
                        HStack(spacing: 12) {
                            ModernDateField(
                                title: "Anreise",
                                date: $viewModel.checkInDate
                            )
                            
                            ModernDateField(
                                title: "Abreise",
                                date: $viewModel.checkOutDate
                            )
                        }
                        
                        HStack(spacing: 12) {
                            InteractiveCounterField(
                                title: "Gäste",
                                value: $viewModel.guests,
                                range: 1...10
                            )
                            
                            InteractiveCounterField(
                                title: "Zimmer",
                                value: $viewModel.rooms,
                                range: 1...5
                            )
                        }
                    }
                    
                    // Price Range
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Preis pro Nacht")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Toggle("", isOn: $viewModel.usePriceFilter)
                                .labelsHidden()
                        }
                        
                        if viewModel.usePriceFilter {
                            VStack(spacing: 8) {
                                HStack {
                                    Text("€\(Int(viewModel.priceRange.lowerBound))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Spacer()
                                    Text("€\(Int(viewModel.priceRange.upperBound))")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                }
                                
                                RangeSlider(range: $viewModel.priceRange, bounds: 0...11000, step: 50)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(.regularMaterial)
                    .cornerRadius(16)
                    
                    // Amenities
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Ausstattung")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            AmenityToggle(isOn: $viewModel.hasWiFi, icon: "wifi", title: "WLAN")
                            AmenityToggle(isOn: $viewModel.hasKitchen, icon: "cooktop", title: "Küche")
                            AmenityToggle(isOn: $viewModel.hasParking, icon: "car", title: "Parkplatz")
                            AmenityToggle(isOn: $viewModel.hasAirConditioning, icon: "wind", title: "Klimaanlage")
                            AmenityToggle(isOn: $viewModel.hasWashingMachine, icon: "washer", title: "Waschmaschine")
                            AmenityToggle(isOn: $viewModel.isPetFriendly, icon: "pawprint", title: "Haustierfreundlich")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 20)
                    .background(.regularMaterial)
                    .cornerRadius(16)
                    
                    // Search Button
                    Button(action: {
                        viewModel.startHotelSearch()
                        dismiss()
                    }) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            Text("Hotels suchen")
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.blue)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.destinationInput.isEmpty)
                }
                .padding(20)
            }
            .navigationTitle("Hotelsuche")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Range Slider Helper

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        // Simplified range slider implementation
        HStack {
            Text("€\(Int(range.lowerBound))")
                .font(.caption)
            Slider(value: .constant(range.upperBound), in: bounds)
            Text("€\(Int(range.upperBound))")
                .font(.caption)
        }
    }
}

// MARK: - Preview

#Preview {
    HotelSearchEmbedded(
        viewModel: ExploreViewModel(),
        globalSearch: "Berlin"
    )
    .padding()
}