//
//  SettingsView.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  Einstellungen View mit Theme-Switch und anderen App-Einstellungen
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showingAbout = false
    @State private var showingSecurityInfo = false
    
    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Design & Darstellung
                Section("Design & Darstellung") {
                    ThemePicker()
                }
                
                // MARK: - KI-Assistent
                Section("KI-Assistent") {
                    HStack {
                        Image(systemName: "brain.filled.head.profile")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("OpenAI Status")
                        
                        Spacer()
                        
                        Text("Konfiguriert")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Image(systemName: "mic.fill")
                            .foregroundColor(.red)
                            .frame(width: 24)
                        
                        Text("Spracherkennung")
                        
                        Spacer()
                        
                        Text("Aktiviert")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                
                // MARK: - API Sicherheit
                Section("API Sicherheit") {
                    Button(action: {
                        showingSecurityInfo = true
                    }) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("Sicherheitsstatus")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // MARK: - Debug
                Section("Debug") {
                    NavigationLink(destination: BackgroundImageTestView()) {
                        HStack {
                            Image(systemName: "photo.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("Background Image Test")
                        }
                    }
                }
                
                // MARK: - App Information
                Section("App Information") {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("Version")
                        
                        Spacer()
                        
                        Text("1.0.0")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Image(systemName: "heart.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("Über die App")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .scrollContentBackground(.hidden)  // Macht Form-Hintergrund durchsichtig
            .navigationTitle("Einstellungen")
            .themedBackground()
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingSecurityInfo) {
                SecurityStatusView()
            }
        }
    }
}

// MARK: - Theme Picker Component

struct ThemePicker: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(.purple)
                    .frame(width: 24)
                
                Text("App-Erscheinungsbild")
                    .font(.body)
            }
            
            HStack(spacing: 0) {
                ForEach(AppTheme.allCases, id: \.self) { theme in
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            themeManager.setTheme(theme)
                        }
                    }) {
                        VStack(spacing: 8) {
                            Image(systemName: theme.iconName)
                                .font(.title2)
                                .foregroundColor(themeManager.currentTheme == theme ? .white : .primary)
                            
                            Text(theme.displayName)
                                .font(.caption)
                                .foregroundColor(themeManager.currentTheme == theme ? .white : .secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.currentTheme == theme ? .blue : Color(.systemGray6))
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    if theme != AppTheme.allCases.last {
                        Spacer().frame(width: 8)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // App Icon
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(radius: 10)
                    
                    VStack(spacing: 8) {
                        Text("Reiseapp")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Deine intelligente Reisebegleiterin")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "brain.filled.head.profile", title: "KI-Assistent", description: "Sprachgesteuerte Reiseplanung mit OpenAI")
                        FeatureRow(icon: "mic.fill", title: "Spracherkennung", description: "Natürliche deutsche Sprachbefehle")
                        FeatureRow(icon: "bed.double.fill", title: "Hotel-Suche", description: "Finde die perfekte Unterkunft")
                        FeatureRow(icon: "airplane", title: "Flug-Suche", description: "Entdecke die besten Flugverbindungen")
                        FeatureRow(icon: "lock.shield.fill", title: "Sicherheit", description: "Alle API-Keys sind sicher verschlüsselt")
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Text("Entwickelt mit ❤️ von Nikolas Kato")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top)
                }
                .padding()
            }
            .navigationTitle("Über die App")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .themedBackground()
        }
    }
}

// MARK: - Feature Row Component

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Security Status View

struct SecurityStatusView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "lock.shield.fill")
                                .foregroundColor(.green)
                            Text("Sicherheitsstatus")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        
                        Text("Alle API-Schlüssel sind sicher über Environment Variables geladen und werden nie im Source Code gespeichert.")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(spacing: 12) {
                        SecurityRow(name: "OpenAI API", status: .secure)
                        SecurityRow(name: "OpenWeatherMap", status: .secure)
                        SecurityRow(name: "Amadeus API", status: .secure)
                        SecurityRow(name: "RapidAPI", status: .secure)
                        SecurityRow(name: "HasData API", status: .secure)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("GitHub-Sicherheit")
                            .font(.headline)
                        
                        Text("✅ Alle API-Keys sind durch .gitignore geschützt\n✅ Keine sensiblen Daten im Repository\n✅ Environment Variables werden verwendet")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
            }
            .navigationTitle("API Sicherheit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
            .themedBackground()
        }
    }
}

// MARK: - Security Row Component

enum SecurityStatus {
    case secure, warning, error
    
    var color: Color {
        switch self {
        case .secure: return .green
        case .warning: return .orange
        case .error: return .red
        }
    }
    
    var icon: String {
        switch self {
        case .secure: return "checkmark.shield.fill"
        case .warning: return "exclamationmark.shield.fill"
        case .error: return "xmark.shield.fill"
        }
    }
    
    var text: String {
        switch self {
        case .secure: return "Sicher"
        case .warning: return "Warnung"
        case .error: return "Fehler"
        }
    }
}

struct SecurityRow: View {
    let name: String
    let status: SecurityStatus
    
    var body: some View {
        HStack {
            Text(name)
                .font(.body)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: status.icon)
                    .foregroundColor(status.color)
                
                Text(status.text)
                    .font(.caption)
                    .foregroundColor(status.color)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
}