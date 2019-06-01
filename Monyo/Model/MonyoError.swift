import Foundation

/// An enum representing every possible error that we should be handling in the app.
/// - ToDo: make exhaiustive
/// - ToDo: ensure localized descriptions are useful to user
enum MonyoError: LocalizedError {
    case monzo(MonzoError)
    case other(Error)
    // TODO: This only necessary since we are not ensuring we can't get to impossible state
    case impossibleState(keyPaths: [String], message: String, model: Model)
}
