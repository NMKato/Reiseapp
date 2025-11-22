//
//  ThemeManager.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  Theme Management für Light/Dark Mode mit Hintergrundbildern
//

import SwiftUI
import Foundation

// MARK: - Theme Types

enum AppTheme: String, CaseIterable {
    case light = "light"
    case dark = "dark"
    case system = "system"
    
    var displayName: String {
        switch self {
        case .light:
            return "Hell"
        case .dark:
            return "Dunkel"
        case .system:
            return "System"
        }
    }
    
    var iconName: String {
        switch self {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "circle.lefthalf.filled"
        }
    }
}

// MARK: - Theme Manager

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var currentTheme: AppTheme = .system {
        didSet {
            saveTheme()
            applyTheme()
        }
    }
    
    @Published var isDarkMode: Bool = false
    
    private let themeKey = "selectedAppTheme"
    
    init() {
        print("🔄 ThemeManager: Initializing...")
        loadTheme()
        applyTheme()
        
        // Listen for system appearance changes
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.applyTheme()
        }
    }
    
    private func loadTheme() {
        if let savedTheme = UserDefaults.standard.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme) {
            currentTheme = theme
            print("🔄 ThemeManager: Loaded saved theme: \(theme)")
        } else {
            currentTheme = .system
            print("🔄 ThemeManager: No saved theme, using system default")
        }
    }
    
    private func saveTheme() {
        UserDefaults.standard.set(currentTheme.rawValue, forKey: themeKey)
    }
    
    private func applyTheme() {
        DispatchQueue.main.async {
            let newDarkModeState: Bool
            switch self.currentTheme {
            case .light:
                newDarkModeState = false
            case .dark:
                newDarkModeState = true
            case .system:
                // Folge dem System-Theme
                newDarkModeState = UITraitCollection.current.userInterfaceStyle == .dark
            }
            
            if self.isDarkMode != newDarkModeState {
                print("🎨 Theme: Switching to \(newDarkModeState ? "Dark" : "Light") mode")
                self.isDarkMode = newDarkModeState
            }
        }
    }
    
    func setTheme(_ theme: AppTheme) {
        currentTheme = theme
    }
    
    // MARK: - Background Images
    
    var backgroundImageName: String {
        let imageName = isDarkMode ? "miraTrip_Back_dark_01" : "miraTrip_Back_light_01"
        print("🎨 Theme: Loading background image: \(imageName), isDarkMode: \(isDarkMode)")
        return imageName
    }
    
    // MARK: - Theme Colors
    
    var backgroundColor: Color {
        return isDarkMode ? Color.black : Color.white
    }
    
    var primaryTextColor: Color {
        return isDarkMode ? Color.white : Color.black
    }
    
    var secondaryTextColor: Color {
        return isDarkMode ? Color.gray : Color.secondary
    }
    
    var cardBackgroundColor: Color {
        return isDarkMode ? Color(.systemGray6) : Color.white
    }
    
    var navigationBackgroundColor: Color {
        return isDarkMode ? Color(.systemGray6) : Color(.systemGray6)
    }
}

// MARK: - View Extensions

extension View {
    func themedBackground() -> some View {
        self.background(
            ThemedBackgroundImageView()
        )
    }
}

// MARK: - Simple Background Image View

struct ThemedBackgroundImageView: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            if let uiImage = UIImage(named: themeManager.backgroundImageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .clipped()
                    .onAppear {
                        print("🖼️ SUCCESS: Loading \(themeManager.backgroundImageName)")
                        print("🖼️ Image size: \(uiImage.size)")
                        print("🖼️ Geometry: \(geometry.size)")
                    }
            } else {
                Rectangle()
                    .fill(themeManager.isDarkMode ? Color.black : Color.white)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height
                    )
                    .onAppear {
                        print("❌ FAILED to load image: \(themeManager.backgroundImageName)")
                    }
            }
        }
        .ignoresSafeArea()
    }
}


extension View {
    func themedCard() -> some View {
        ThemedCardWrapper {
            self
        }
    }
}

// MARK: - Themed Card Wrapper

struct ThemedCardWrapper<Content: View>: View {
    @StateObject private var themeManager = ThemeManager.shared
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.cardBackgroundColor)
                    .shadow(
                        color: themeManager.isDarkMode ? .white.opacity(0.1) : .black.opacity(0.1),
                        radius: 8,
                        x: 0,
                        y: 2
                    )
            )
    }
}

// MARK: - Environment Key

struct ThemeEnvironmentKey: EnvironmentKey {
    static let defaultValue = ThemeManager.shared
}

extension EnvironmentValues {
    var themeManager: ThemeManager {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}