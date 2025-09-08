//
//  TestView.swift
//  Reiseapp
//
//  Created by Benjamin Vodel on 08.09.25.
//

import SwiftUI

struct LoginView: View {
    @State var textField1: String = ""
    @State var textField2: String = ""
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.darkBlue, Color.blue, Color.lightBlue]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack{
                Text("Welcome to")
                    .font(.system(size: 50))
                    .foregroundStyle(.violett)
                    .shadow(color: .yellow, radius: 3, x: 0, y: 5)
                    .multilineTextAlignment(.center)
                Text("Sunset Time")
                    .font(.system(size: 40))
                    .foregroundStyle(.violett)
                    .shadow(color: .yellow, radius: 3, x: 0, y: 5)
                Spacer()
            }
            
            
            
        }
    }
}

#Preview {
    LoginView()
}
