import UIKit

/// A very thin wrapper around `TransactionRowView`
final class TransactionTableViewCell: UITableViewCell {
    // MARK: - UITableViewCell
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: - Properties
    let transactionRow = TransactionRowView()

    
    // MARK: - Setup
    func setup() {
        self.contentView.addSubview(transactionRow)
        transactionRow.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            transactionRow.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            transactionRow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            transactionRow.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            transactionRow.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            ])
        
    }
    

    // MARK: - Update
    func update(transaction: Transaction) {
        transactionRow.update(transaction: transaction)
    }

}
