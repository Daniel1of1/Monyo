import UIKit

/// All updates come through this viewController (via `update(model:)`)
/// and are cascaded down the view heirarchy where necessary
class RootViewController: UIViewController {
    
    let authVC = AuthenticationViewController()
    let transactionListVC = TransactionListViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Effectively continue showing the launch screen until we are ready
        // to show something else, here we can do  some aesthetically pleasing
        // intro animations.
        let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: nil)
        self.replace(launchScreen.instantiateViewController(withIdentifier: "launch"))
        self.view.backgroundColor = .white
        Debug.start()
    }
        
    func update(model: Model) {
        DispatchQueue.main.async {
            if let error = model.error {
                self.show(error: error)
                Current.update(message: .shownError)
            }
            if model.accessToken == nil {
                self.authVC.update(model: model)
                self.replace(self.authVC)
            } else {
                self.transactionListVC.update(model: model)
                self.replace(self.transactionListVC)
            }
        }
    }
    
    // TODO: decide on a (much) nicer way to show global errors.
    func show(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.reflectedString, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true)
    }
}
