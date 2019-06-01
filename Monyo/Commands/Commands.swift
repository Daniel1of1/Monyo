import UIKit

/// A `Command` is a continuation whose return value is `Void`, essentially a wrapper
/// for a callback.
/// This is here for the purposes of using more 'Elm-like' vocabulary.
typealias Command<A> = Cont<(),A>

/// The single place with which to perform any non-deterministic operations
/// - Note: This is probably quite an overloaded term and is not used in the strictest sense that it is in Haskel from which it is inspired.
/// - Todo: Bring this back to being private, it is currently not because I have not properly decoupled `Debug` functionality to change the World.
var Realworld = World.default

enum Commands {
    
    // MARK: - Cache
    
    // TODO: decide where this should live and how to encrypt
    static let cacheURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("unencrypted.dat")

    static func loadFromPersistence(world: World = Realworld) -> Command<Model> {

        return Command { cont in
            var model = Model.initial
            do {
                let cached = try world.read(cacheURL)
                let cachedModel = try JSONDecoder().decode(Model.self, from: cached)
                model = cachedModel
            }
            catch {
                // TODO: decide how to handle this error
                print(error)
            }
            cont(model)
        }
    }
    
    static func persist(model: Model, world: World = Realworld) -> Command<Void> {
        return Command { cont in
            do {
                let data = try JSONEncoder().encode(model)
                try world.write(data, cacheURL)
            }
            catch {
                // TODO: decide how to handle this error
            }
            
            cont(())
        }
    }
    
    // MARK: - Network
    
    static func networkCommand(request: URLRequest, world: World = Realworld) -> Command<Result<(Data,URLResponse),Error>> {
        return Command { cont in
            world.networkRequest(request, cont)
        }
    }
    
    static func networkCommand(request: URLRequest) -> Command<Result<(Data,URLResponse),Error>> {
        return Command { cont in
            Realworld.networkRequest(request, cont)
        }
    }
    
    // MARK: - Auth Tokens
    
    static func fetchTokens(authCode: String, clientID: String, clientSecret: String, redirectURI: URL, world: World = Realworld) -> Command<Result<Tokens,Error>> {
        let request = URLRequest.tokensRequest(authCode: authCode, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
        let cmd = networkCommand(request: request, world: world)
        return cmd
            .map(bind(decoder(for: Tokens.self)))
    }

    // MARK: - Accounts
    
    static func accounts(accessToken: String, world: World = Realworld) -> Command<Result<[Account],Error>> {
        let request = URLRequest.accounts.authenticate(with: accessToken)
        let cmd = networkCommand(request: request, world: world)
        
        return cmd
            .map(bind(decoder(for: AccountResponse.self)))
            .map(lift( { return $0.accounts } ))

    }
    
    // MARK: - Transactions

    static func latestTransactions(model: Model, world: World = Realworld) -> Command<Result<[Transaction],Error>> {
        
        guard  let accessToken = model.accessToken, let accountID = model.activeAccount?.id else {
            return Command.pure(.failure(MonyoError.impossibleState(keyPaths:["accessToken","activeAccount"], message: "should not be nil", model: model)))
        }
        
        let sinceDate = model.transactions.first?.created ?? Calendar.current.date(byAdding: DateComponents(day:-7) , to: world.now())!
        let splitUp = queries(since: sinceDate)
        
        let commands = splitUp
            .map { URLRequest.transactionRequest(with: accountID, options: $0).authenticate(with: accessToken) }
            .map(networkCommand)

        let combined = Command<Result<(Data, URLResponse), Error>>.combine(commands)

        return combined.map{ results -> Result<[Transaction],Error> in
            return results.map(bind(decoder(for: TransactionResponse.self)))
                .map(lift({return $0.transactions }))
                .reduce(Result<[Transaction],Error>.success([Transaction]()), unit2(+))
        }
    }
    
    // TODO: better default for transactionquery
    static func transactions(accessToken: String, accountID: String, options:TransactionQueryOptions? = TransactionQueryOptions(since: .date(Date().addingTimeInterval(-60*60*24*7)), limit: nil, before: nil) , world: World = Realworld) -> Command<Result<[Transaction],Error>> {
        let request = URLRequest.transactionRequest(with: accountID, options: options).authenticate(with: accessToken)
        let cmd = networkCommand(request: request, world: world)
        
        return cmd
            .map(bind(decoder(for: TransactionResponse.self)))
            .map(lift({ return $0.transactions }))
    }
    
    // MARK - UIApplication
    
    static func openURL(_ url: URL) -> Command<Void> {
        return Command { cont in
        DispatchQueue.main.async {
            UIApplication.shared.open(url, options: [:])
            cont(())
            }
        }
    }
}

// MARK: - Pure

func queries(since: Date, world: World = Realworld, numberOfSegments: Int = 6) -> [TransactionQueryOptions] {
    let now = world.now()
    
    let start = since
    let end = now
    
    let difference = end.timeIntervalSince(start)
    
    var segs = [(start: Date,end: Date)]()
    
    for i in 0..<numberOfSegments {
        let d1 = start.addingTimeInterval(Double(i) * difference/Double(numberOfSegments))
        let d2 = start.addingTimeInterval(Double(i+1) * difference/Double(numberOfSegments))
        segs.append((d1,d2))
    }
    
    return segs.map { TransactionQueryOptions(since: .date($0.start), limit: nil, before: $0.end) }
    
}
