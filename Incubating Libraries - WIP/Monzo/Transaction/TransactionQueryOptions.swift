import Foundation

public enum SinceQueryOption {
    case date(Date)
    case id(String)
}

public struct TransactionQueryOptions {
    let since: SinceQueryOption?
    let limit: Int?
    let before: Date?
    public init(since: SinceQueryOption? = nil, limit: Int? = nil, before: Date? = nil) {
        self.before = before
        self.since = since
        self.limit = limit
    }
}

extension TransactionQueryOptions {
    
    public var queryString: String {
        var params = [(String,String)]()
        if let beforeString = before.map(DateFormatter.queryOptions.string) {
            params.append(("before",beforeString))
        }
        if let limit = limit, limit <= 100 , limit > 0 {
            params.append(("limit",String(limit)))
        }
        
        if case let .id(id)? = since {
            params.append(("since",id))
        } else if case let .date(date)? = since {
            let sinceDate = DateFormatter.queryOptions.string(from: date)
            params.append(("since",sinceDate))
        }
        return params.map { "\($0.0)=\($0.1)" }.joined(separator: "&")
    }
}


