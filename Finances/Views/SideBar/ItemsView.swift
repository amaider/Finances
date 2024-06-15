// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct ItemsView: View {
    @AppStorage("iSortKey") var sortKeyPathHelper: Int = 0
    
    var body: some View {
        ItemsListView()
    }
}

struct ItemsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var items: [Item]
    
    var body: some View {
        List(content: {
            ForEach(items, content: { item in
                ItemRowView(item: item)
            })
        })
    }
}

#Preview {
    ItemsView()
}
