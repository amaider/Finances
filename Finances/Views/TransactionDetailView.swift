// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct TransactionDetailView: View {
    let transaction: Transaction
    
    var body: some View {
        NavigationView(content: {
            Form(content: {
                Text(transaction.shop?.name ?? "No Shop")
                    .font(.title)
                    .bold()
                Text(transaction.shop?.location ?? "No Location")
                    .foregroundStyle(.gray)
                
            })
            .formStyle(.columns)
        })
        .navigationTitle("Details")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar(content: {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing, content: {
                Button("Edit", action: {})
            })
            #endif
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
