// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct DataBaseView: View {
    @Environment(\.modelContext) private var modelContext
   @Query var transactions: [Transaction]
   @Query var shops: [Shop]
   @Query var categories: [Category]
   @Query var items: [Item]
   @Query var documents: [Document]
    
    var body: some View {
        NavigationSplitView(sidebar: {
            List(content: {
                Section("Transactions \(transactions.count)x", content: {
                    ForEach(transactions, content: { transaction in
                        NavigationLink(destination: {
                            DataBaseTransactionView(transaction: transaction)
                        }, label: {
                            DataBaseTransactionView(transaction: transaction)
                        })
                    })
                })
                Section("Shops \(shops.count)x", content: {
                    ForEach(shops, content: { shop in
                        NavigationLink(destination: {
                            DataBaseTransactionView(transaction: shop.transactions.first ?? Transaction.example())
                        }, label: {
                            Text("\(shop.name): \(shop.location ?? "")")
                        })
                    })
                })
                Section("Categories \(categories.count)x", content: {
                    ForEach(categories, content: { category in
                        NavigationLink(destination: {
                            DataBaseTransactionView(transaction: category.transactions.first ?? Transaction.example())
                        }, label: {
                            Text("\(category.name)")
                        })
                    })
                })
            })
        }, content: {
            
        }, detail: {
            
        })
    }
}

#Preview {
    DataBaseView()
        .modelContainer(previewContainer)
}

struct DataBaseTransactionView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(content: {
            Text(transaction.shop?.name ?? "no Shop")
        })
    }
}

#Preview {
    ModelPreview(content: { transaction in
        DataBaseTransactionView(transaction: transaction)
    })
}
