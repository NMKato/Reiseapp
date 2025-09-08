//
//  TestView.swift
//  Reiseapp
//
//  Created by Benjamin Vodel on 08.09.25.
//

import SwiftUI

struct LoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn = false
    @State private var showingAlert = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.darkBlue, Color.blue, Color.lightBlue]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    VStack(spacing: 10) {
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
                    .padding(.top, 100)
                    
                    Spacer()
                    
                    VStack(spacing: 20) {
                        TextField("Benutzername", text: $username)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                        
                        SecureField("Passwort", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal, 40)
                        
                        Button(action: {
                            // Simplified login - just check if fields are not empty
                            if !username.isEmpty && !password.isEmpty {
                                isLoggedIn = true
                            } else {
                                showingAlert = true
                            }
                        }) {
                            Text("Anmelden")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(Color.violett)
                                .cornerRadius(25)
                                .shadow(radius: 5)
                        }
                        
                        Button(action: {
                            // Skip login for demo
                            isLoggedIn = true
                        }) {
                            Text("Als Gast fortfahren")
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    Spacer()
                }
            }
            .alert("Fehler", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Bitte geben Sie Benutzername und Passwort ein")
            }
            .navigationDestination(isPresented: $isLoggedIn) {
                TripsListView(repo: MockTripRepository())
            }
        }
    }
}

#Preview {
    LoginView()
}
