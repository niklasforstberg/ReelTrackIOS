import SwiftUI

struct FamilySetupView: View {
    @Binding var hasFamily: Bool
    @State private var familyName = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Your Family")
                .font(.largeTitle)
                .bold()
            
            TextField("Family Name", text: $familyName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Button(action: createFamily) {
                if isLoading {
                    ProgressView()
                } else {
                    Text("Create Family")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(isLoading)
        }
        .padding()
    }
    
    private func createFamily() {
        print("Starting family creation with name: \(familyName)")
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            print("Full token: \(token)")
            if let payload = JWTPayload.decode(from: token) {
                print("Token payload: \(payload)")
                print("Token exp: \(payload.exp ?? 0)")
                print("Current time: \(Int(Date().timeIntervalSince1970))")
            }
        }
        
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let requestBody = ["name": familyName] as [String: String]
                print("Request body JSON: \(String(data: try JSONEncoder().encode(requestBody), encoding: .utf8) ?? "")")
                
                let data = try await APIClient.shared.authenticatedRequest(
                    path: "/family",
                    method: "POST",
                    body: requestBody
                )
                
                print("Raw response: \(String(data: data, encoding: .utf8) ?? "none")")
                
                if let response = try? JSONDecoder().decode(CreateFamilyResponse.self, from: data) {
                    print("Successfully created family with ID: \(response.id)")
                    await MainActor.run {
                        isLoading = false
                        hasFamily = true
                    }
                } else {
                    print("Failed to decode response")
                    throw APIError.invalidResponse
                }
            } catch {
                print("Error creating family: \(error)")
                if let apiError = error as? APIError {
                    print("API Error details: \(apiError)")
                }
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
} 