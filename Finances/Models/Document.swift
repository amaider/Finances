// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Document {
    var url: URL
    // @Attribute(.externalStorage) var data: Data
    
    @Relationship(inverse: \Transaction.documents) var transaction: Transaction?
    
//    var size: Int { filesizekey }
    var size: Int
    
    init(url: URL, transaction: Transaction? = nil, size: Int) {
        self.url = url
//        self.data = data
        self.transaction = transaction
        self.size = size
    }
    
    func delete() {
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
}
