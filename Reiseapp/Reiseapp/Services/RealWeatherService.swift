//
//  RealWeatherService.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 09.09.25.
//

import Foundation

// OpenWeatherMap API Models
struct OpenWeatherResponse: Codable {
    let list: [OpenWeatherItem]
    let city: OpenWeatherCity
}

struct OpenWeatherItem: Codable {
    let dt: TimeInterval
    let main: OpenWeatherMain
    let weather: [OpenWeatherWeather]
    let wind: OpenWeatherWind?
    let rain: OpenWeatherRain?
    let snow: OpenWeatherSnow?
    let dtTxt: String
    
    private enum CodingKeys: String, CodingKey {
        case dt, main, weather, wind, rain, snow
        case dtTxt = "dt_txt"
    }
}

struct OpenWeatherMain: Codable {
    let temp: Double
    let tempMin: Double
    let tempMax: Double
    let humidity: Int
    
    private enum CodingKeys: String, CodingKey {
        case temp
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case humidity
    }
}

struct OpenWeatherWeather: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct OpenWeatherWind: Codable {
    let speed: Double
}

struct OpenWeatherRain: Codable {
    let threeHour: Double?
    
    private enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}

struct OpenWeatherSnow: Codable {
    let threeHour: Double?
    
    private enum CodingKeys: String, CodingKey {
        case threeHour = "3h"
    }
}

struct OpenWeatherCity: Codable {
    let name: String
    let coord: OpenWeatherCoord
    let country: String
}

struct OpenWeatherCoord: Codable {
    let lat: Double
    let lon: Double
}

// Real Weather Service Implementation
final class RealWeatherService: WeatherService {
    private let networkManager: NetworkManaging
    private let cache = CacheManager.shared
    private let rateLimiter = RateLimiter()
    
    init(networkManager: NetworkManaging = NetworkManager.shared) {
        self.networkManager = networkManager
    }
    
    func forecast(for destination: String, on date: Date) async throws -> String {
        // Simple forecast for backward compatibility
        let forecast = try await getDetailedForecast(for: destination, startDate: date, days: 1)
        if let firstDay = forecast.forecasts.first {
            return "\(firstDay.condition.emoji) \(firstDay.temperatureMaxCelsius)"
        }
        return "☀️ 24°"
    }
    
    func getDetailedForecast(for destination: String, startDate: Date, days: Int = 5) async throws -> WeatherForecast {
        // Check cache first
        let cacheKey = "weather_\(destination)_\(startDate.timeIntervalSince1970)"
        if let cachedData = cache.getCachedData(for: cacheKey),
           let forecast = try? JSONDecoder().decode(WeatherForecast.self, from: cachedData) {
            // Return cached data if less than 1 hour old
            if forecast.lastUpdated.timeIntervalSinceNow > -3600 {
                return forecast
            }
        }
        
        // Rate limiting - max 1 request per second
        guard rateLimiter.shouldAllowRequest(for: "weather", minimumInterval: 1.0) else {
            throw NetworkError.rateLimitExceeded
        }
        
        // Check for API key
        guard !APIConfiguration.APIKeys.openWeatherMap.isEmpty,
              APIConfiguration.APIKeys.openWeatherMap != "YOUR_OPENWEATHER_API_KEY" else {
            // Return mock data if no API key
            return createMockForecast(for: destination, startDate: startDate, days: days)
        }
        
        // Create endpoint
        let endpoint = Endpoint(
            baseURL: APIConfiguration.shared.baseURLs.weather,
            path: "/forecast",
            queryItems: [
                URLQueryItem(name: "q", value: destination),
                URLQueryItem(name: "appid", value: APIConfiguration.APIKeys.openWeatherMap),
                URLQueryItem(name: "units", value: "metric"),
                URLQueryItem(name: "cnt", value: String(days * 8)) // 8 forecasts per day (3-hour intervals)
            ]
        )
        
        // Fetch data
        let response = try await networkManager.request(endpoint, type: OpenWeatherResponse.self)
        
        // Convert to our model
        let forecast = convertToWeatherForecast(response, destination: destination)
        
        // Cache the result
        if let encoded = try? JSONEncoder().encode(forecast) {
            cache.cache(data: encoded, for: cacheKey)
        }
        
        return forecast
    }
    
    private func convertToWeatherForecast(_ response: OpenWeatherResponse, destination: String) -> WeatherForecast {
        // Group forecasts by day
        var dailyForecasts: [Date: [OpenWeatherItem]] = [:]
        let calendar = Calendar.current
        
        for item in response.list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayStart = calendar.startOfDay(for: date)
            dailyForecasts[dayStart, default: []].append(item)
        }
        
        // Convert to DailyWeather
        let forecasts = dailyForecasts.sorted { $0.key < $1.key }.compactMap { date, items -> DailyWeather? in
            guard !items.isEmpty else { return nil }
            
            let temps = items.map { $0.main.temp }
            let minTemp = items.map { $0.main.tempMin }.min() ?? 0
            let maxTemp = items.map { $0.main.tempMax }.max() ?? 0
            let avgHumidity = items.reduce(0) { $0 + $1.main.humidity } / items.count
            let avgWind = items.compactMap { $0.wind?.speed }.reduce(0, +) / Double(items.count)
            
            // Get most common weather condition
            let conditions = items.compactMap { $0.weather.first?.main }
            let conditionCounts = Dictionary(grouping: conditions, by: { $0 }).mapValues { $0.count }
            let mostCommon = conditionCounts.max(by: { $0.value < $1.value })?.key ?? "Clear"
            
            // Calculate precipitation
            let rain = items.compactMap { $0.rain?.threeHour }.reduce(0, +)
            let snow = items.compactMap { $0.snow?.threeHour }.reduce(0, +)
            
            return DailyWeather(
                date: date,
                temperatureMin: minTemp,
                temperatureMax: maxTemp,
                temperatureCurrent: temps.first,
                condition: WeatherCondition(rawValue: mostCommon) ?? .clear,
                humidity: avgHumidity,
                windSpeed: avgWind,
                precipitation: rain + snow,
                icon: items.first?.weather.first?.icon ?? "01d"
            )
        }
        
        return WeatherForecast(
            location: destination,
            forecasts: forecasts,
            lastUpdated: Date()
        )
    }
    
    private func createMockForecast(for destination: String, startDate: Date, days: Int) -> WeatherForecast {
        let calendar = Calendar.current
        var forecasts: [DailyWeather] = []
        
        for dayOffset in 0..<days {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) ?? startDate
            let temp = Double.random(in: 15...28)
            
            forecasts.append(DailyWeather(
                date: date,
                temperatureMin: temp - 5,
                temperatureMax: temp + 5,
                temperatureCurrent: temp,
                condition: [.clear, .clouds, .rain].randomElement() ?? .clear,
                humidity: Int.random(in: 40...80),
                windSpeed: Double.random(in: 5...20),
                precipitation: Double.random(in: 0...10),
                icon: "01d"
            ))
        }
        
        return WeatherForecast(
            location: destination,
            forecasts: forecasts,
            lastUpdated: Date()
        )
    }
}