
import UIKit

/// A very basic (for the moment) UITableViewController to show a list
/// of cells representing `Transaction`s
final class TransactionListViewController: UITableViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    // MARK: - UITableViewController / UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TransactionTableViewCell
        let transaction = transactions[indexPath.row]
        cell.update(transaction: transaction)
        return cell
    }
    
    // MARK: - Properties
    
    private var transactions = [Transaction]()
    
    // MARK: - Setup
    
    func setup() {
        tableView.register(TransactionTableViewCell.self, forCellReuseIdentifier: "Cell")
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(getLatest), for: .valueChanged)
        // FIXME: this loading state should be on the model, in the same way it is
        // for `Authentication`
        self.refreshControl?.beginRefreshing()
    }
    
    // MARK: - User Interaction
    
    @objc func getLatest() {
        Current.update(message: .getLatest)
        // FIXME: this loading state should be on the model, in the same way it is
        // for `Authentication`
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.refreshControl?.endRefreshing()
        }
    }
    
    // MARK: - Update
    
    func update(model: Model) {
        // FIXME: this is just for show at the moment, to make feed look cleaner
        // ideally these would be grouped with the relevant purchase
        // currently not dealing with pots
        let filtered = model.transactions.filter {  !$0.description.contains("pot_") }
        if filtered != self.transactions {
            self.transactions = filtered
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
}
