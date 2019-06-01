import Foundation

public extension URLRequest {
    static func transactionRequest(with accountId: String, options: TransactionQueryOptions?) -> URLRequest {
        var urlString = "https://api.monzo.com/transactions?expand[]=merchant&account_id=\(accountId)"
        if let options = options {
            urlString.append("&")
            urlString.append(options.queryString)
        }
        return URLRequest(url: URL(string: urlString)!)
    }
}
