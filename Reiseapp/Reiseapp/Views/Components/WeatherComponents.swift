//
//  WeatherComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct CityWeather {
    let city: String
    let temp: String
    let condition: String
    let landmark: String
    let gradient: [Color]
}

// MARK: - Weather Explore Section

struct WeatherExploreSection: View {
    let globalSearch: String
    
    private let popularDestinations = [
        "Berlin", "München", "Barcelona", "Paris", "London", "Amsterdam"
    ]
    
    private let cityLandmarks = [
        CityWeather(city: "Berlin", temp: "24°", condition: "☀️", landmark: "Brandenburger Tor", gradient: [Color.orange, Color.yellow]),
        CityWeather(city: "München", temp: "22°", condition: "⛅", landmark: "Oktoberfest", gradient: [Color.blue, Color.cyan]),
        CityWeather(city: "Barcelona", temp: "28°", condition: "☀️", landmark: "Sagrada Familia", gradient: [Color.red, Color.orange]),
        CityWeather(city: "Paris", temp: "20°", condition: "🌧️", landmark: "Eiffelturm", gradient: [Color.purple, Color.pink]),
        CityWeather(city: "London", temp: "18°", condition: "🌦️", landmark: "Big Ben", gradient: [Color.gray, Color.blue]),
        CityWeather(city: "Amsterdam", temp: "19°", condition: "☁️", landmark: "Grachten", gradient: [Color.green, Color.teal])
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Section Header
            HStack {
                Text("Wetter beliebter Reiseziele")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            // Weather Cards Grid with Landmark Backgrounds & Subtle Fade Edges
            ZStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(cityLandmarks, id: \.city) { cityWeather in
                            WeatherDestinationCard(cityWeather: cityWeather)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 4)
                }
                
                // Subtle fade edges
                HStack {
                    LinearGradient(
                        colors: [
                            Color(UIColor.systemBackground).opacity(0.9),
                            Color(UIColor.systemBackground).opacity(0.3),
                            Color.clear
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 20)
                    .allowsHitTesting(false)
                    
                    Spacer()
                    
                    LinearGradient(
                        colors: [
                            Color.clear,
                            Color(UIColor.systemBackground).opacity(0.3),
                            Color(UIColor.systemBackground).opacity(0.9)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: 20)
                    .allowsHitTesting(false)
                }
            }
            .frame(maxWidth: .infinity)
            
            // Quick Weather Search
            VStack(alignment: .leading, spacing: 12) {
                Text("Wetter für dein Reiseziel")
                    .font(.headline)
                    .padding(.horizontal)
                
                WeatherWidgetView(
                    destination: "Barcelona",
                    startDate: Date()
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
            }
        }
    }
}

// MARK: - Weather Destination Card

struct WeatherDestinationCard: View {
    let cityWeather: CityWeather
    
    var body: some View {
        VStack(spacing: 8) {
            // Beautiful Landmark Background
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: cityWeather.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 120)
                
                // Landmark Info Overlay
                VStack(spacing: 8) {
                    // Weather condition icon
                    Text(cityWeather.condition)
                        .font(.title)
                        .shadow(radius: 2)
                    
                    // Temperature
                    Text(cityWeather.temp)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                        .shadow(radius: 2)
                    
                    // Landmark name
                    Text(cityWeather.landmark)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.white.opacity(0.9))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.white.opacity(0.25))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                }
            }
            
            // City name
            Text(cityWeather.city)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
        }
        .frame(width: 160)
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
    }
}

// MARK: - Weather Search Expanded View

struct WeatherSearchExpandedView: View {
    let destination: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Wetter für \(destination)")
                .font(.headline)
            
            WeatherWidgetView(destination: destination, startDate: Date())
        }
    }
}

// MARK: - Previews

#if DEBUG
struct WeatherComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            WeatherExploreSection(globalSearch: "")
                .previewDisplayName("Weather Explore Section")
            
            WeatherDestinationCard(
                cityWeather: CityWeather(
                    city: "Berlin",
                    temp: "24°",
                    condition: "☀️",
                    landmark: "Brandenburger Tor",
                    gradient: [Color.orange, Color.yellow]
                )
            )
            .previewDisplayName("Weather Destination Card")
            
            WeatherSearchExpandedView(destination: "Barcelona")
                .previewDisplayName("Weather Search Expanded")
        }
    }
}
#endif