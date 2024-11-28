//
//  ContentView.swift
//  ReelTrackiOS
//
//  Created by Niklas Förstberg on 2024-11-26.
//

import SwiftUI

struct ContentView: View {
    @State private var isShowingRegister = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var hasFamily = false
    @State private var isLoggedIn = false
    
    var body: some View {
        Group {
            if isLoggedIn {
                if hasFamily {
                    Text("Main App View")  // Replace with your main app view
                } else {
                    FamilySetupView(hasFamily: $hasFamily)
                }
            } else {
                NavigationView {
                    VStack(spacing: 20) {
                        Text("ReelTrack")
                            .font(.largeTitle)
                            .bold()
                        
                        TextField("Email", text: $email)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        
                        SecureField("Password", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        if let error = errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        
                        Button(action: login) {
                            if isLoading {
                                ProgressView()
                            } else {
                                Text("Login")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(isLoading)
                        
                        Button("Create Account") {
                            isShowingRegister = true
                        }
                    }
                    .padding()
                    .sheet(isPresented: $isShowingRegister) {
                        RegisterView()
                    }
                }
            }
        }
        .onChange(of: isLoggedIn) { newValue in
            if newValue {
                // Force view refresh when login state changes
                print("Login state changed, hasFamily: \(hasFamily)")
            }
        }
    }
    
    private func login() {
        print("Login started")
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: APIConfig.endpoint("/auth/login")) else {
            print("Invalid URL")
            return
        }
        
        let body = ["email": email, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.development.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                print("Response received")
                isLoading = false
                
                if let error = error {
                    print("Error: \(error)")
                    errorMessage = error.localizedDescription
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response type")
                    errorMessage = "Invalid response"
                    return
                }
                
                print("Status code: \(httpResponse.statusCode)")
                
                if httpResponse.statusCode == 200 {
                    print("Parsing response data...")
                    if let data = data {
                        print("Raw response: \(String(data: data, encoding: .utf8) ?? "")")
                        if let response = try? JSONDecoder().decode(LoginResponse.self, from: data) {
                            print("Decoded response successfully")
                            let token = response.token
                            print("Token received: \(token.prefix(20))...")
                            UserDefaults.standard.set(token, forKey: "authToken")
                            
                            print("Attempting to decode JWT...")
                            if let payload = JWTPayload.decode(from: token) {
                                print("JWT decoded successfully")
                                print("Family ID from token: \(payload.familyId)")
                                hasFamily = !payload.familyId.isEmpty
                            } else {
                                print("Failed to decode JWT")
                            }
                            
                            withAnimation {
                                isLoggedIn = true
                            }
                            print("Final state - isLoggedIn: \(isLoggedIn), hasFamily: \(hasFamily)")
                        } else {
                            print("Failed to decode response")
                        }
                    }
                } else {
                    if let data = data {
                        print("Error response: \(String(data: data, encoding: .utf8) ?? "")")
                    }
                    errorMessage = "Login failed"
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
