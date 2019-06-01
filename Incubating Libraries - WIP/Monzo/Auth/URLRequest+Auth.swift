import Foundation
public extension URLRequest {
    
    func authenticate(with token: String) -> URLRequest {
        var request = self
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    static func tokensRequest(authCode: String, clientID: String, clientSecret: String, redirectURI: URL) -> URLRequest {
        var r = URLRequest(url: Util.URL("https://api.monzo.com/oauth2/token"))
        r.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        r.httpMethod = "POST"
        
        let parameters = ["grant_type":"authorization_code",
                          "client_id":clientID,
                          "client_secret":clientSecret,
                          "redirect_uri": redirectURI.absoluteString,
                          "code":authCode]
        
        let body = parameters
            .map{ entry in return [entry.key, entry.value.stringByAddingPercentEncodingForFormData() ?? ""].joined(separator: "=") }
            .joined(separator: "&")
            .data(using: .utf8)
        
        r.httpBody = body
        return r
    }
    
    static func authCodeURL(clientID: String, redirectURI: URL, stateToken: String) -> URL {
        return URL(string: "https://auth.monzo.com/?client_id=\(clientID)&redirect_uri=\(redirectURI.absoluteString)&response_type=code&state=\(stateToken)")!
    }
    

}
