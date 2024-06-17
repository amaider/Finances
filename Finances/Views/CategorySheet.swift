// 16.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct CategorySheet: View {
    @State var collapseHelper: Set<String> = []
    
    let transactions: [Transaction]
    let categories: [CategoryList]
    
    init(transactions: [Transaction]) {
        self.transactions = transactions
        self.categories = {
            let categoryDict = transactions.reduce(into: [String: [Transaction]](), { result, transaction in
                result[transaction.category?.name ?? "nan", default: []].append(transaction)
            })
            
            return categoryDict.reduce(into: [CategoryList](), { result, entry in
                result.append(CategoryList(name: entry.key, transactions: entry.value))
            })
        }()
    }
    
    
    var body: some View {
        ScrollView(content: {
            ForEach(categories.sorted(by: { $0.amount > $1.amount }), content: { category in
                Button(action: { collapseSectionAction(category.name) }, label: {
                    HStack(content: {
                        Text(category.name)
                        Spacer()
                        Text(category.amount, format: .currency(code: "EUR"))
                        Image(systemName: collapseHelper.contains(category.name) ? "chevron.down" : "chevron.left")
                            .frame(width: 20, height: 20)
                            .foregroundColor(.gray)
                    })
                    .font(.title3)
                    .contentShape(Rectangle())
                })
                .buttonStyle(.plain)
                
                if collapseHelper.contains(category.name) {
                    ForEach(category.transactions.sorted(by: { $0.date < $1.date }), content: { transaction in
                        TransactionRowViewSmall(transaction: transaction, isSelected: false)
                            .contentShape(Rectangle())
                    })
                    .padding(.leading, 8)
                    .padding(.trailing, 20)
                    
                }
            })
        })
        .listStyle(.sidebar)
    }
    
    private func collapseSectionAction(_ section: String) {
        if collapseHelper.remove(section) == nil {
            collapseHelper.insert(section)
        }
    }
    
    // MARK: CategoryList Struct
    struct CategoryList: Identifiable {
        let id: UUID = UUID()
        let name: String
        let transactions: [Transaction]
        var amount: Decimal { transactions.reduce(0, { $0 + $1.amount}) }
    }
}

#Preview {
    CategorySheet(transactions: [Transaction.example(), Transaction.example()])
}
