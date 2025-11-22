//
//  PlanningComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct PlanningFeature: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

// MARK: - Category Tab Button

struct CategoryTabButton: View {
    let category: ExploreViewModel.TravelCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(isSelected ? category.color.opacity(0.2) : Color.clear)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isSelected ? category.color : Color.secondary.opacity(0.3), lineWidth: 2)
                        )
                    
                    Image(systemName: category.icon)
                        .font(.title3)
                        .foregroundStyle(isSelected ? category.color : .secondary)
                }
                
                Text(category.rawValue)
                    .font(.caption)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? category.color : .secondary)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

// MARK: - Planning Section

struct PlanningSection: View {
    private let planningFeatures = [
        PlanningFeature(
            title: "Trip Planer",
            subtitle: "Erstelle detaillierte Reisepläne",
            icon: "map.fill",
            color: .green
        ),
        PlanningFeature(
            title: "Budget Tracker",
            subtitle: "Behalte deine Ausgaben im Blick",
            icon: "eurosign.circle.fill",
            color: .blue
        ),
        PlanningFeature(
            title: "Packing Liste",
            subtitle: "Vergiss nichts Wichtiges",
            icon: "checkmark.circle.fill",
            color: .purple
        ),
        PlanningFeature(
            title: "Dokumente",
            subtitle: "Alle wichtigen Papiere",
            icon: "doc.fill",
            color: .orange
        )
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            HStack {
                Text("Reiseplanung")
                    .font(.headline)
                Spacer()
            }
            .padding(.horizontal)
            
            // Planning Features Grid
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 160), spacing: 16)
            ], spacing: 16) {
                ForEach(planningFeatures) { feature in
                    PlanningFeatureCard(feature: feature)
                }
            }
            .padding(.horizontal)
            
            // Quick Actions
            VStack(alignment: .leading, spacing: 16) {
                Text("Schnellaktionen")
                    .font(.headline)
                    .padding(.horizontal)
                
                VStack(spacing: 8) {
                    QuickActionRow(title: "Neue Reise planen", icon: "plus.circle.fill", color: .blue)
                    QuickActionRow(title: "Bestehende Reise bearbeiten", icon: "pencil.circle.fill", color: .green)
                    QuickActionRow(title: "Reise-Checkliste", icon: "checkmark.square.fill", color: .orange)
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Planning Feature Card

struct PlanningFeatureCard: View {
    let feature: PlanningFeature
    
    var body: some View {
        Button(action: {}) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(feature.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: feature.icon)
                        .font(.title2)
                        .foregroundStyle(feature.color)
                }
                
                VStack(spacing: 4) {
                    Text(feature.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(feature.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial)
            .cornerRadius(16)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Action Row

struct QuickActionRow: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.quaternary)
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Search Sheet

struct QuickSearchSheet: View {
    @Binding var searchText: String
    @Environment(\.dismiss) private var dismiss
    @State private var suggestions = [
        "Barcelona", "Paris", "London", "Rom", "Amsterdam",
        "Berlin", "München", "Hamburg", "Wien", "Zürich"
    ]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                // Search Field
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Reiseziel eingeben...", text: $searchText)
                        .textFieldStyle(.plain)
                    
                    if !searchText.isEmpty {
                        Button(action: { searchText = "" }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(.quaternary)
                .cornerRadius(12)
                
                // Popular Destinations
                VStack(alignment: .leading, spacing: 12) {
                    Text("Beliebte Reiseziele")
                        .font(.headline)
                    
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100), spacing: 12)
                    ], spacing: 12) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                searchText = suggestion
                                dismiss()
                            }) {
                                Text(suggestion)
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(.quaternary)
                                    .cornerRadius(20)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Reiseziel suchen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Fertig") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Planning Expanded View

struct PlanningExpandedView: View {
    let destination: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Reise nach \(destination) planen")
                .font(.headline)
            
            Text("Hier können Sie Ihre komplette Reise planen")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews

#if DEBUG
struct PlanningComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            PlanningSection()
                .previewDisplayName("Planning Section")
            
            PlanningFeatureCard(
                feature: PlanningFeature(
                    title: "Trip Planer",
                    subtitle: "Erstelle detaillierte Reisepläne",
                    icon: "map.fill",
                    color: .green
                )
            )
            .previewDisplayName("Planning Feature Card")
            
            QuickActionRow(
                title: "Neue Reise planen",
                icon: "plus.circle.fill",
                color: .blue
            )
            .previewDisplayName("Quick Action Row")
            
            QuickSearchSheet(searchText: .constant(""))
                .previewDisplayName("Quick Search Sheet")
            
            PlanningExpandedView(destination: "Barcelona")
                .previewDisplayName("Planning Expanded View")
        }
    }
}
#endif