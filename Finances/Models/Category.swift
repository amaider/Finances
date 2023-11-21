// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Category: Codable {
    
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
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case transactions
        case amount
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
        amount = try container.decode(Decimal.self, forKey: .amount)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(amount, forKey: .amount)
    }
}
