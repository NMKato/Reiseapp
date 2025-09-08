//
//  TestView.swift
//  Reiseapp
//
//  Created by Benjamin Vodel on 08.09.25.
//

import SwiftUI

import SwiftUI

struct LoginView: View {
    @EnvironmentObject private var auth: AuthStore   // <-- für Gast-Login
    @State private var username: String = ""
    @State private var passwort: String = ""

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.darkBlue, Color.blue, Color.lightBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                // Titel
                VStack(spacing: 4) {
                    Text("Welcome to")
                        .font(.system(size: 50))
                        .foregroundStyle(.violett)
                        .shadow(color: .yellow, radius: 3, x: 0, y: 5)
                        .multilineTextAlignment(.center)
                    Text("Sunset Time")
                        .font(.system(size: 40))
                        .foregroundStyle(.violett)
                        .shadow(color: .yellow, radius: 3, x: 0, y: 5)
                }

                // Eingabefelder
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white.opacity(0.8))
                        TextField("Username eingeben", text: $username)
                            .foregroundColor(.black)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                    .overlay(Capsule().stroke(Color.blue.opacity(0.7), lineWidth: 2))
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)

                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.white.opacity(0.8))
                        SecureField("Passwort eingeben", text: $passwort)
                            .foregroundColor(.black)
                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                    .overlay(Capsule().stroke(Color.blue.opacity(0.7), lineWidth: 2))
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)

                // Gast-Login Button
                Button {
                    auth.isLoggedIn = true
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "person.fill.questionmark")
                            .imageScale(.large)
                        Text("Als Gast fortfahren")
                            .font(.headline)
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                    .overlay(Capsule().stroke(Color.blue.opacity(0.7), lineWidth: 2))
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                    .accessibilityLabel("Als Gast fortfahren")
                }

                Spacer()
            }
            .padding(.top, 40)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthStore())   // Preview
}
