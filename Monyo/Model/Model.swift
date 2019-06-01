import Foundation

/**
 Model is a struct that can wholly represent the state of the _entire_ app
 (with the exception of some transient UI state which is considered out of scope
 and to be tracked within the UI itself.
 It is a pure value type and should be mutated exclusively with its `update` function.
*/
struct Model: Equatable {
    /// A struct to represent the state of the app's authentication
    var authentication: Authentication
    /// Every user _should_ have an active account. It is optional to represent
    /// the state where we do not have one yet.
    var activeAccount: Account?
    /// A list of all the user's transactions we have locally, sorted by date.
    var transactions: [Transaction]
    /// Storage to wrap `error` to make it equatable
    private var _equatableError: EquatableError?
    /// Computed variable to wrap and unwrap the underlying error that
    /// currently affects the application state. Currently we have only one
    /// globally that we care about at a time
    var error: Error? {
        get {
            return _equatableError?.actualError
        } set {
            _equatableError = newValue.map(EquatableError.init)
        }
    }
    
    /**
     Initializes a new app `Model`, with every parameter specified.
     
     - Note:
     This should not be used directly during the app's runtime. Any modifications
     to `Model` should be done via its `update` method. Further, this should only
     be called by the `Program` it runs in.
     
     - Parameters:
     - authentication: The authentication state
     - activeAccount: The active `Account` struct of the user, if it exists
     - error: The current global error of the application, if there is one
     - transactions: A list of `Transaction`s sorted by date.
     
     - Returns: A `Model` struct representing the entire state of the app.
     */
    init(authentication: Authentication, activeAccount: Account?, error: Error?, transactions: [Transaction]) {
        self.authentication = authentication
        self.activeAccount = activeAccount
        self._equatableError = error.map(EquatableError.init)
        self.transactions = transactions
    }
    
}

extension Model {
    /// Convenience to retrieve `accessToken` from `authentication.tokens`
    var accessToken: String? {
        return self.authentication.tokens?.accessToken
    }
}


// Mark - Codable

extension Model: Codable {
    
    enum CodingKeys: String, CodingKey {
        case authentication
        case activeAccount
        case error
        case transactions
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authentication, forKey: .authentication)
        try container.encode(activeAccount, forKey: .activeAccount)
        try container.encode(transactions, forKey: .transactions)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        authentication = try container.decode(Authentication.self, forKey: .authentication)
        activeAccount = try? container.decode(Account.self, forKey: .activeAccount)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
    }
}

// Mark - Initial

extension Model {
    /// The starting point of any `Model`
    static let initial = Model(authentication: Authentication.initial, activeAccount: nil, error: nil, transactions:[])
}

