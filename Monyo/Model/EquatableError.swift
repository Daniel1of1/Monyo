import Foundation

/// A wrapper around `Error` that makes it equatable
struct EquatableError: Error, Equatable {
    static func == (lhs: EquatableError, rhs: EquatableError) -> Bool {
        return areEqual(lhs.actualError, rhs.actualError)
    }
    
    /// The underlying error that is being wrapped
    let actualError: Error
    
    /**
     Initialize an `EquatableError` from an `Error`
     - Parameter actualError: The underlying error that is being wrapped.
     */
    init(_ actualError: Error) {
        self.actualError = actualError
    }
}

extension Error {
    /// Create an `EquatableError` from `Error`
    var equatable: EquatableError {
        return EquatableError(self)
    }
}

/// Taken from: https://kandelvijaya.com/2018/04/21/blog_equalityonerror/
/**
 This is a equality on any 2 instance of Error.
 */
public func areEqual(_ lhs: Error, _ rhs: Error) -> Bool {
    return lhs.reflectedString == rhs.reflectedString
}


public extension Error {
    var reflectedString: String {
        // NOTE 1: We can just use the standard reflection for our case
        return String(reflecting: self)
    }
    
    // Same typed Equality
    func isEqual(to: Self) -> Bool {
        return self.reflectedString == to.reflectedString
    }
    
}


public extension NSError {
    // prevents scenario where one would cast swift Error to NSError
    // whereby losing the associatedvalue in Obj-C realm.
    // (IntError.unknown as NSError("some")).(IntError.unknown as NSError)
    func isEqual(to: NSError) -> Bool {
        let lhs = self as Error
        let rhs = to as Error
        return self.isEqual(to) && lhs.reflectedString == rhs.reflectedString
    }
}
