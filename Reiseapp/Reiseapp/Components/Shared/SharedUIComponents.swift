//
//  SharedUIComponents.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Circle Category Button

struct CircleCategoryButton: View {
    let category: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : .secondary)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.blue : Color.clear)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.blue : Color(.tertiaryLabel), lineWidth: 2)
                            )
                    )
                
                Text(category)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? .primary : .secondary)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rounded Corner Shape

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Interactive Card Button Style

struct InteractiveCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.regularMaterial)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Error View

struct ErrorView: View {
    let error: Error
    let retryAction: (() -> Void)?
    
    var body: some View {
        EmptyStateView(
            icon: "exclamationmark.triangle",
            title: "Fehler aufgetreten",
            description: error.localizedDescription,
            actionTitle: retryAction != nil ? "Erneut versuchen" : nil,
            action: retryAction
        )
    }
}

// MARK: - Badge View

struct BadgeView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption2)
            .fontWeight(.semibold)
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color, in: Capsule())
    }
}

// MARK: - Rating View

struct RatingView: View {
    let rating: Double
    let maxRating: Int = 5
    let size: Font = .caption
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<maxRating, id: \.self) { index in
                Image(systemName: index < Int(rating) ? "star.fill" : "star")
                    .foregroundStyle(index < Int(rating) ? .yellow : .secondary)
                    .font(size)
            }
            
            Text("\(rating, specifier: "%.1f")")
                .font(size)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Price View

struct PriceView: View {
    let price: Double
    let currency: String
    let period: String?
    
    init(price: Double, currency: String = "€", period: String? = nil) {
        self.price = price
        self.currency = currency
        self.period = period
    }
    
    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 2) {
            Text("\(currency)\(Int(price))")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            if let period = period {
                Text(period)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Gradient Background View

struct GradientBackgroundView: View {
    let colors: [Color]
    let startPoint: UnitPoint
    let endPoint: UnitPoint
    
    init(
        colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: startPoint,
            endPoint: endPoint
        )
        .ignoresSafeArea()
    }
}


// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        CircleCategoryButton(
            category: "Hotels",
            icon: "bed.double",
            isSelected: true,
            action: {}
        )
        
        BadgeView(text: "Neu", color: .blue)
        
        RatingView(rating: 4.5)
        
        PriceView(price: 89, period: "pro Nacht")
        
        LoadingView(message: "Hotels werden geladen...")
            .frame(height: 100)
    }
    .padding()
}
