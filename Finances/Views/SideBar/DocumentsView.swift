// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

struct DocumentsView: View {
    @AppStorage("dSortKey") var sortKeyPathHelper: Int = 0
    
    var body: some View {
        DocumentsListView()
    }
}

struct DocumentsListView: View {
    @Environment(\.modelContext) var modelContext
    @Query var documents: [Document]
    
    var body: some View {
        List(content: {
            ForEach(documents, content: { document in
                Text(document.url.lastPathComponent)
            })
        })
    }
}

#Preview {
    DocumentsView()
}
