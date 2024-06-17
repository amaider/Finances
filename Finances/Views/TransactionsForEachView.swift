// 2024-06-15, Swift 5.0, macOS 14.4, Xcode 15.2
// Copyright © 2024 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct TransactionForEachView: View {
    @Query var transactions: [Transaction]
    
    init(sort descriptors: [SortDescriptor<Transaction>]? = nil, searchTerm: String? = nil) {
        _transactions = Query(
            filter: #Predicate {
                if searchTerm?.isEmpty ?? true {
                    return true
                } else {
                    return $0.searchTerms.localizedStandardContains(searchTerm!)
                }
            },
            sort: descriptors ?? []
        )
        //        _transactions = Query(filter: Predicate({
        //            PredicateExpression.build_Conditional(<#T##Test#>, <#T##If#>, <#T##Else#>)
        //        }))
    }
    init(date: Date, span: Calendar.Component, sort descriptors: [SortDescriptor<Transaction>]? = nil, searchTerm: String? = nil) {
        let startDate: Date = switch span {
            case .year: date.startOf(.year)
            default: date.startOf(.month)
        }
        let endDate: Date = switch span {
            case .year: date.endOf(.year)
            default: date.endOf(.month)
        }
        _transactions = Query(
            filter: #Predicate {
                if searchTerm?.isEmpty ?? true {
                    return $0.date >= startDate && $0.date <= endDate
                } else {
                    return $0.searchTerms.localizedStandardContains(searchTerm!)
                }
            },
            sort: descriptors ?? []
        )
        
    }
    
    // init(date: Date?, shop: Shop?, category: Category?, sort descriptors: [SortDescriptor<Transaction>], searchTerm: String) {
    //     if let date: Date = date {
    //         let startMonth: Date = date.startOf(.month)
    //         let endMonth: Date = date.endOf(.month
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
        }
    }
}

#Preview {
    TransactionForEachView(date: .iso8601(year: 2021, month: 5), span: .month, sort: [SortDescriptor(\Transaction.date), SortDescriptor(\Transaction.shop?.name)], searchTerm: "")
        .modelContainer(previewContainer)
        .monospaced()
}

