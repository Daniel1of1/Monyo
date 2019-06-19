import Foundation

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

enum Network {}
extension Network {
    static func command(request: URLRequest) -> Command<Result<(Data,URLResponse),Error>> {
        return Command { cont in
            URLSession.shared.performRequest(request: request, completion: cont)
        }
    }
}
