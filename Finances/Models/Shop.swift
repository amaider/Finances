// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Shop {
    var name: String
    var location: String
    var colorData: ColorData
    var transactions: [Transaction]?
    
    @Transient var color: Color { colorData.color }
//    @Transient var amount: Decimal { transactions?.reduce(0, { $0 + $1.amount }) ?? 0}
    var amount: Decimal
    
    init(name: String, location: String, colorData: ColorData = .init(.primary), transactions: [Transaction]? = [], amount: Decimal) {
        self.name = name
        self.location = location
        self.colorData = colorData
        self.transactions = transactions
        self.amount = amount
    }
    
    // only delete if empty
    func delete() {
        if !(transactions?.isEmpty ?? true) { return }
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
    
    static func delete(_ shop: Shop) {
        if !(shop.transactions?.isEmpty ?? true) { return }
        guard let context = shop.modelContext else { return }
        context.delete(shop)
    }
}
