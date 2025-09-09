//
//  Activity.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

struct Activity: Identifiable, Hashable,Codable {
    let id: UUID
    var title: String
    var notes: String?
    var time: Date?

    init(id: UUID = UUID(), title: String, notes: String? = nil, time: Date? = nil) {
        self.id = id
        self.title = title
        self.notes = notes
        self.time = time
    }
}
