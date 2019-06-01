import Foundation

struct ErrorResponse: Codable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case error
        case errorDescription = "error_description"
        case message
    }
    
    let code: String
    let message: String
    let error: String?
    let errorDescription: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        code = try container.decode(String.self, forKey: .code)
        error = try? container.decode(String.self, forKey: .error)
        errorDescription = try? container.decode(String.self, forKey: .errorDescription)
        message = try container.decode(String.self, forKey: .message)
    }
}
