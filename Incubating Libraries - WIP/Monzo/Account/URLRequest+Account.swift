import Foundation

public extension URLRequest {
    static let accounts: URLRequest = {
        let urlString = "https://api.monzo.com/accounts"
        return URLRequest(url: URL(string: urlString)!)
    }()
}
