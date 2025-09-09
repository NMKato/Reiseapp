//
//  AddTripViewModel.swift
//  Reiseapp
//
//  Created by Florica Girisci on 08.09.25.
//

import SwiftUI
import Foundation

@MainActor
final class AddTripViewModel: ObservableObject {
    // Inputs
    @Published var title: String = ""
    @Published var destination: String = ""
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date().addingTimeInterval(86400 * 7) // 7 days later
    @Published var imageName: String = "photo.on.rectangle"

    // Validation
    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func buildTrip() -> Trip {
        Trip(
            title: title,
            destination: destination,
            startDate: startDate,
            endDate: endDate,
            imageName: imageName
        )
    }
}