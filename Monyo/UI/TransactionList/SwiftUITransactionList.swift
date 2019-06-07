import SwiftUI

struct SwiftUITransactionList : View {
    
    @ObjectBinding var transactionHolder: TransactionsHolder
    
    var body: some View {
        List(transactionHolder.transactions) { transaction in
            SwiftUITransactionCell(transaction: transaction)
        }
    }
}

/// SwiftUI wrapper around `IconView`
struct SwiftUIIconView: UIViewRepresentable {
    
    var url: URL? = nil
    
    func makeUIView(context: Context) -> IconView {
        IconView()
    }
    
    func updateUIView(_ view: IconView, context: Context) {
        view.url = url
    }
}

/// SwiftUI equivalent of `TransactionCell`
struct SwiftUITransactionCell: View {
    
    var transaction: Transaction
    
    var body: some View {
        
        let mainText = transaction.merchant?.name ??
            transaction.description
        let subText = transaction.notes
        
        // TODO: use the currency in transaction
        let merchantUrl = (transaction.merchant?.logo).flatMap(URL.init(string:))

        return HStack(alignment: .center) {
            SwiftUIIconView(url: merchantUrl).frame(width: 32, height: 32).cornerRadius(4)
            VStack(alignment: .leading) {
                Text(mainText)
                    .font(.headline).color(.primary)
                Text(subText)
                    .font(.subheadline).color(.secondary)
                }.padding(12)
            Spacer()
            AmountText(amount: transaction.amount)
            }.padding(8)
        
    }
}

struct AmountText: View {
    
    let amount: Int
    
    var body: some View {
        
        var amountText = NumberFormatter.localizedString(from: NSNumber(value: abs(Double(amount)/100)), number: .currency)

        if amount > 0 {
            amountText = "+ \(amountText)"
        }
        
        let t = Text(amountText)
        
        if amount > 0 {
            return t.color(.green)
        } else {
            return t.color(.primary)
        }
        
    }
}

#if DEBUG
struct SwiftUITransactionList_Previews : PreviewProvider {
    
    @State static var transactions = TransactionsHolder(transactions: tenRandomTransactionsForOneWeek())
    
    static var previews: some View {
        SwiftUITransactionList(transactionHolder: transactions)
    }
}
#endif
