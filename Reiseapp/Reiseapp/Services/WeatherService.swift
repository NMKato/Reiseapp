//
//  WeatherService.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

protocol WeatherService {
    func forecast(for destination: String, on date: Date) async throws -> String
}

struct DummyWeatherService: WeatherService {
    func forecast(for destination: String, on date: Date) async throws -> String { "☀️ 24°" }
}
