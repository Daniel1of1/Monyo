/**
 `Authentication` is a struct that represents the state of authentication in the app.
 This includes tokens that grant access to resources of the user, as well as credentials needed to create and renew these tokens.
 */
struct Authentication: Codable, Equatable {
    /// An Error representing anything that can go wrong exclusively during the  authentication process.
    enum Error: String, Swift.Error {
        /**
         The state token we generated locally and the state token we received
         upon launching the app through a url do not match. This indicates that
         there may be a cross origin attack being attempted.
         - SeeAlso: https://docs.monzo.com/#acquire-an-access-token
         */
        case stateTokenMismatch
    }
    /// A container for all the data necessary to start an `Unconfidential` flow
    /// to obtain accessTokens.
    /// - SeeAlso: https://docs.monzo.com/#acquire-an-access-token
    var credentials: UnConfidentialBaseCredentials
    /// Optional `Tokens` representing whether or not we have tokens with which to make requests.
    var tokens: Tokens?
    /// Indicates whether or not we are in the process of acquiring access tokens.
    var loading: Bool
}

// MARK: - Initial

extension Authentication {
    /// Base `Authentication` state
    static let initial = Authentication(credentials: UnConfidentialBaseCredentials.initial, tokens: nil, loading: false)
}
