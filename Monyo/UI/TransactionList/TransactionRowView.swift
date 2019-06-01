import UIKit

/// A view to represent the basic components of `Transaction`,
/// most pertinantly, how much, and to who / why.
final class TransactionRowView: UIView {
    
    // MARK: - UIView
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        
    }
    
    // MARK: - Properties
    private let mainTextLabel = UILabel()
    private let extraInfoLabel = UILabel()
    private let amountLabel = UILabel()
    private let iconView: IconView = IconView()
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = UIStackView.Alignment.center
        return stackView
    }()
    private let detailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = UIStackView.Distribution.fill
        stackView.alignment = .fill
        // we want this to be the segment to be squashed
        stackView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return stackView
    }()
    
    
    // MARK: - Setup
    func setup() {
        detailStackView.addArrangedSubview(mainTextLabel)
        detailStackView.addArrangedSubview(extraInfoLabel)
        
        mainTextLabel.font = UIFont.preferredFont(forTextStyle: .body)
        extraInfoLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        
        mainStackView.addArrangedSubview(iconView)
        mainStackView.addArrangedSubview(detailStackView)
        mainStackView.spacing = 12 // TODO: remove magic numbers
        amountLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        amountLabel.textAlignment = .right
        mainStackView.addArrangedSubview(amountLabel)
        addSubview(mainStackView)
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        iconView.layer.cornerRadius = 8
        iconView.clipsToBounds = true
        
        // This is to prevent what ends up being conflicting AUtoloayout constraints, even though
        // they should infact resolve
        let bottomConstraint = mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        bottomConstraint.priority = .defaultHigh
        let constraints = [
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            iconView.heightAnchor.constraint(equalToConstant: 32),
            bottomConstraint
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Update
    func update(transaction: Transaction) {
        let mainText = transaction.merchant?.name ??
            transaction.description
        let subText = transaction.notes
        
        // TODO: use the currency in transaction
        var amountText = NumberFormatter.localizedString(from: NSNumber(value: abs(Double(transaction.amount)/100)), number: .currency)
        if transaction.amount > 0 {
            amountText = "+ \(amountText)"
            self.amountLabel.textColor = .green
        } else {
            self.amountLabel.textColor = .black
        }
        
        let merchantUrl = (transaction.merchant?.logo).flatMap(URL.init(string:))
        
        self.mainTextLabel.text = mainText
        self.extraInfoLabel.text = subText
        self.amountLabel.text = amountText
        self.iconView.url = merchantUrl
        if merchantUrl != nil {
            self.iconView.backgroundColor = .white
        } else {
            // forgoing a placeholder image
            let colours = [UIColor.purple, UIColor.magenta, UIColor.orange, UIColor.brown]
            let index = abs(mainText.hashValue) % colours.count
            self.iconView.backgroundColor = colours[index]
        }
    }
}
