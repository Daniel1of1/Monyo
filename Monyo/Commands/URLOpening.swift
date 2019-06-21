import UIKit

enum URLOpening {}
extension URLOpening {
    static func openURL(_ url: URL) -> Command<Void> {
        return Command { cont in
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:])
                cont(())
            }
        }
    }
}
