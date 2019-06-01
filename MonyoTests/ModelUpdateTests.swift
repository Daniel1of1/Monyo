extension Command where R == Void {
    func runSynchronously() -> A {
        let semaphore = DispatchSemaphore(value: 0)
        var value: A!
        self.run { a in
            value = a
            semaphore.signal()
        }
        semaphore.wait()
        return value
    }
}

extension Account {
    static let example: Account = Account.init(id: "dsf", closed: false, created: "", description: "adsf", type: "sadf", owners: [], accountNumber: "2354", sortCode: "2345")

}

extension Transaction {
    static let example: Transaction = Transaction.init(accountBalance: 100, amount: 30, created: Date(), currency: "GBP", description: "A small transaction", id: "tx_0099", merchant: nil, metadata: Metadata(), notes: "", isLoad: false, settled: nil)
}


import XCTest
@testable import Monyo

class ModelUpdateTests: XCTestCase {
    
    struct TestError: Error {}

    func testThatModelIsSetWhenLoaded() {
         //Given
        var model = Model.initial
        var expectedModel = model
        expectedModel.authentication.credentials = UnConfidentialBaseCredentials(clientID: "something", clientSecret: "different", redirectURI: Util.URL("http://example.com"))

        // When
        _ = model.update(message: .loadedFromPersistence(model: expectedModel))

        // Then
        XCTAssertEqual(model, expectedModel)
    }

    func testStartFetchingTokensDoesNotUpdateModel() {
        //Given
        var model = Model.initial
        let expectedModel = model
        
        // When
        _  = model.update(message: .startFetchingTokens)
        // This will open the URL at the moment
        // TODO route opening URLs through "World"
        //let message = command?.runSynchronously()
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }
    
    func testRecievedAuthCodeUpdateCorrectState() {
        //Given
        var model = Model.initial
        // we expect authentication to be loading
        var expectedModel = model
        expectedModel.authentication.loading = true
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        
        // When
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }
    
    func testRecievedAuthCodeUpdateStateMismatch() {
        //Given
        var model = Model.initial
        _ = model.update(message: .startFetchingTokens)
        
        var expectedModel = model
        expectedModel.error = Authentication.Error.stateTokenMismatch
        expectedModel.authentication.tokens = nil
        expectedModel.authentication.loading = false

        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken + "no"
        
        // When
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }
    
    func testRecievedTokensSuccessNoAccount() {
        //Given
        var model = Model.initial
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedTokens = Tokens(accessToken: "accessToken", refreshToken: "RefreshToken", expires: Date())

        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))

        var expectedModel = model
        expectedModel.authentication.tokens = expectedTokens
        expectedModel.authentication.loading = false
        
        // When
        _ = model.update(message: .receivedTokens(.success(expectedTokens)))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }

    func testRecievedTokensSuccessWithActiveAccount() {
        //Given
        var model = Model.initial
        model.activeAccount = Account.example
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedTokens = Tokens(accessToken: "accessToken", refreshToken: "RefreshToken", expires: Date())
        
        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        
        var expectedModel = model
        expectedModel.authentication.tokens = expectedTokens
        expectedModel.authentication.loading = false
        
        // When
        _ = model.update(message: .receivedTokens(.success(expectedTokens)))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }

    func testRecievedTokensFailure() {
        //Given
        var model = Model.initial
        model.activeAccount = Account.example
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedError = TestError()
        
        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        
        var expectedModel = model
        expectedModel.error = TestError()
        expectedModel.authentication.loading = false
        
        // When
        _ = model.update(message: .receivedTokens(.failure(expectedError)))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }



    func testRecievedAccountsSuccess() {
        //Given
        var model = Model.initial
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedTokens = Tokens(accessToken: "accessToken", refreshToken: "RefreshToken", expires: Date())
        
        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        _ = model.update(message: .receivedTokens(.success(expectedTokens)))
        
        var expectedModel = model
        expectedModel.activeAccount = Account.example
        
        // When
        _ = model.update(message: .receivedAccounts(.success([Account.example])))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }

    func testRecievedAccountsFailure() {
        //Given
        var model = Model.initial
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedTokens = Tokens(accessToken: "accessToken", refreshToken: "RefreshToken", expires: Date())
        let expectedError = TestError()
        
        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        _ = model.update(message: .receivedTokens(.success(expectedTokens)))
        
        var expectedModel = model
        expectedModel.error = expectedError
        
        // When
        _ = model.update(message: .receivedAccounts(.failure(expectedError)))
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }

    func testRecievedTransactionsBasicSuccess() {
        //Given
        var model = Model.initial
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedTokens = Tokens(accessToken: "accessToken", refreshToken: "RefreshToken", expires: Date())
        let expectedTransactions = tenRandomTransactionsForOneWeek().sorted { $0.created > $1.created }
        
        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        _ = model.update(message: .receivedTokens(.success(expectedTokens)))
        _ = model.update(message: .receivedAccounts(.success([Account.example])))

        var expectedModel = model
        expectedModel.transactions = expectedTransactions
        
        // When
        _ = model.update(message: .receivedTransactions(transactionsResult:.success(expectedTransactions)))

        // Then
        XCTAssertEqual(model, expectedModel)
    }
    
    func testRecievedTransactionsFailure() {
        //Given
        var model = Model.initial
        let authCode = "authCode"
        let stateToken = model.authentication.credentials.stateToken
        let expectedTokens = Tokens(accessToken: "accessToken", refreshToken: "RefreshToken", expires: Date())
        let expectedError = TestError()
        
        _ = model.update(message: .startFetchingTokens)
        _ = model.update(message: .receievedAuthCode(authCode: authCode, stateToken: stateToken))
        _ = model.update(message: .receivedTokens(.success(expectedTokens)))
        _ = model.update(message: .receivedAccounts(.success([Account.example])))

        var expectedModel = model
        expectedModel.error = expectedError
        
        // When
        _ = model.update(message: .receivedTransactions(transactionsResult:.failure(expectedError)))

        // Then
        XCTAssertEqual(model, expectedModel)
    }
    
    func testAcknowledgedErrorRemovesIt() {
        //Given
        var model = Model.initial
        let expectedError = TestError()
        var expectedModel = model
        expectedModel.error = expectedError
        
        // When
        _ = model.update(message: .shownError)
        
        // Then
        XCTAssertNil(model.error)
    }
    

    func testNoOpDoesNothing() {
        //Given
        var model = Model.initial
        let expectedModel = model
        // When
        _ = model.update(message: .noOp)
        
        // Then
        XCTAssertEqual(model, expectedModel)
    }
    


}
