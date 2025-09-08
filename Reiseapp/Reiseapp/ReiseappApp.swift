//
//  TravelApp.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI

@main
struct TravelApp: App {
  //  @StateObject private var tripsView.tripStore = TripStore()

    var body: some Scene {
        WindowGroup {
            LoginView()
             //   .environmentObject(tripStore)
        }
    }
}
