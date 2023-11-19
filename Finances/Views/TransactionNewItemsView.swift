// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct TransactionNewItemsView: View {
    @Binding var itemsInput: [Item]
    
    var body: some View {
        List(content: {
            Section(content: {
                NavigationLink("Add Item", destination: {
                    Text("nice")
                })
            })
            
            Section("Items", content: {
                ForEach(itemsInput, content: { item in
                    Text("")
                })
            })
        })
    }
}

#Preview {
    TransactionNewItemsView(itemsInput: .constant([]))
}
