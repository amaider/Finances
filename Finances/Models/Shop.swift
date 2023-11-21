// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Shop: Codable {
    var name: String
    var location: String?
    var colorData: UInt?
    
    var transactions: [Transaction]?
    
    @Transient var colorTransient: Color {
        guard let colorData: UInt = colorData else { return .primary }
        return Color.init(hex: colorData)
    }
//    @Transient var transactionsCount: Int { transactions?.count }
    var transactionsCount: Int
//    @Transient var amount: Decimal { transactions?.reduce(0, { $0 + $1.amount }) ?? 0 }
    var amount: Decimal
    
    /// only relationships default initialized, because they get set in transaction, so not necessarry for init
    init(name: String, location: String?, color: Color?, transactions: [Transaction]? = [], transactionsCount: Int, amount: Decimal) {
        self.name = name
        self.location = location
        self.colorData = color?.hex
        self.transactions = transactions
        self.transactionsCount = transactionsCount
        self.amount = amount
    }
    
    /// only delete if empty
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
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case location
        case colorData
        case transactions
        case transactionsCount
        case amount
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        location = try container.decode(String.self, forKey: .location)
        colorData = try container.decode(UInt.self, forKey: .colorData)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
        transactionsCount = try container.decode(Int.self, forKey: .transactionsCount)
        amount = try container.decode(Decimal.self, forKey: .amount)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(location, forKey: .location)
        try container.encode(colorData, forKey: .colorData)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(transactionsCount, forKey: .transactionsCount)
        try container.encode(amount, forKey: .amount)
    }
}
