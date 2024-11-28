struct LoginResponse: Codable {
    let token: String
    let userId: Int
    let email: String
}

struct RegisterResponse: Codable {
    let message: String
}

struct ErrorResponse: Codable {
    let message: String
}

struct CreateFamilyResponse: Codable {
    let id: Int
    let name: String
} 