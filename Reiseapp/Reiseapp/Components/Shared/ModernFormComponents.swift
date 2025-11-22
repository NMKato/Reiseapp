//
//  ModernFormComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Modern Text Field

struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.secondary)
                .font(.title3)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.tertiary, lineWidth: 1)
        )
    }
}

// MARK: - Modern Date Field

struct ModernDateField: View {
    let title: String
    @Binding var date: Date
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "de_DE")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                    .font(.caption)
                    .frame(width: 16)
                
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            DatePicker(
                "",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.compact)
            .labelsHidden()
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Range Slider

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    let step: Double
    
    var body: some View {
        VStack(spacing: 12) {
            // Max price per night display
            HStack {
                Text("Max. Preis pro Nacht:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text("\(Int(range.upperBound))€")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(.blue)
            }
            
            // Safe range calculation helper functions
            var safeMinRange: ClosedRange<Double> {
                let maxValue = max(bounds.lowerBound + step, range.upperBound - step)
                return bounds.lowerBound...maxValue
            }
            
            var safeMaxRange: ClosedRange<Double> {
                let minValue = min(bounds.upperBound - step, range.lowerBound + step)
                return minValue...bounds.upperBound
            }
            
            // Single slider for max price (simplified approach)
            VStack(spacing: 8) {
                Slider(
                    value: Binding(
                        get: { range.upperBound },
                        set: { newValue in
                            let clampedValue = min(bounds.upperBound, max(newValue, bounds.lowerBound))
                            range = bounds.lowerBound...clampedValue
                        }
                    ),
                    in: bounds.lowerBound...bounds.upperBound,
                    step: step
                )
                .accentColor(.blue)
                
                // Range indicators
                HStack {
                    Text("\(Int(bounds.lowerBound))€")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(bounds.upperBound))€")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Modern Counter Field

struct ModernCounterField: View {
    let title: String
    let value: Int
    let onIncrement: () -> Void
    let onDecrement: () -> Void
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.primary)
            
            Spacer()
            
            HStack(spacing: 16) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle.fill")
                        .foregroundStyle(.secondary)
                        .font(.title2)
                }
                .disabled(value <= 1)
                
                Text("\(value)")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .frame(minWidth: 30)
                
                Button(action: onIncrement) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(.tertiary, lineWidth: 1)
        )
    }
}

// MARK: - Interactive Counter Field

struct InteractiveCounterField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    var body: some View {
        ModernCounterField(
            title: title,
            value: value,
            onIncrement: {
                if value < range.upperBound {
                    value += 1
                }
            },
            onDecrement: {
                if value > range.lowerBound {
                    value -= 1
                }
            }
        )
    }
}

// MARK: - Amenity Toggle

struct AmenityToggle: View {
    @Binding var isOn: Bool
    let icon: String
    let title: String
    
    var body: some View {
        Button(action: { isOn.toggle() }) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isOn ? .white : .secondary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isOn ? .white : .secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isOn ? .blue : .clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isOn ? Color.blue : Color(.tertiaryLabel), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flight Detail Row

struct FlightDetailRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Modern Rating Picker (Star Slider)

struct ModernRatingPicker: View {
    @Binding var selectedRating: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "star.circle")
                    .foregroundStyle(.secondary)
                    .font(.title3)
                
                Text("Mindestbewertung")
                    .font(.headline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if selectedRating > 0 {
                    Text("\(selectedRating)+ Sterne")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Alle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Star Slider
            HStack(spacing: 8) {
                // "Alle" option
                Button(action: { selectedRating = 0 }) {
                    Text("Alle")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(selectedRating == 0 ? .blue : .secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            selectedRating == 0 ? 
                            Color.blue.opacity(0.1) : Color.clear
                        )
                        .cornerRadius(6)
                }
                .buttonStyle(.plain)
                
                Spacer()
                
                // Interactive star rating slider
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { rating in
                        Button(action: { selectedRating = rating }) {
                            Image(systemName: selectedRating >= rating ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundStyle(selectedRating >= rating ? .yellow : .gray.opacity(0.5))
                        }
                        .buttonStyle(.plain)
                        .scaleEffect(selectedRating == rating ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.15), value: selectedRating)
                    }
                }
            }
            
            // Slider track underneath
            VStack(spacing: 4) {
                HStack(spacing: 0) {
                    // "Alle" section
                    Rectangle()
                        .fill(selectedRating == 0 ? .blue : .gray.opacity(0.2))
                        .frame(height: 2)
                        .frame(width: 30)
                    
                    Spacer()
                    
                    // Star rating track
                    HStack(spacing: 4) {
                        ForEach(1...5, id: \.self) { rating in
                            Rectangle()
                                .fill(selectedRating >= rating ? .yellow : .gray.opacity(0.2))
                                .frame(height: 2)
                                .frame(width: 24)
                        }
                    }
                }
                .cornerRadius(1)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        ModernTextField(
            icon: "magnifyingglass",
            placeholder: "Wohin geht die Reise?",
            text: .constant("")
        )
        
        ModernDateField(
            title: "Anreise",
            date: .constant(Date())
        )
        
        InteractiveCounterField(
            title: "Gäste",
            value: .constant(2),
            range: 1...10
        )
        
        AmenityToggle(
            isOn: .constant(true),
            icon: "wifi",
            title: "WLAN"
        )
        .frame(width: 80)
        
        ModernRatingPicker(
            selectedRating: .constant(4)
        )
    }
    .padding()
}