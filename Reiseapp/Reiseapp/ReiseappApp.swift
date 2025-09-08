//
//  ReiseappApp.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.



import SwiftUI

final class AuthStore: ObservableObject {
    @Published var isLoggedIn = false
}

@main
struct TravelPlannerApp: App {
    @StateObject private var auth = AuthStore()

    var body: some Scene {
        WindowGroup {
            Group {
                if auth.isLoggedIn {
                    RootView()
                } else {
                    LoginView()
                }
            }
        
            .environment(\.appEnvironment, .live)
            .environmentObject(auth)
        }
    }
}
