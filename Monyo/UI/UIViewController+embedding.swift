import UIKit

extension UIViewController {
    /// Utility for performing all the steps for adding a child view controller.
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    /// Utility for wholly replacing the receivers childViewControllers with
    /// only the one specified.
    func replace(_ vc: UIViewController) {
        if children.count == 1 && children.first == vc {
            return
        }
        children.forEach{$0.remove()}
        self.add(vc)
    }
    
    /// Utility for performing all the steps to remove a child view controller.
    func remove() {
        guard parent != nil else {
            return
        }
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

