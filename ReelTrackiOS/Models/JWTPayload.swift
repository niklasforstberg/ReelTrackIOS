import Foundation

struct JWTPayload: Codable {
    let exp: Int
    let iss: String  // issuer
    let aud: String  // audience
    
    // Using custom coding keys to map the long URLs to simpler properties
    let userId: String
    let email: String
    let familyId: String
    let isAdmin: String
    
    enum CodingKeys: String, CodingKey {
        case exp, iss, aud
        case userId = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"
        case email = "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
        case familyId = "FamilyId"
        case isAdmin = "IsAdmin"
    }
    
    static func decode(from token: String) -> JWTPayload? {
        print("Decoding JWT token...")
        let parts = token.components(separatedBy: ".")
        print("Token parts count: \(parts.count)")
        
        guard parts.count == 3 else {
            print("Invalid token format - wrong number of parts")
            return nil
        }
        
        let payloadBase64 = parts[1].base64URLUnpadded()
        print("Base64 payload: \(payloadBase64)")
        
        guard let data = Data(base64Encoded: payloadBase64) else {
            print("Failed to decode base64 data")
            return nil
        }
        
        print("Decoded JSON: \(String(data: data, encoding: .utf8) ?? "invalid UTF8")")
        
        do {
            let payload = try JSONDecoder().decode(JWTPayload.self, from: data)
            print("Successfully decoded payload: \(payload)")
            return payload
        } catch {
            print("JSON decoding error: \(error)")
            return nil
        }
    }
} 