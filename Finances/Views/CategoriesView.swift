// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct CategoriesView: View {
    var body: some View {
        CategoriesListView()
    }
}

struct CategoriesListView: View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Category.name) var categories: [Category]
    
    @State private var categoryInput: String = ""
    @State private var searchTerm: String = ""
    @FocusState private var refocus: Bool
    
    var body: some View {
        List(content: {
            Section(content: {
                TextField("New Category", text: $categoryInput, prompt: Text("+ Category"))
                    .focused($refocus)
                    .foregroundColor(categories.contains(where: { $0.name == categoryInput }) ? .red : nil)
                    .onSubmit({
                        if categoryInput.isEmpty || categories.contains(where: { $0.name == categoryInput }) { return }
                        let category: Category = Category(name: categoryInput, amount: 0)
                        modelContext.insert(category)
                    })
            })
            
            if let categoriesFiltered: [Category] = try? categories.filter(#Predicate { categoryInput.isEmpty ? true : $0.name.localizedStandardContains(categoryInput) }) {
                ForEach(categoriesFiltered, content: { category in
                    DisclosureGroup(content: {
                        NavigationLink(destination: {
                            TransactionsView()
                        }, label: {
                            Text("Chart here")
                        })
                    }, label: {
                        HStack(content: {
                            Text(category.name)
                            Spacer()
                            Text("\(category.transactions?.count ?? 0) Transactions")
                                .font(.subheadline)
                                .foregroundStyle(.gray)
                            if category.transactions?.isEmpty ?? true {
                                Image(systemName: "trash")
                            }
                        })
                    })
                    .deleteDisabled(category.transactions?.isEmpty == false)
                })
                .onDelete(perform: { indexSet in
                    indexSet.map({ print(categoriesFiltered[$0]) })
                })
            }
        })
        .searchable(text: $searchTerm)
    }
}

#Preview {
    CategoriesView()
}
