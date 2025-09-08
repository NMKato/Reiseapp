//
//  DayPlan.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI
import Foundation

struct DayPlan: Identifiable, Hashable {
    let id: UUID
    var date: Date
    var activities: [Activity]
    var checklist: [ChecklistItem]

    init(id: UUID = UUID(), date: Date, activities: [Activity] = [], checklist: [ChecklistItem] = []) {
        self.id = id
        self.date = date
        self.activities = activities
        self.checklist = checklist
    }
}
