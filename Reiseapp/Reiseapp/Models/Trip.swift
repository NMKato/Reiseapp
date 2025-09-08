//
//  Trip.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

struct Trip: Identifiable, Hashable {
    let id: UUID
    var title: String
    var startLocation: String
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var ticketPrice: Double
    var persons: [String]
    var photoData: Data?
    //var imageName: String?

    var days: [DayPlan]
    var totalPrice: Double {
        ticketPrice * Double(persons.count)
    }

    init(
        id: UUID = UUID(),
        title: String,
        startLocation: String,
        destination: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        ticketPrice: Double = 0,
        persons: [String] = [],
        photoData: Data? = nil,
     //   imageName: String? = nil,
        days: [DayPlan] = []
    ) {
        self.id = id
        self.title = title
        self.startLocation = startLocation
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.ticketPrice = ticketPrice
        self.persons = persons
        self.photoData = photoData
      //  self.imageName = imageName
        self.days = days
    }
}
