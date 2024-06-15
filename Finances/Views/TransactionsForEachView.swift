// 2024-06-15, Swift 5.0, macOS 14.4, Xcode 15.2
// Copyright © 2024 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct TransactionForEachView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    
    @State var showMonthReceiptSheet: Bool = false
    var monthAmount: Decimal { transactions.reduce(0, { $0 + $1.amount })}
    //    @State var monthPresentationDetent: PresentationDetent = .height(50)
    
    
    
    init(date: Date, sort descriptors: [SortDescriptor<Transaction>], searchTerm: String) {
        let startMonth: Date = date.startOfMonth()
        let endMonth: Date = date.endOfMonth()
        
        _transactions = Query(
            filter: #Predicate {
                if searchTerm.isEmpty {
                    return $0.date >= startMonth && $0.date <= endMonth
                } else {
                    //                     return $0.shop?.name.localizedStandardContains(searchTerm) ?? false
                    return $0.searchTerms.localizedStandardContains(searchTerm)
                    // $0.searchTerms.contains(where: { return $0.localizedStandardContains(searchTerm) })
                }
            },
            sort: descriptors
        )
    }
    
    // init(date: Date?, shop: Shop?, category: Category?, sort descriptors: [SortDescriptor<Transaction>], searchTerm: String) {
    //     if let date: Date = date {
    //         let startMonth: Date = date.startOfMonth()
    //         let endMonth: Date = date.endOfMonth()
    //
    //         _transactions = Query(
    //             filter: #Predicate {
    //                 if searchTerm.isEmpty {
    //                     return $0.date >= startMonth && $0.date <= endMonth
    //                 } else {
    //                     return $0.searchTerms.contains(searchTerm)
    //                 }
    //             },
    //             sort: descriptors
    //         )
    //     } else if let shop: Shop = shop {
    //         _transactions = Query(
    //             filter: #Predicate {
    //                 if searchTerm.isEmpty {
    //                     return $0.shop == shop
    //                 } else {
    //                     return $0.searchTerms.contains(searchTerm)
    //                 }
    //             },
    //             sort: descriptors
    //         )
    //     } else if let category: Category = category {
    //         _transactions = Query(
    //             filter: #Predicate {
    //                 if searchTerm.isEmpty {
    //                     return $0.category == category
    //                 } else {
    //                     return $0.searchTerms.contains(searchTerm)
    //                 }
    //             },
    //             sort: descriptors
    //         )
    //     }
    // }
    
    var body: some View {
        if transactions.isEmpty {
            ContentUnavailableView("No Transactions", systemImage: "doc.richtext")
                .listRowSeparator(.hidden)
        } else {
            ForEach(transactions, content: { transaction in
                NavigationLink(destination: {
                    TransactionDetailView(transaction: transaction)
                }, label: {
                    TransactionRowViewSmall(transaction: transaction, isSelected: false)
                })
                .buttonStyle(.plain)
            })
            .listRowSeparator(.hidden)
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar) {
                    HStack(alignment: .lastTextBaseline, content: {
                        Text("Total")
                        Spacer()
                        Text(monthAmount, format: .currency(code: "EUR"))
                            .foregroundColor(monthAmount > 0 ? .green : .red)
                    })
                    .font(.title2)
                    .bold()
                    .onTapGesture(perform: { showMonthReceiptSheet.toggle() })
                }
            })
            .sheet(isPresented: $showMonthReceiptSheet, content: {
                CategorySheet(transactions: transactions)
                    .padding(.horizontal)
                    .presentationDetents([.medium])
                    .presentationBackgroundInteraction(.enabled)
            })
        }
    }
}

#Preview {
    TransactionForEachView(date: .iso8601(year: 2021, month: 5), sort: [SortDescriptor(\Transaction.date), SortDescriptor(\Transaction.shop?.name)], searchTerm: "")
        .modelContainer(previewContainer)
        .monospaced()
}

