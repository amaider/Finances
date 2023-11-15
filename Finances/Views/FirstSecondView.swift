// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct FirstSecondView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    
    init(date: Date, sort descriptors: [SortDescriptor<Transaction>], searchTerm: String) {
        let startMonth: Date = date.startOfMonth()
        let endMonth: Date = date.endOfMonth()
        
        _transactions = Query(
            filter: #Predicate {
                if searchTerm.isEmpty {
                    return $0.date > startMonth && $0.date < endMonth
                } else {
                    return $0.shop?.name.localizedStandardContains(searchTerm) ?? false
                }
            },
            sort: descriptors
        )
        
    }
    
    var body: some View {
        List(content: {
            ForEach(transactions, content: { transaction in
                NavigationLink(destination: {
                    TransactionDetailView(transaction: transaction)
                }, label: {
                    TransactionRowViewSmall(transaction: transaction, isSelected: false)
                        .contentShape(Rectangle())
                        .contextMenu(menuItems: {
                            NavigationLink(destination: {
                                TransactionEditSheet(transaction: transaction)
                            }, label: { Label("Edit", systemImage: "square.and.pencil")})
                            Button("Duplicate", systemImage: "doc.on.doc.fill", action: { transaction.duplicate() })
                            Button("Delete", systemImage: "trash", role: .destructive, action: { transaction.deleteOtherRelationships() })
                        }, preview: {
                            ReceiptView(transaction: transaction)
                        })
                })
            })
        })
        .listStyle(.plain)
        .overlay(content: {
            if transactions.isEmpty {
                ContentUnavailableView("No Transactions", systemImage: "doc.richtext")
            }
        })
        // Text("Summe")
    }
}

#Preview {
    FirstSecondView(date: .iso8601(year: 2021, month: 5), sort: [SortDescriptor(\Transaction.date), SortDescriptor(\Transaction.shop?.name)], searchTerm: "")
        .modelContainer(previewContainer)
        .monospaced()
}
