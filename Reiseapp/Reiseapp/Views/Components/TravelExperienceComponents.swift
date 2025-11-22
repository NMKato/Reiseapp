//
//  TravelExperienceComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI
import Foundation

// MARK: - Data Models

struct TravelEssential {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct LocalExperience {
    let title: String
    let image: String
    let price: String
    let rating: Double
}

struct TravelTip {
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Travel Essentials Section

struct TravelEssentialsSection: View {
    let destination: String
    
    private var essentials: [TravelEssential] {
        guard !destination.isEmpty else { return [] }
        
        return [
            TravelEssential(
                icon: "creditcard.fill",
                title: "Währung & Bezahlung",
                description: getCurrencyInfo(for: destination),
                color: .green
            ),
            TravelEssential(
                icon: "globe.europe.africa.fill",
                title: "Sprache",
                description: getLanguageInfo(for: destination),
                color: .blue
            ),
            TravelEssential(
                icon: "doc.text.fill",
                title: "Visa & Dokumente",
                description: getVisaInfo(for: destination),
                color: .red
            ),
            TravelEssential(
                icon: "bolt.fill",
                title: "Steckdosen",
                description: getPlugInfo(for: destination),
                color: .yellow
            )
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reise-Essentials")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ForEach(essentials, id: \.title) { essential in
                    TravelEssentialCard(essential: essential)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func getCurrencyInfo(for destination: String) -> String {
        switch destination {
        case "Paris", "Berlin", "München", "Rom", "Barcelona", "Amsterdam":
            return "Euro (EUR) • Karte überall"
        case "London":
            return "Pfund Sterling (GBP) • Kontaktlos"
        case "Zürich":
            return "Schweizer Franken (CHF)"
        default:
            return "Euro (EUR) empfohlen"
        }
    }
    
    private func getLanguageInfo(for destination: String) -> String {
        switch destination {
        case "Paris": return "Französisch • Englisch OK"
        case "Berlin", "München": return "Deutsch • Englisch gut"
        case "Rom": return "Italienisch • Englisch OK"
        case "Barcelona": return "Spanisch • Englisch OK"
        case "Amsterdam": return "Englisch perfekt"
        case "London": return "Englisch"
        default: return "Englisch meist OK"
        }
    }
    
    private func getVisaInfo(for destination: String) -> String {
        switch destination {
        case "Paris", "Berlin", "München", "Rom", "Barcelona", "Amsterdam", "Zürich":
            return "EU-Personalausweis OK"
        case "London":
            return "Reisepass nötig (Brexit)"
        default:
            return "EU-Personalausweis meist OK"
        }
    }
    
    private func getPlugInfo(for destination: String) -> String {
        switch destination {
        case "London":
            return "Typ G • Adapter nötig"
        case "Zürich":
            return "Typ C/J • Adapter nötig"
        default:
            return "Typ C/F • EU-Standard"
        }
    }
}

// MARK: - Travel Essential Card

struct TravelEssentialCard: View {
    let essential: TravelEssential
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: essential.icon)
                    .font(.title2)
                    .foregroundStyle(essential.color)
                Spacer()
            }
            
            Text(essential.title)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Text(essential.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Local Experiences Section

struct LocalExperiencesSection: View {
    let destination: String
    
    private var experiences: [LocalExperience] {
        guard !destination.isEmpty else { return [] }
        
        switch destination {
        case "Paris":
            return [
                LocalExperience(title: "Seine-Bootsfahrt", image: "ferry.fill", price: "€15", rating: 4.6),
                LocalExperience(title: "Louvre Museum", image: "building.columns.fill", price: "€22", rating: 4.8),
                LocalExperience(title: "Eiffelturm Tour", image: "building.fill", price: "€29", rating: 4.7),
                LocalExperience(title: "Montmartre Walk", image: "figure.walk", price: "€12", rating: 4.5)
            ]
        case "Berlin":
            return [
                LocalExperience(title: "Brandenburger Tor", image: "building.columns.fill", price: "kostenlos", rating: 4.7),
                LocalExperience(title: "Museum Island", image: "building.2.fill", price: "€18", rating: 4.6),
                LocalExperience(title: "Berlin Wall Tour", image: "figure.walk", price: "€15", rating: 4.8),
                LocalExperience(title: "Reichstag Dome", image: "building.fill", price: "kostenlos", rating: 4.5)
            ]
        case "Barcelona":
            return [
                LocalExperience(title: "Sagrada Familia", image: "building.columns.fill", price: "€26", rating: 4.8),
                LocalExperience(title: "Park Güell", image: "leaf.fill", price: "€13", rating: 4.6),
                LocalExperience(title: "Gothic Quarter", image: "figure.walk", price: "kostenlos", rating: 4.5),
                LocalExperience(title: "Casa Batlló", image: "building.2.fill", price: "€35", rating: 4.7)
            ]
        case "Amsterdam":
            return [
                LocalExperience(title: "Canal Cruise", image: "ferry.fill", price: "€18", rating: 4.6),
                LocalExperience(title: "Anne Frank House", image: "building.2.fill", price: "€16", rating: 4.8),
                LocalExperience(title: "Rijksmuseum", image: "building.columns.fill", price: "€22", rating: 4.7),
                LocalExperience(title: "Bike Tour", image: "bicycle", price: "€25", rating: 4.5)
            ]
        case "London":
            return [
                LocalExperience(title: "Tower Bridge", image: "building.2.fill", price: "£11", rating: 4.6),
                LocalExperience(title: "British Museum", image: "building.columns.fill", price: "kostenlos", rating: 4.8),
                LocalExperience(title: "London Eye", image: "circle.fill", price: "£32", rating: 4.4),
                LocalExperience(title: "Hyde Park", image: "leaf.fill", price: "kostenlos", rating: 4.3)
            ]
        default:
            return [
                LocalExperience(title: "Stadtführung", image: "figure.walk", price: "€15", rating: 4.5),
                LocalExperience(title: "Museum", image: "building.columns.fill", price: "€12", rating: 4.4),
                LocalExperience(title: "Altstadt", image: "building.2.fill", price: "kostenlos", rating: 4.6),
                LocalExperience(title: "Park", image: "leaf.fill", price: "kostenlos", rating: 4.3)
            ]
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Lokale Erlebnisse")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
                Button("Alle anzeigen") {}
                    .font(.caption)
                    .foregroundStyle(.blue)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(experiences, id: \.title) { experience in
                        LocalExperienceCard(experience: experience)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Local Experience Card

struct LocalExperienceCard: View {
    let experience: LocalExperience
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: experience.image)
                .font(.title)
                .foregroundStyle(.blue)
                .frame(height: 40)
            
            Text(experience.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .multilineTextAlignment(.leading)
            
            HStack {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text(String(format: "%.1f", experience.rating))
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                Text(experience.price)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.green)
            }
        }
        .padding()
        .frame(width: 150, alignment: .leading)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Travel Tips Section

struct TravelTipsSection: View {
    let destination: String
    
    private var tips: [TravelTip] {
        guard !destination.isEmpty else { return defaultTips }
        
        switch destination {
        case "Paris":
            return [
                TravelTip(icon: "clock.fill", title: "Beste Reisezeit", description: "Mai-September", color: .orange),
                TravelTip(icon: "fork.knife.circle.fill", title: "Essen", description: "Mittagspause 12-14 Uhr", color: .red),
                TravelTip(icon: "tram.fill", title: "Transport", description: "Metro-Tageskarte €7.50", color: .blue),
                TravelTip(icon: "exclamationmark.triangle.fill", title: "Sicherheit", description: "Taschendiebe beachten", color: .yellow)
            ]
        case "Berlin":
            return [
                TravelTip(icon: "clock.fill", title: "Beste Reisezeit", description: "Mai-Oktober", color: .orange),
                TravelTip(icon: "banknote.fill", title: "Bezahlen", description: "Bar noch üblich", color: .green),
                TravelTip(icon: "bicycle", title: "Transport", description: "Fahrradfreundlich", color: .blue),
                TravelTip(icon: "moon.fill", title: "Nachtleben", description: "Clubs ab 1 Uhr", color: .purple)
            ]
        case "Barcelona":
            return [
                TravelTip(icon: "clock.fill", title: "Beste Reisezeit", description: "April-Juni, Sept-Okt", color: .orange),
                TravelTip(icon: "fork.knife.circle.fill", title: "Essen", description: "Spätes Abendessen", color: .red),
                TravelTip(icon: "tram.fill", title: "Transport", description: "Metro + Bus €2.40", color: .blue),
                TravelTip(icon: "sun.max.fill", title: "Strand", description: "Barceloneta Beach", color: .cyan)
            ]
        case "Amsterdam":
            return [
                TravelTip(icon: "clock.fill", title: "Beste Reisezeit", description: "April-September", color: .orange),
                TravelTip(icon: "bicycle", title: "Transport", description: "Fahrrad mieten!", color: .blue),
                TravelTip(icon: "creditcard.fill", title: "Bezahlen", description: "Karten überall", color: .green),
                TravelTip(icon: "tram.fill", title: "Öffis", description: "GVB-Tageskarte €8.50", color: .purple)
            ]
        case "London":
            return [
                TravelTip(icon: "clock.fill", title: "Beste Reisezeit", description: "Mai-September", color: .orange),
                TravelTip(icon: "umbrella.fill", title: "Wetter", description: "Regenschirm mitnehmen", color: .blue),
                TravelTip(icon: "tram.fill", title: "Transport", description: "Oyster Card nutzen", color: .red),
                TravelTip(icon: "cup.and.saucer.fill", title: "Kultur", description: "Afternoon Tea", color: .brown)
            ]
        default:
            return defaultTips
        }
    }
    
    private var defaultTips: [TravelTip] {
        [
            TravelTip(icon: "clock.fill", title: "Beste Reisezeit", description: "Frühling/Herbst", color: .orange),
            TravelTip(icon: "creditcard.fill", title: "Bezahlen", description: "Karten akzeptiert", color: .green),
            TravelTip(icon: "tram.fill", title: "Transport", description: "Öffentliche nutzen", color: .blue),
            TravelTip(icon: "camera.fill", title: "Fotos", description: "Goldene Stunde", color: .yellow)
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Reisetipps")
                    .font(.title3)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(tips, id: \.title) { tip in
                    TravelTipCard(tip: tip)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Travel Tip Card

struct TravelTipCard: View {
    let tip: TravelTip
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: tip.icon)
                .font(.title2)
                .foregroundStyle(tip.color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(tip.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

// MARK: - Previews

#if DEBUG
struct TravelExperienceComponents_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            TravelEssentialsSection(destination: "Paris")
                .previewDisplayName("Travel Essentials Section")
            
            LocalExperiencesSection(destination: "Berlin")
                .previewDisplayName("Local Experiences Section")
            
            TravelTipsSection(destination: "Barcelona")
                .previewDisplayName("Travel Tips Section")
            
            TravelEssentialCard(
                essential: TravelEssential(
                    icon: "creditcard.fill",
                    title: "Währung",
                    description: "Euro (EUR)",
                    color: .green
                )
            )
            .previewDisplayName("Travel Essential Card")
            
            LocalExperienceCard(
                experience: LocalExperience(
                    title: "Sagrada Familia",
                    image: "building.columns.fill",
                    price: "€26",
                    rating: 4.8
                )
            )
            .previewDisplayName("Local Experience Card")
            
            TravelTipCard(
                tip: TravelTip(
                    icon: "clock.fill",
                    title: "Beste Reisezeit",
                    description: "Mai-September",
                    color: .orange
                )
            )
            .previewDisplayName("Travel Tip Card")
        }
    }
}
#endif