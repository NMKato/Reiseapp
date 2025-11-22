//
//  LoginView.swift
//  Reiseapp
//
//  Created by Benjamin Vodel on 08.09.25.
//

import SwiftUI



struct LoginView: View {

    @EnvironmentObject private var auth: AuthStore
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var showingAlert = false
    

    var body: some View {
        ZStack {
            // Background wird jetzt über themedBackground() in ReiseappApp.swift gesetzt
            Color.clear

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

                .padding(.top, 40)
                
                Spacer()
                

                // Eingabefelder
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white.opacity(0.8))
                        TextField("Username eingeben", text: $username)

                            .foregroundColor(.white)

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
                        SecureField("Passwort eingeben", text: $password)
                            .foregroundColor(.white)

                            .autocapitalization(.none)
                    }
                    .padding()
                    .background(Capsule().fill(Color.white.opacity(0.15)))
                    .overlay(Capsule().stroke(Color.blue.opacity(0.7), lineWidth: 2))
                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal)

                
                // Login Button
                Button {
                    if !username.isEmpty && !password.isEmpty {
                        auth.isLoggedIn = true
                    } else {
                        showingAlert = true
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.right.circle.fill")
                            .imageScale(.large)
                        Text("Anmelden")
                            .font(.headline)
                    }
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(Capsule().fill(Color.violett))
                    .overlay(Capsule().stroke(Color.yellow.opacity(0.7), lineWidth: 2))
                    .shadow(color: .yellow.opacity(0.3), radius: 5, x: 0, y: 3)
                    .foregroundColor(.white)
                    .padding(.horizontal)
                }

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
            .dismissKeyboard()
        }
        .alert("Fehler", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Bitte geben Sie Benutzername und Passwort ein")

        }
    }
}

#Preview {
    LoginView()

        .environmentObject(AuthStore())
}

