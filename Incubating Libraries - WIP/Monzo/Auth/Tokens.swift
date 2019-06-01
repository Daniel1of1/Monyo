import Foundation

/// A structure to hold the contents of a token response from monzo
/// - SeeAlso: [monzo docs](https://docs.monzo.com/#acquire-an-access-token) for more
public  struct Tokens: Codable, Equatable {
  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case expires = "expires_in"
    case refreshToken = "refresh_token"
  }
  
  public let accessToken: String
  public let refreshToken: String?
  public let expires: Date?
    
}

extension Tokens {
    // add date to allow for deterministic function
    public  init(from decoder: Decoder, date: Date = Date()) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let expiresIn = try? container.decodeIfPresent(Double.self, forKey: .expires)
        
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try? container.decodeIfPresent(String.self, forKey: .refreshToken)
        if let expiresIn = expiresIn {
            expires = date.addingTimeInterval(expiresIn)
        } else {
            expires = nil
        }
    }
}
