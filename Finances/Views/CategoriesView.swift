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
    @Query var categories: [Category]
    
    var body: some View {
        List(content: {
            ForEach(categories, content: { category in
                Text(category.name)
            })
        })
    }
}

#Preview {
    CategoriesView()
}
