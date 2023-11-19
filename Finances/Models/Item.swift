// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import Foundation
import SwiftUI
import SwiftData

@Model class Item {
    var name: String
    var note: String
    var volume: String
    var amount: Decimal

    var transaction: Transaction?
    
//    var date: Date { transaction.date }
    var date: Date?
    
    init(name: String, note: String, volume: String, amount: Decimal, transaction: Transaction? = nil, date: Date?) {
        self.name = name
        self.note = note
        self.volume = volume
        self.amount = amount
        self.date = date
        self.transaction = transaction
    }
    
    func delete() {
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
}
