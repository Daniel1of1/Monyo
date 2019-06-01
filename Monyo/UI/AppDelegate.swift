import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let root = RootViewController()
        Current.viewUpdate = root.update
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = root
        window?.makeKeyAndVisible()
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

        // TODO: pull outh into function and test
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
            case let keysAndValues = queryItems.map({ ($0.name, $0.value) }),
            case let dictionary = Dictionary(uniqueKeysWithValues: keysAndValues),
            let code = dictionary["code"]  as? String,
            let state = dictionary["state"] as? String {
            
            DispatchQueue.main.async {
                Current.update(message: .receievedAuthCode(authCode: code, stateToken: state))
            }
        
        }
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Current.update(message: .persist)
    }
}

