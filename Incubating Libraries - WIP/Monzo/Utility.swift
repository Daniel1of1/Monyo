import Foundation

typealias Util = Utility

enum Utility {
    static func URL(_ string: StaticString) -> Foundation.URL {
        guard let url = Foundation.URL(string: "\(string)") else {
            preconditionFailure("Invalid static URL string: \(string)")
        }
        return url
    }
    static func URL(stringLiteral value: StaticString) -> Foundation.URL {
        return self.URL(value)
    }
    
    static func URLRequest(_ string: StaticString) -> Foundation.URLRequest {
        return Foundation.URLRequest(url: URL(string))
    }
    
}

// TODO: bring into util namespace nicely or move out of util?
extension String {
    public func stringByAddingPercentEncodingForFormData() -> String? {
        let unreserved = "*-._"
        let allowed = CharacterSet.alphanumerics.union(CharacterSet.init(charactersIn: unreserved))
        let encoded = addingPercentEncoding(withAllowedCharacters: allowed)
        return encoded
    }
}

// TODO: bring into util namespace nicely or move out of util?

extension DateFormatter {
    static let queryOptions: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "y-MM-dd'T'HH:mm:ss'Z'"
        return f
    }()

    static let transaction: DateFormatter = {
        let f = DateFormatter()
        f.isLenient = true
        f.dateFormat = "y-MM-dd'T'HH:mm:ss.SSSZ"
        return f
    }()
    
    static let transactionFallback: DateFormatter = {
        let f = DateFormatter()
        f.isLenient = true
        f.dateFormat = "y-MM-dd'T'HH:mm:ssZ"
        return f
    }()

    
    
    private static let debugPresentation: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        f.timeZone = .autoupdatingCurrent
        return f
    }()
}

