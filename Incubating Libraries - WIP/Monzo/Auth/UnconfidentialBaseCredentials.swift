import Foundation

public struct UnConfidentialBaseCredentials: Codable, Equatable {
  
  let clientID: String
  let clientSecret: String
  let redirectURI: URL
  let stateToken: String = UUID().uuidString
    
  public init(clientID: String, clientSecret: String, redirectURI: URL) {
    self.clientID = clientID
    self.clientSecret = clientSecret
    self.redirectURI = redirectURI
  }
    
}
