
import UIKit
import SwiftUI
import Combine

extension Transaction: Identifiable {}

/// A wrapper to allow transactions to be bindable,
/// - Note: should probably do this with the whole model
class TransactionsHolder : BindableObject {
    var transactions = [Transaction]() {
        didSet {
            didChange.send(())
        }
    }
    var didChange = PassthroughSubject<Void,Never>()
    
    init(transactions: [Transaction]) {
        self.transactions = transactions
    }
}


/// A very basic (for the moment) UITableViewController to show a list
/// of cells representing `Transaction`s
final class TransactionListViewController: UIViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - Properties
    
    private var transactionHolder = TransactionsHolder(transactions: [])
    
    // MARK: - Setup
    
    func setup() {
        let hostedView = UIHostingController(rootView: SwiftUITransactionList(transactionHolder: transactionHolder))
        self.add(hostedView)
        hostedView.view.frame = self.view.bounds
    }
    
    // MARK: - Update
    
    func update(model: Model) {
        let filtered = model.transactions.filter {  !$0.description.contains("pot_") }
        if filtered != self.transactionHolder.transactions {
            
            DispatchQueue.main.async {
                self.transactionHolder.transactions = filtered
            }
        }
    }
    
}
