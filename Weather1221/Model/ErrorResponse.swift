import Foundation

struct ErrorResponse: Codable {
    let error: Error
    
    struct Error: Codable {
        let code: Int
        let message: String
    }
}
