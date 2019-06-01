import Foundation


extension String: Error {}

/// Stub responses for network requests we match on
public func babylonNetworkMock(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), Error>) -> Void) {
    DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 1.5) {
        switch request.url!.absoluteString {
        case let s where s.contains("https://api.monzo.com/oauth2/token"):
            let data = try! JSONEncoder().encode(tokens)
            completion(Result.success((data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)))
        case let s where s.contains("https://api.monzo.com/accounts"):
            let data = try! JSONEncoder().encode(accounts)
            completion(Result.success((data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)))
        case let s where s.contains("https://api.monzo.com/transactions"):
            let data = try! JSONEncoder().encode(transactions)
            completion(Result.success((data, HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!)))
        default:
            completion(.failure("using mock network and a response for this url is not configured"))
        }
    }
}

private let tokens = Tokens(accessToken: "access", refreshToken: nil, expires: nil)
private let accounts = AccountResponse(accounts:[blankAccount])
private var transactions: TransactionResponse {
    return TransactionResponse(transactions:tenRandomTransactionsForOneWeek())
}

func tenRandomTransactionsForOneWeek() -> [Transaction] {
    return (1...10).map { _ in return randomTransaction() }
}

private let blankAccount = Account(id: UUID().uuidString, closed: false, created: "", description: "", type: "", owners: [], accountNumber: "1235", sortCode: "1231")

private func randomTransaction() -> Transaction {
    return Transaction(accountBalance: 0, amount: Int.random(in: -10000...10000), created: randomDateInLastWeek(), currency: "GBP", description: "a transfer", id: UUID().uuidString, merchant: randomMerchant(), metadata: Metadata(), notes: "", isLoad: true, settled: nil)
}

private func randomDateInLastWeek() -> Date {
    let date = Calendar.autoupdatingCurrent.date(byAdding: .day, value: -7, to: Date())!
    let interval = Date().timeIntervalSince(date)
    let random = arc4random_uniform(UInt32(interval))
    return Date().addingTimeInterval(Double(random))
}

private func randomMerchant() -> Merchant {
    var gen = SystemRandomNumberGenerator.init()
    let (name, handle) = babylonians.randomElement(using: &gen)!
    let logoURL = "https://mondo-logo-cache.appspot.com/twitter/\(handle)/?size=small"
    
    let blankAddress = Address(address: "", city: "", country: "", latitude: 0, longitude: 0, postcode: "", region: "")
    return Merchant(address: blankAddress, created: randomDateInLastWeek(), groupID: "n/a", id: UUID().uuidString, logo: logoURL, emoji: "✌️", name: name, category: "n/a")
}

/// from: https://github.com/Babylonpartners/ios-playbook#1-whos-in-the-team
private let babylonians: [(String,String)] = [
    ("Adam Borek", "@TheAdamBorek"),
    ("Adrian Śliwa", "@adiki91"),
    ("Ana Catarina Figueiredo", "@AnnKatFig"),
    ("Anders Ha", "@_andersha"),
    ("Anil Puttabuddhi", "@anilputtabuddhi"),
    ("Ben Henshall", "@Ben_Henshall"),
    ("Chitra Kotwani", "@ChitraKotwani"),
    ("Danilo Aliberti", "@babylonhealth"),
    ("David Rodrigues", "@dmcrodrigues"),
    ("Diego Petrucci", "@diegopetrucci"),
    ("Giorgos Tsiapaliokas", "@gtsiap"),
    ("Ilya Puchka", "@ilyapuchka"),
    ("Jason Dobo", "@jasondobo"),
    ("João Pereira", "@NSMyself"),
    ("Joshua Simmons", "@j531"),
    ("Martin Nygren", "@babylonhealth"),
    ("Michael Brown", "@mluisbrown"),
    ("Michał Kwiecień", "@kwiecien_co"),
    ("Nicola Di Pol", "@nicola.dipol"),
    ("Olivier Halligon", "@AliSoftware"),
    ("Rui Peres", "@peres"),
    ("Sergey Shulga", "@SergDort"),
    ("Simon Cass", "@codercass"),
    ("Jakub Tomanik", "@jtomanik"),
    ("Viorel Mihalache", "@viorelMO"),
    ("Witold Skibniewski", "@babylonhealth"),
    ("Yasuhiro Inami", "@inamiy"),
    ("Yuri Karabatov", "@karabatov"),
]

