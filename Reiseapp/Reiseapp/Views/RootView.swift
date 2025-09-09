//
//  RootView.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI

struct RootView: View {
    @Environment(\.appEnvironment) private var env

    var body: some View {
        TabView {
            NavigationStack { TripsListView(repo: env.tripRepository) }
                .tabItem { Label("Reisen", systemImage: "list.bullet") }

            NavigationStack { Text("Explore (später)") }
                .tabItem { Label("Entdecken", systemImage: "globe") }

            NavigationStack { Text("Einstellungen (später)") }
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
        }
    }
}
#Preview {
    RootView()
        .environment(\.appEnvironment, .preview)
}
