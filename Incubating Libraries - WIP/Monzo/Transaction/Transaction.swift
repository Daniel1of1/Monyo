import Foundation
import Swift



public struct TransactionResponse: Codable {
    public let transactions: [Transaction]
}

// TODO: I think I need to add isdeclied reason optional
public struct Transaction: Equatable {
  public let accountBalance, amount: Int
  public let created: Date
  public let currency, description, id: String
  public let merchant: Merchant?
  public let metadata: Metadata
  public let notes: String
  public let isLoad: Bool
  public let settled: Date?
  
}

extension Transaction: Codable {
    enum CodingKeys: String, CodingKey {
        case accountBalance = "account_balance"
        case amount, created, currency, description, id, merchant, metadata, notes
        case isLoad = "is_load"
        case settled
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accountBalance = try container.decode(Int.self, forKey: .accountBalance)
        amount = try container.decode(Int.self, forKey: .amount)
        let createdString = try container.decode(String.self, forKey: .created)
        currency = try container.decode(String.self, forKey: .currency)
        description = try container.decode(String.self, forKey: .description)
        id = try container.decode(String.self, forKey: .id)
        merchant = try? container.decode(Merchant.self, forKey: .merchant)
        metadata = try container.decode(Metadata.self, forKey: .metadata)
        notes = try container.decode(String.self, forKey: .notes)
        isLoad = try container.decode(Bool.self, forKey: .isLoad)
        let settledString = try container.decodeIfPresent(String.self, forKey: .settled)
        settled = settledString.flatMap(DateFormatter.transaction.date)
        guard let createdDate = DateFormatter.transaction.date(from: createdString) ?? DateFormatter.transactionFallback.date(from: createdString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [CodingKeys.created, CodingKeys.settled], debugDescription: "error decoding date"))
        }
        created = createdDate
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accountBalance, forKey: .accountBalance)
        try container.encode(amount, forKey: .amount)
        let createdString = DateFormatter.transaction.string(from: created)
        try container.encode(createdString, forKey: .created)
        try container.encode(currency, forKey: .currency)
        try container.encode(description, forKey: .description)
        try container.encode(id, forKey: .id)
        try container.encode(merchant, forKey: .merchant)
        try container.encode(metadata, forKey: .metadata)
        try container.encode(notes, forKey: .notes)
        try container.encode(isLoad, forKey: .isLoad)
        if let settledString = settled.map(DateFormatter.transaction.string) {
            try container.encode(settledString, forKey: .settled)
        }
    }
}

extension Transaction: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

//extension Transaction: CustomDebugStringConvertible {
////    private static let encoder = JSONEncoder()
////    public var debugDescription: String {
////        let dateFormatter = DateFormatter.transaction
////        let encoder = Transaction.encoder
////        encoder.dateEncodingStrategy = .formatted(dateFormatter)
////        encoder.outputFormatting = .prettyPrinted
////        let data =
////        return String(data: try! encoder.encode(self), encoding: .utf8)!
////    }
//}

public struct Merchant: Equatable {
  public let address: Address
  public let created: Date
  public let groupID, id: String
  public let logo: String
  public let emoji, name, category: String
  
  enum CodingKeys: String, CodingKey {
    case address, created
    case groupID = "group_id"
    case id, logo, emoji, name, category
  }
  

}

extension Merchant: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        address = try container.decode(Address.self, forKey: .address)
        let createdString = try container.decode(String.self, forKey: .created)
        groupID = try container.decode(String.self, forKey: .groupID)
        id = try container.decode(String.self, forKey: .id)
        logo = try container.decode(String.self, forKey: .logo)
        emoji = try container.decode(String.self, forKey: .emoji)
        name = try container.decode(String.self, forKey: .name)
        category = try container.decode(String.self, forKey: .category)
        guard let createdDate = DateFormatter.transaction.date(from: createdString) else {
            throw DecodingError.dataCorrupted(DecodingError.Context.init(codingPath: [CodingKeys.created], debugDescription: "error decoding date"))
        }
        created = createdDate
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encode(groupID, forKey: .groupID)
        let createdString = DateFormatter.transaction.string(from: created)
        try container.encode(createdString, forKey: .created)
        try container.encode(id, forKey: .id)
        try container.encode(logo, forKey: .logo)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(name, forKey: .name)
        try container.encode(category, forKey: .category)
    }

}

public struct Address: Equatable {
  public let address, city, country: String
  public let latitude, longitude: Double
  public let postcode, region: String
}

extension Address: Codable { }

public struct Metadata: Codable, Equatable {
}
