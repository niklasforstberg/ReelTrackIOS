import Foundation

enum APIError: Error {
    case invalidURL
    case noToken
    case networkError(Error)
    case invalidResponse
    case serverError(Int)
}

class APIClient {
    static let shared = APIClient()
    
    private func getToken() -> String? {
        return UserDefaults.standard.string(forKey: "authToken")
    }
    
    func authenticatedRequest<T: Encodable>(
        path: String,
        method: String = "GET",
        body: T? = nil
    ) async throws -> Data {
        let fullURL = APIConfig.endpoint(path)
        print("Full URL: \(fullURL)")
        
        guard let url = URL(string: fullURL) else {
            print("Invalid URL: \(fullURL)")
            throw APIError.invalidURL
        }
        
        guard let token = getToken() else {
            print("No auth token found")
            throw APIError.noToken
        }
        print("Token found: \(token.prefix(20))...")
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try? JSONEncoder().encode(body)
        }
        
        print("Full request headers: \(request.allHTTPHeaderFields ?? [:])")
        
        do {
            let (data, response) = try await URLSession.development.data(for: request)
            print("Response status: \((response as? HTTPURLResponse)?.statusCode ?? -1)")
            print("Response data: \(String(data: data, encoding: .utf8) ?? "none")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError.serverError(httpResponse.statusCode)
            }
            
            return data
        } catch {
            print("Network error: \(error)")
            throw APIError.networkError(error)
        }
    }
} 