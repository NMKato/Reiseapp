//
//  BackgroundImageTest.swift
//  Reiseapp
//
//  Created by Nikolas Kato
//
//  Simple Test View to debug background image loading
//

import SwiftUI

struct BackgroundImageTestView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🧪 Background Image Test")
                    .font(.title)
                    .padding()
                
                Group {
                    Text("Light Image Test:")
                    if let lightImage = UIImage(named: "miraTrip_Back_light_01") {
                        Image(uiImage: lightImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                        Text("✅ Light image found! Size: \(Int(lightImage.size.width))x\(Int(lightImage.size.height))")
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Light image NOT found")
                            .foregroundColor(.red)
                    }
                }
                
                Group {
                    Text("Dark Image Test:")
                    if let darkImage = UIImage(named: "miraTrip_Back_dark_01") {
                        Image(uiImage: darkImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .cornerRadius(10)
                        Text("✅ Dark image found! Size: \(Int(darkImage.size.width))x\(Int(darkImage.size.height))")
                            .foregroundColor(.green)
                    } else {
                        Text("❌ Dark image NOT found")
                            .foregroundColor(.red)
                    }
                }
                
                Group {
                    Text("Direct SwiftUI Image Test:")
                    
                    HStack {
                        VStack {
                            Text("Light (SwiftUI)")
                            Image("miraTrip_Back_light_01")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(10)
                                .onAppear {
                                    print("🧪 SwiftUI Light image appeared")
                                }
                        }
                        
                        VStack {
                            Text("Dark (SwiftUI)")
                            Image("miraTrip_Back_dark_01")
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .cornerRadius(10)
                                .onAppear {
                                    print("🧪 SwiftUI Dark image appeared")
                                }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    BackgroundImageTestView()
}