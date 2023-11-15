// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    let transaction: Transaction
    
    @State private var showEditSheet: Bool = false
    
    var body: some View {
        ScrollView(content: {
            ReceiptView(transaction: transaction)
            
            // MARK: Documents
            GroupBox(content: {
                ScrollView(.horizontal, content: {
                    HStack(content: {
                        ForEach(0...2, id: \.self, content: {
                            Text("Doc\($0)")
                                .aspectRatio(2, contentMode: .fit)
                                .frame(width: 50, height: 100)
                                .contextMenu(ContextMenu(menuItems: {
                                    Text("Delete")
                                    Text("Share")
                                }))
                                .background(.red.opacity(0.3))
                        })
                    })
                })
            }, label: {
                
            })
            
            // MARK: Note
            GroupBox(content: {
                LabeledContent(content: {
                    Image(systemName: "tag")
                }, label: {
                    Text(transaction.category?.name ?? "no category")
                })
                
                if let note: String = transaction.note {
                    Divider()
                    Text(note)
                }
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
        })
        .onChange(of: transaction.isDeleted, {
            if $1 { dismiss() }
        })
        .sheet(isPresented: $showEditSheet, content: {
            TransactionEditSheet(transaction: transaction)
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
