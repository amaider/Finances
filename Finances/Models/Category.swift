// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Category {
    var name: String
    
    var transactions: [Transaction]?

//    @Transient var amount: Decimal { transactions?.reduce(0, { $0 + $1.amount }) ?? 0 }
    var amount: Decimal
    
    init(name: String, transactions: [Transaction]? = [], amount: Decimal) {
        self.name = name
        self.transactions = transactions
        self.amount = amount
    }
    
    func delete() {
        if !(transactions?.isEmpty ?? true) { return }
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
}
