//
//  WeatherWidgetView.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import SwiftUI

struct WeatherWidgetView: View {
    let destination: String
    let startDate: Date?
    @State private var weatherForecast: WeatherForecast?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedDay: DailyWeather?
    
    private let weatherService = RealWeatherService()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Wettervorhersage", systemImage: "cloud.sun.fill")
                    .font(.headline)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                if isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if let forecast = weatherForecast {
                // Current/First day highlight
                if let today = forecast.forecasts.first {
                    CurrentWeatherCard(weather: today)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedDay = selectedDay == today ? nil : today
                            }
                        }
                }
                
                // 5-Day Forecast with Subtle Fade Edges
                ZStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(forecast.forecasts.prefix(5)) { day in
                                DailyWeatherCard(weather: day, isSelected: selectedDay?.id == day.id)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedDay = selectedDay?.id == day.id ? nil : day
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 16)
                    }
                    
                    // Subtle fade edges for smooth scrolling
                    HStack {
                        LinearGradient(
                            colors: [
                                Color(UIColor.systemBackground).opacity(0.8),
                                Color(UIColor.systemBackground).opacity(0.2),
                                Color.clear
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 16)
                        .allowsHitTesting(false)
                        
                        Spacer()
                        
                        LinearGradient(
                            colors: [
                                Color.clear,
                                Color(UIColor.systemBackground).opacity(0.2),
                                Color(UIColor.systemBackground).opacity(0.8)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .frame(width: 16)
                        .allowsHitTesting(false)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Selected day details
                if let selected = selectedDay {
                    WeatherDetailCard(weather: selected)
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
                
            } else if let error = errorMessage {
                // Error state
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                
            } else {
                // Empty state
                VStack(spacing: 8) {
                    Image(systemName: "cloud.sun")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text("Wetter wird geladen...")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.05), radius: 10, y: 5)
        )
        .task {
            await loadWeather()
        }
    }
    
    private func loadWeather() async {
        guard let startDate = startDate else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let forecast = try await weatherService.getDetailedForecast(
                for: destination,
                startDate: startDate,
                days: 5
            )
            
            await MainActor.run {
                withAnimation(.easeInOut) {
                    self.weatherForecast = forecast
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Wetter konnte nicht geladen werden"
                self.isLoading = false
            }
        }
    }
}

// Current Weather Card
struct CurrentWeatherCard: View {
    let weather: DailyWeather
    
    var body: some View {
        HStack(spacing: 20) {
            // Temperature & Condition
            VStack(alignment: .leading, spacing: 4) {
                Text(weather.condition.emoji)
                    .font(.system(size: 40))
                
                HStack(alignment: .top, spacing: 4) {
                    Text("\(Int(weather.temperatureMax))°")
                        .font(.system(size: 36, weight: .semibold, design: .rounded))
                    
                    VStack(alignment: .leading) {
                        Text("H: \(weather.temperatureMaxCelsius)")
                            .font(.caption)
                        Text("L: \(weather.temperatureMinCelsius)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(weather.condition.rawValue)
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Additional Info
            VStack(alignment: .trailing, spacing: 12) {
                InfoRow(icon: "humidity.fill", value: "\(weather.humidity)%", color: .blue)
                InfoRow(icon: "wind", value: "\(Int(weather.windSpeed)) km/h", color: .teal)
                if weather.precipitation > 0 {
                    InfoRow(icon: "drop.fill", value: "\(Int(weather.precipitation)) mm", color: .cyan)
                }
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: gradientColors(for: weather.condition),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(0.15)
        )
        .cornerRadius(16)
    }
    
    private func gradientColors(for condition: WeatherCondition) -> [Color] {
        switch condition {
        case .clear: return [.yellow, .orange]
        case .clouds: return [.gray, .gray.opacity(0.5)]
        case .rain: return [.blue, .cyan]
        case .snow: return [.white, .blue.opacity(0.3)]
        case .thunderstorm: return [.purple, .indigo]
        case .drizzle: return [.blue.opacity(0.5), .cyan.opacity(0.5)]
        case .mist: return [.gray.opacity(0.3), .gray.opacity(0.1)]
        }
    }
}

// Daily Weather Card
struct DailyWeatherCard: View {
    let weather: DailyWeather
    let isSelected: Bool
    
    private var dayFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dayFormatter.string(from: weather.date))
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
            
            Text(weather.condition.emoji)
                .font(.title2)
            
            Text(weather.temperatureMaxCelsius)
                .font(.callout)
                .fontWeight(.medium)
            
            Text(weather.temperatureMinCelsius)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(width: 65)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : Color.secondary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isSelected ? 1.05 : 1.0)
    }
}

// Weather Detail Card
struct WeatherDetailCard: View {
    let weather: DailyWeather
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d. MMMM"
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(dateFormatter.string(from: weather.date))
                .font(.subheadline)
                .fontWeight(.medium)
            
            HStack(spacing: 20) {
                DetailItem(icon: "thermometer.high", label: "Max", value: weather.temperatureMaxCelsius)
                DetailItem(icon: "thermometer.low", label: "Min", value: weather.temperatureMinCelsius)
                DetailItem(icon: "humidity", label: "Feuchtigkeit", value: "\(weather.humidity)%")
                DetailItem(icon: "wind", label: "Wind", value: "\(Int(weather.windSpeed)) km/h")
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// Helper Views
struct InfoRow: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(value)
                .font(.caption)
                .foregroundStyle(.primary)
        }
    }
}

struct DetailItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ScrollView {
        WeatherWidgetView(
            destination: "Barcelona",
            startDate: Date()
        )
        .padding()
    }
}