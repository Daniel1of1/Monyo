import Foundation

/// Represents every possible input that can change the state of the app (as represented by `Model`)
/// or the outside world.
enum Msg {
    // caching
    /// Tell our model we have loaded a new one from our cache
    case loadedFromPersistence(model: Model)
    /// Tell our model to be persisted
    case persist
    // Auth
    /// Begin the process of fetching access tokens
    case startFetchingTokens
    /// Received authode and state pair.
    /// This happens when we open a link that monzo has sent to our email client
    /// these will be extracted from the url query parameters.
    case receievedAuthCode(authCode: String, stateToken: String)
    /// The result of requesting access tokens
    case receivedTokens(Result<Tokens,Error>)
    // Accounts
    /// The result of requesting the users accounts
    case receivedAccounts(Result<[Account],Error>)
    // Transactions
    /// Begin the process of getting the latest Transactions.
    /// The specific implementation of this will be in the `Command` that is
    /// returned from the `update` function when passing in this message
    case getLatest
    /// The result of any request to get `Transaction`s
    case receivedTransactions(transactionsResult: Result<[Transaction],Error>)
    // Errors
    /// Indicates the user has seen the global error
    case shownError
    // NoOp
    /// Do nothing
    case noOp
}

extension Model {
    /// changes the `Model` for every possible input, as described by `Msg`
    mutating func update(message: Msg) -> Command<Msg>? {
        switch message {
            
        // Mark - Caching
        case .loadedFromPersistence(let model):
            self = model
            return command(for: self)
        case .persist:
            return Commands.persist(model: self).map{.noOp}
            
        // Mark - Auth
        case .startFetchingTokens:
            let credentials = self.authentication.credentials
            let url = URLRequest.authCodeURL(clientID: credentials.clientID, redirectURI: credentials.redirectURI, stateToken: credentials.stateToken)
            return Commands.openURL(url).map{ .noOp }
        case .receievedAuthCode(let authCode, let stateToken):
            self.authentication.loading = true
            if self.authentication.credentials.stateToken != stateToken {
                self.error = Authentication.Error.stateTokenMismatch
                self.authentication.tokens = nil
                self.authentication.loading = false
                return nil
            } else {
                let credentials = self.authentication.credentials
                return Commands.fetchTokens(authCode: authCode, clientID: credentials.clientID, clientSecret: credentials.clientSecret, redirectURI: credentials.redirectURI).map(Msg.receivedTokens)
            }
        case .receivedTokens(.success(let tokens)):
            self.authentication.tokens = tokens
            self.authentication.loading = false
            
            if self.activeAccount == nil, let accessToken = accessToken {
                return Commands.accounts(accessToken: accessToken).map(Msg.receivedAccounts)
            }
            return nil
        case .receivedTokens(.failure(let error)):
            self.error = error
            self.authentication.loading = false
            return nil
            
        // Mark - Accounts
        case .receivedAccounts(.success(let accounts)):
            let account = accounts.first {  $0.closed == false }
            self.activeAccount = account
            return Commands.latestTransactions(model: self).map(Msg.receivedTransactions)
        case .receivedAccounts(.failure(let error)):
            // TODO: Error cases need to be fleshed out here a bit
            self.error = error
            return nil
            
        // Mark - Transactions
        case .getLatest:
            // TODO: more tests
            return Commands.latestTransactions(model: self).map(Msg.receivedTransactions)
        case .receivedTransactions(.success(let transactions)):
            self.transactions = Array(Set(self.transactions + transactions)).sorted { $0.created > $1.created }
            return nil
        case .receivedTransactions(.failure(let error)):
            self.error = error
            // TODO: more tests
            if case MonzoError.accessTokenExpired = error {
                self.authentication.tokens = nil
            }
            if case MonzoError.accessTokenEvicted = error {
                self.authentication.tokens = nil
            }
            return nil
        // Mark - Errors
        case .shownError:
            self.error = nil
            return nil
        // Mark - NoOp
        case .noOp:
            return nil
        }
    }
    
    /// A helper to decide what `Command` we might want to run
    /// after a model is in a certain state
    private func command(for model: Model) -> Command<Msg>? {
        guard let accessToken = model.accessToken else {
            return nil
        }
        
        guard  model.activeAccount != nil else {
            return Commands.accounts(accessToken: accessToken).map(Msg.receivedAccounts)
        }
        
        return Commands.latestTransactions(model: self).map(Msg.receivedTransactions)
    }
    
}
