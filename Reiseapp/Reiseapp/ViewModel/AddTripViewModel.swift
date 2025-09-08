//
//  AddTripViewModel.swift
//  Reiseapp
//
//  Created by Florica Girisci on 08.09.25.
//

import SwiftUI
import Foundation
import UIKit

@MainActor
final class AddTripViewModel: ObservableObject {
    // Inputs
    @Published var title: String = ""
    @Published var startLocation: String = ""
    @Published var destination: String = ""
    @Published var departureDate: Date = Date()
    @Published var ticketPriceText: String = ""
    @Published var persons: [String] = []
    @Published var newPerson: String = ""
    @Published var photoData: Data? = nil

    // Derived
    var ticketPrice: Double { Double(ticketPriceText.replacingOccurrences(of: ",", with: ".")) ?? 0 }
    var totalPrice: Double { ticketPrice * Double(persons.count) }

    var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !startLocation.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func addPerson() {
        let p = newPerson.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !p.isEmpty else { return }
        persons.append(p)
        newPerson = ""
    }

    func removePersons(at offsets: IndexSet) {
        persons.remove(atOffsets: offsets)
    }

    func buildTrip() -> Trip {
        Trip(
            title: title,
            startLocation: startLocation,
            destination: destination,
            startDate: departureDate,
            ticketPrice: ticketPrice,
            persons: persons,
            photoData: photoData
        )
    }
}

