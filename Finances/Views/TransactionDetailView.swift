// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    // @Query var categories: [Category]
    
    let transaction: Transaction
    
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        ScrollView(content: {
            ReceiptView(transaction: transaction)
            
            // MARK: Documents
            GroupBox(content: {
                if !(transaction.documents?.isEmpty ?? true) {
                    ScrollView(.horizontal, content: {
                        HStack(content: {
                            ForEach(transaction.documents!, content: { document in
                                Text(document.url.lastPathComponent)
                                    .aspectRatio(2, contentMode: .fit)
                                    .frame(width: 50, height: 100)
                                    .contextMenu(ContextMenu(menuItems: {
                                        Text("Share")
                                        Text("Delete")
                                    }))
                                    .background(.red.opacity(0.3))
                            })
                        })
                    })
                } else {
                    Text("No Documents")
                        .opacity(0.5)
                        .frame(maxWidth: .infinity)
                }
            })
            
            // MARK: Note
            GroupBox(content: {
                LabeledContent(content: {
                    Image(systemName: "tag")
                }, label: {
                    // let categoryBinding: Binding<Category> = Binding(
                    //     get: { transaction.category ?? categories.first(where: { $0.name == "other" }) ?? Category(name: "other") },
                    //     set: { newValue in transaction.category = newValue }
                    // )
                    // Picker("Category Picker", selection: categoryBinding, content: {
                    //     ForEach(categories, content: { category in
                    //         Text(category.name).tag(category)
                    //     })
                    // })
                    // .labelsHidden()
                    
                   Text(transaction.category?.name ?? "nil")
                })
                
                if !transaction.note.isEmpty {
                    Divider()
                    Text(transaction.note)
                }
            })
            
            GroupBox(content: {
                Text(transaction.searchTerms)
            })
        })
        .padding(.horizontal)
        .navigationTitle("Details")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .toolbar(content: {
            ToolbarItem(placement: .topBarTrailing, content: {
                Button("Edit", action: { showEditSheet.toggle() })
            })
            
            ToolbarItem(placement: .bottomBar, content: {
                Button("delte", role: .destructive, action: { transaction.deleteOtherRelationships() })
                    .foregroundStyle(.red)
            })
        })
        .onChange(of: transaction.isDeleted, {
            if $1 { dismiss() }
        })
        .sheet(isPresented: $showEditSheet, content: {
            NavigationView(content: {
                TransactionNewSheet(transaction: transaction)                
            })
        })
    }
}

#Preview {
    ModelPreview(content: { transaction in
        NavigationStack(root: {
            TransactionDetailView(transaction: transaction)
        })
    })
}
