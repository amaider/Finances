// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct ShopsView: View {
    @AppStorage("sortKeyPathHelper") var sortKeyPathHelper: Int = 0
    @AppStorage("sortOrder") var sortOrder: Bool = true
    var sortDescriptor: SortDescriptor<Shop> {
        let sortOrder: SortOrder = sortOrder ? .forward : .reverse
        switch sortKeyPathHelper {
            case 2: return SortDescriptor(\.amount, order: sortOrder)
            default: return SortDescriptor(\.name, order: sortOrder)
        }
    }
    
    @State var searchTerm: String = ""
    
    var body: some View {
        ShopsListView(sort: [sortDescriptor], searchTerm: searchTerm)
            .searchable(text: $searchTerm)
            .toolbar(content: {
                ToolbarItem(placement: .topBarTrailing, content: {
                    Menu("Sort", systemImage: "line.3.horizontal.decrease.circle", content: {
                        Picker("Sort", selection: $sortKeyPathHelper, content: {
                            Text("Name").tag(1)
                            Text("Amount").tag(2)
                        })
                        Picker("Order", selection: $sortOrder, content: {
                            Text("Forward").tag(true)
                            Text("Reverse").tag(false)
                        })
                    })
                })
            })
    }
}

struct ShopsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var shops: [Shop]
    
    init(sort descriptors: [SortDescriptor<Shop>], searchTerm: String) {
        _shops = Query(
            filter: #Predicate {
                if searchTerm.isEmpty {
                    return true
                } else {
                    return $0.name.localizedStandardContains(searchTerm)
                }
            },
            sort: descriptors
        )
    }
    
    var body: some View {
        List(content: {
            ForEach(shops, content: { shop in
                DisclosureGroup(content: {
                    NavigationLink(destination: {
                        ForEach(shop.transactions, content: { transaction in
                            NavigationLink(destination: {
                                TransactionDetailView(transaction: transaction)
                            }, label: {
                                TransactionRowViewSmall(transaction: transaction, isSelected: false)
                            })
                            .buttonStyle(.plain)
                        })
                    }, label: {
                        Text("Transactions: \(shop.transactions.count)")
                        Text("Chart Here")
                    })
                }, label: {
                    HStack(content: {
                        let colorBinding: Binding<Color> = Binding(get: { shop.color }, set: { shop.colorData = .init($0) })
                        ColorPicker(selection: colorBinding, supportsOpacity: true, label: {
                            HStack(content: {
                                Text(shop.name)
                                    .foregroundStyle(shop.color)
                                Spacer()
                                Text(Double(shop.amount) / 100.0, format: .currency(code: "EUR"))
                                    .foregroundColor(shop.amount > 0 ? .green : .red)
                                    .shadow(radius: 10)
                            })
                        })
                    })
                })
            })
        })
        .navigationTitle("Shops (\(shops.count))")
    }
}

#Preview {
    ShopsView()
}
