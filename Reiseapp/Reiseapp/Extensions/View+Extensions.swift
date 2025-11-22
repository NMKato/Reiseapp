//
//  View+Extensions.swift
//  Reiseapp
//
//  Created by Nikolas Kato on 11.09.25.
//

import SwiftUI

// MARK: - Keyboard Dismissal Extension
extension View {
    /// Hides the keyboard when tapping outside of text fields
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            let keyWindow = UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
            keyWindow?.endEditing(true)
        }
    }
}

// MARK: - Alternative implementation for iOS 15+
extension View {
    /// Modern implementation for hiding keyboard on tap
    func dismissKeyboardOnTap() -> some View {
        self.contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
    }
}

// MARK: - Enhanced Keyboard Dismissal
extension View {
    /// Enhanced keyboard dismissal that works with ScrollView and other containers
    func dismissKeyboard() -> some View {
        self.onTapGesture {
            // Hide keyboard when tapping anywhere
            hideKeyboard()
        }
    }
    
    /// Alternative keyboard dismissal for ScrollViews and complex layouts
    func dismissKeyboardOnScroll() -> some View {
        self.background(
            KeyboardDismissArea()
        )
    }
    
    /// Helper function to hide keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - Keyboard Dismissal Background View
struct KeyboardDismissArea: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject {
        @objc func handleTap() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}