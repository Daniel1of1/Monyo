import Foundation

public struct AccountResponse: Codable {
    public let accounts: [Account]
}

public struct Account: Codable, Equatable {
    public let id: String
    public let closed: Bool
    public let created, description, type: String
    public let owners: [Owner]
    public let accountNumber, sortCode: String?
    
    enum CodingKeys: String, CodingKey {
        case id, closed, created, description, type, owners
        case accountNumber = "account_number"
        case sortCode = "sort_code"
    }
}

public struct Owner: Codable, Equatable {
    public let userID, preferredName, preferredFirstName: String
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case preferredName = "preferred_name"
        case preferredFirstName = "preferred_first_name"
    }
}
