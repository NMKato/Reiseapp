//
//  RootView.swift
//  Reiseapp
//
//  Created by Waldemar Dietler on 08.09.25.
//

import SwiftUI

struct RootView: View {
    @ObservedObject private var env: AppEnvironment
    
    init(appEnvironment: AppEnvironment? = nil) {
        self.env = appEnvironment ?? AppEnvironment.live
    }

    var body: some View {
        TabView(selection: Binding(
            get: { env.selectedTab },
            set: { env.selectedTab = $0 }
        )) {
            NavigationStack { TripsListView(repo: env.tripRepository) }
                .tabItem { Label("Reisen", systemImage: "list.bullet") }
                .tag(0)

            ExploreView()
                .tabItem { Label("Entdecken", systemImage: "globe") }
                .tag(1)

            SettingsView()
                .tabItem { Label("Einstellungen", systemImage: "gearshape") }
                .tag(2)
        }
        .onAppear {
            // Mache TabView-Hintergrund durchsichtig für themed background
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .environment(\.appEnvironment, env)
    }
}
#Preview {
    RootView(appEnvironment: .preview)
        .environment(\.appEnvironment, .preview)
}
