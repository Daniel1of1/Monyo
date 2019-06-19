import Foundation

enum Persistence {}
extension Persistence {
    
    // Mark: - Persistence
    private static var _read: (URL) -> Command<Result<Data,Error>> = { (url: URL) in
        return Command { cont in
            let result =  Result(catching: { try Data.init(contentsOf:url) } )
            cont(result)
        }
    }
    
    private static var _write: (Data, URL) -> Command<Result<Void,Error>> = { (data: Data, url: URL) in
        return Command { cont in
            let result =  Result(catching: { try data.write(to: url) } )
            cont(result)
        }
    }
    
    // TODO: decide where this should live and how to encrypt
    static let cacheURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("unencrypted.dat")
    
    static func loadFromPersistence() -> Command<Model> {
        return Command { cont in
            var model = Model.initial
            do {
                let cached = try Data.init(contentsOf: cacheURL)
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
    
    static func persist(model: Model) -> Command<Void> {
        return Command { cont in
            do {
                let data = try JSONEncoder().encode(model)
                try data.write(to: cacheURL)
            }
            catch {
                // TODO: decide how to handle this error
            }
            
            cont(())
        }
    }

}
