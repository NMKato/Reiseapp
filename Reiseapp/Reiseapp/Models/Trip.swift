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
    var destination: String
    var startDate: Date?
    var endDate: Date?
    var photoURL: URL?
    var imageName: String?

    var days: [DayPlan]

    init(
        id: UUID = UUID(),
        title: String,
        destination: String,
        startDate: Date? = nil,
        endDate: Date? = nil,
        imageName: String? = nil,
        photoURL: URL? = nil,
        days: [DayPlan] = []
    ) {
        self.id = id
        self.title = title
        self.destination = destination
        self.startDate = startDate
        self.endDate = endDate
        self.imageName = imageName
        self.photoURL = photoURL
        self.days = days
    }
}
