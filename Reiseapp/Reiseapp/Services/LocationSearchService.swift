//
//  LocationSearchService.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation
// Später: MKLocalSearch einbauen
protocol LocationSearchService {
    func suggest(query: String) async throws -> [String]
}

struct DummyLocationSearchService: LocationSearchService {
    func suggest(query: String) async throws -> [String] { [] }
}
