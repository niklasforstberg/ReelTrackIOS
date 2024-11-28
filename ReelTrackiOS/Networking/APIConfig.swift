enum APIConfig {
    static let baseURL = "https://localhost:7235"
    
    static func endpoint(_ path: String) -> String {
        return baseURL + path
    }
} 