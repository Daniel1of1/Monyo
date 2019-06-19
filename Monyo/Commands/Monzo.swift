import Foundation

enum MonzoCommands {}
extension MonzoCommands {
    
    // MARK: - Auth Tokens
    
    static func fetchTokens(authCode: String, clientID: String, clientSecret: String, redirectURI: URL) -> Command<Result<Tokens,Error>> {
        let request = URLRequest.tokensRequest(authCode: authCode, clientID: clientID, clientSecret: clientSecret, redirectURI: redirectURI)
        let cmd = Network.command(request: request)
        return cmd
            .map(bind(decoder(for: Tokens.self)))
    }
    
    // MARK: - Accounts
    
    static func accounts(accessToken: String) -> Command<Result<[Account],Error>> {
        let request = URLRequest.accounts.authenticate(with: accessToken)
        let cmd = Network.command(request: request)
        
        return cmd
            .map(bind(decoder(for: AccountResponse.self)))
            .map(lift( { return $0.accounts } ))
    }

    // MARK: - Transactions
    
    static func latestTransactions(model: Model) -> Command<Result<[Transaction],Error>> {
        guard  let accessToken = model.accessToken, let accountID = model.activeAccount?.id else {
            return Command.pure(.failure(MonyoError.impossibleState(keyPaths:["accessToken","activeAccount"], message: "should not be nil", model: model)))
        }
        
        let sinceDate = model.transactions.first?.created ?? Calendar.current.date(byAdding: DateComponents(day:-7) , to: Date())!
        let splitUp = queries(since: sinceDate)
        
        let commands = splitUp
            .map { URLRequest.transactionRequest(with: accountID, options: $0).authenticate(with: accessToken) }
            .map(Network.command)
        
        let combined = Command<Result<(Data, URLResponse), Error>>.combine(commands)
        
        return combined.map{ results -> Result<[Transaction],Error> in
            return results.map(bind(decoder(for: TransactionResponse.self)))
                .map(lift({return $0.transactions }))
                .reduce(Result<[Transaction],Error>.success([Transaction]()), unit2(+))
        }
    }
}


private func queries(since: Date, numberOfSegments: Int = 6) -> [TransactionQueryOptions] {
    let now = Date()
    
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
