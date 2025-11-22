//
//  CategorySelectionComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Category Selection Components

struct CategorySelectionView: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Was möchtest du planen?")
                .font(.headline)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 16) {
                ForEach(ExploreViewModel.TravelCategory.allCases, id: \.self) { category in
                    CategoryButton(
                        category: category,
                        isSelected: viewModel.selectedCategory == category
                    ) {
                        viewModel.selectCategory(category)
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Category Button

struct CategoryButton: View {
    let category: ExploreViewModel.TravelCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            // Add haptic feedback for better interaction
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : category.color)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(isSelected ? category.color : category.color.opacity(0.1))
                    )
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? category.color : .secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Category-Specific Content Views

struct CategoryContentView: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        switch viewModel.selectedCategory {
        case .hotels:
            HotelsCategoryContent(viewModel: viewModel)
        case .flights:
            FlightsCategoryContent(viewModel: viewModel)
        case .weather:
            WeatherCategoryContent(viewModel: viewModel)
        case .planning:
            PlanningCategoryContent(viewModel: viewModel)
        }
    }
}

// MARK: - Hotels Category Content

struct HotelsCategoryContent: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Hotel Search Section
            HotelSearchEmbedded(viewModel: viewModel, globalSearch: "")
            
            // Popular Hotels Section
            if !viewModel.popularHotels.isEmpty {
                PopularHotelsGrid(viewModel: viewModel)
            }
            
            // Search Results
            if viewModel.showResults && !viewModel.searchResults.isEmpty {
                HotelSearchResults(viewModel: viewModel)
            }
        }
    }
}

// MARK: - Flights Category Content

struct FlightsCategoryContent: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            // Flight Search Form
            VStack(alignment: .leading, spacing: 16) {
                Text("Flüge suchen")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Coming Soon - Flugsuche wird implementiert")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Weather Category Content

struct WeatherCategoryContent: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Wetter-Information")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Coming Soon - Wettervorhersage wird implementiert")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity)
                    .background(.regularMaterial)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Planning Category Content

struct PlanningCategoryContent: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reiseplanung")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Planning Features Grid
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                    ForEach(AppConfiguration.PlanningFeatures.features, id: \.id) { feature in
                        PlanningFeatureCard(feature: feature)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Planning Feature Card

struct PlanningFeatureCard: View {
    let feature: PlanningFeature
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: feature.icon)
                .font(.title2)
                .foregroundStyle(feature.color)
                .frame(width: 40, height: 40)
                .background(feature.color.opacity(0.1))
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(feature.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
        }
        .padding(16)
        .frame(height: 120)
        .background(.regularMaterial)
        .cornerRadius(12)
        .onTapGesture {
            print("Planning feature tapped: \(feature.title)")
        }
    }
}

// MARK: - Popular Hotels Grid

struct PopularHotelsGrid: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Beliebte Hotels")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Button("Alle anzeigen") {
                    // TODO: Show all popular hotels
                }
                .font(.subheadline)
                .foregroundStyle(.blue)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(Array(viewModel.popularHotels.prefix(6)), id: \.id) { hotel in
                    PopularHotelCard(hotel: hotel) {
                        // TODO: Handle hotel selection
                        print("Selected hotel: \(hotel.name)")
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .onAppear {
            if viewModel.popularHotels.isEmpty {
                viewModel.loadPopularHotels()
            }
        }
    }
}

// MARK: - Popular Hotel Card

struct PopularHotelCard: View {
    let hotel: Hotel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                AsyncImage(url: URL(string: hotel.images.first ?? "")) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(.gray.opacity(0.3))
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(.gray)
                        )
                }
                .frame(height: 100)
                .clipped()
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(hotel.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                    
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text("\(hotel.rating, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text("ab €\(Int(hotel.pricePerNight.amount))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.blue)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
        }
        .buttonStyle(.plain)
        .frame(height: 160)
        .background(.regularMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Hotel Search Results

struct HotelSearchResults: View {
    @ObservedObject var viewModel: ExploreViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Suchergebnisse")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                Text("\(viewModel.searchResults.count) Hotels gefunden")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                ForEach(viewModel.searchResults, id: \.id) { hotel in
                    PopularHotelCard(hotel: hotel) {
                        print("Selected search result: \(hotel.name)")
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Preview

#Preview {
    CategorySelectionView(viewModel: ExploreViewModel())
        .padding()
}