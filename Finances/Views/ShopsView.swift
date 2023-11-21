// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData
import Foundation

struct ShopsView: View {
    @AppStorage("sSortKey") var sortKeyPathHelper: Int = 0
    @AppStorage("sortOrder") var sortOrder: Bool = true
    var sortDescriptor: SortDescriptor<Shop> {
        let sortOrder: SortOrder = sortOrder ? .forward : .reverse
        switch sortKeyPathHelper {
            case 2: return SortDescriptor(\.amount, order: sortOrder)
            case 3: return SortDescriptor(\.colorData, order: sortOrder)
            case 4: return SortDescriptor(\.transactionsCount, order: sortOrder)
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
                            Text("Color").tag(3)
                            Text("Count").tag(4)
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
                        // MARK: ShopEditView
                        VStack(content: {
                            // Form(content: {
                                let nameBinding: Binding<String> = Binding(
                                    get: { shop.name },
                                    set: { if !$0.isEmpty { shop.name = $0 } }
                                )
                                let locationBinding: Binding<String> = Binding(
                                    get: { shop.location ?? "" },
                                    set: { shop.location = $0 }
                                )
                                let colorBinding: Binding<Color> = Binding(
                                    get: { shop.colorTransient },
                                    set: {
                                        let newColor: Color.Resolved = $0.resolve(in: EnvironmentValues())
                                        if newColor.red > 0.8 && newColor.green > 0.8 && newColor.blue > 0.8 || newColor.red < 0.2 && newColor.green < 0.2 && newColor.blue < 0.2 { shop.colorData = nil }
                                        else { shop.colorData = $0.hex }
                                    }
                                )
                                
                                Section(content: {
                                    TextField("Shop", text: nameBinding)
                                    TextField("Location", text: locationBinding)
                                    ColorPicker("Color", selection: colorBinding)
                                })
                            // })
                            
                            TransactionsListView(date: .now, sort: [SortDescriptor(\.date)], searchTerm: shop.name)
                        })
                    }, label: {
                        Text("Chart Here")
                    })
                }, label: {
                    LabeledContent(content: {
                        VStack(alignment: .trailing, spacing: 0, content: {
                            Text(shop.amount, format: .currency(code: "EUR"))
                                .foregroundColor(shop.amount > 0 ? .green : .red)
                                .shadow(radius: 10)
                            Text("\(shop.transactions?.count ?? 0) Transactions")
                                .font(.caption)
                        })
                    }, label: {
                        Text(shop.name).foregroundStyle(shop.colorTransient)
                        if !shop.location.isEmpty { Text(shop.location) }
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
