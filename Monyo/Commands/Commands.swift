import UIKit

/// A `Command` is a continuation whose return value is `Void`, essentially a wrapper
/// for a callback.
/// This is here for the purposes of using more 'Elm-like' vocabulary.
typealias Command<A> = Cont<(),A>

struct CommandProvider {
    var _loadFromPersistence: () -> Command<Model>
    var _persist: (_ model: Model) -> Command<Void>
    var _fetchTokens: (_ authCode: String, _ clientID: String, _ clientSecret: String, _ redirectURI: URL) -> Command<Result<Tokens,Error>>
    var _accounts: (_ accessToken: String) -> Command<Result<[Account],Error>>
    var _latestTransactions: (Model) -> Command<Result<[Transaction],Error>>
    var _openURL: (_ url: URL) -> Command<Void>
}

extension CommandProvider {
    func fetchTokens(authCode: String, clientID: String, clientSecret: String, redirectURI: URL) -> Command<Result<Tokens,Error>> {
        return _fetchTokens(authCode, clientID, clientSecret, redirectURI)
    }
    
    func accounts(accessToken: String) -> Command<Result<[Account],Error>> {
        return _accounts(accessToken)
    }
    
    func latestTransactions(model: Model) -> Command<Result<[Transaction],Error>> {
        return _latestTransactions(model)
    }
    
    func loadFromPersistence() -> Command<Model> {
        return _loadFromPersistence()
    }
    
    func persist(model: Model) -> Command<Void> {
        return _persist(model)
    }
    
    func openURL(_ url: URL) -> Command<Void>  {
        return _openURL(url)
    }
    
}

extension CommandProvider {
    static let `default` = {
        return CommandProvider(_loadFromPersistence: Persistence.loadFromPersistence,
                               _persist: Persistence.persist,
                               _fetchTokens: MonzoCommands.fetchTokens,
                               _accounts: MonzoCommands.accounts,
                               _latestTransactions: MonzoCommands.latestTransactions,
                               _openURL: URLOpening.openURL)
    }()
    
    static let mockSuccess = {
        return CommandProvider(_loadFromPersistence: Persistence.loadFromPersistence,
                               _persist: Persistence.persist,
                               _fetchTokens: MonzoCommands.fetchTokens,
                               _accounts: MonzoCommands.accounts,
                               _latestTransactions: MonzoCommands.latestTransactions,
                               _openURL: URLOpening.openURL)
    }()
}
