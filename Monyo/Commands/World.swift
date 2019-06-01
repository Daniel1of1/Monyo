import UIKit

extension URLSession {
    /// Wraps up the standard (Data?, Response?, Error?) callback into
    /// Result<(Data, URLResponse), Error>
    public func performRequest(request: URLRequest, completion: @escaping (Result<(Data, URLResponse), Error>) -> Void) {
        self.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success((data ?? Data(), response!)))
            }
            }.resume()
    }
}

/// Represents the collection of all the non deterministic interactions the
/// application (or the `Program`) needs to have with the outside world
struct World {
    /// A function that takes a `URLRequest` and a callback with the result of making that request.
    var networkRequest: (URLRequest, @escaping (Result<(Data,URLResponse),Error>) -> Void) -> Void  // = URLSession.shared.performRequest
    /// A function to retrieve the current time.
    var now: () -> Date // = Date.init
    ///
    /// - Parameters:
    ///     - url: The URL of the data you wish to read.
    /// - Throws: Any error encountered while trying to read from the url.
    /// - Returns: the data at that location.
    var read: (_ contentsOf: URL) throws -> Data // = { (url: URL) in try Data.init(contentsOf:url) }
    ///
    /// - Parameters:
    ///     - data: The `Data` you want written.
    ///     - url: The URL you wish to write the data to.
    /// - Throws: Any error encountered while trying to read from the url.
    /// - Returns: the data at that location.
    var write: (_ data: Data, _ contentsOf: URL) throws -> Void // = { (data: Data, url: URL) in try data.write(to: url)
}

extension World {
    static let `default` = World(
        networkRequest: URLSession.shared.performRequest,
        now: Date.init,
        read: { (url: URL) in try Data.init(contentsOf:url) },
        write: { (data: Data, url: URL) in try data.write(to: url) }
    )
}
