// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Category: Codable {
    // MARK: Properties
    var name: String
    
    // MARK: Relationships
    var transactions: [Transaction]?

    // MARK: Transient KeyPath
    //    @Transient var transactionsCount: Int { transactions?.count }
    var transactionsCount: Int = 0
    //    @Transient var amount: Decimal { transactions?.reduce(0, { $0 + $1.amount }) ?? 0 }
    var amount: Decimal = Decimal(0)
    // @Transient var average: Decimal { transactionsCount == 0 ? 0 : amount / Decimal(transactionsCount) }
    var average: Decimal = Decimal(0)    /// average per transaction
    
    
    // MARK: init
    init(name: String, transactions: [Transaction]? = []) {
        self.name = name
        self.transactions = transactions
    }
    
    // MARK: Functions
    func delete() {
        /// only delete if empty
        if !(transactions?.isEmpty ?? true) { return }
        self.modelContext?.delete(self)
    }
    func update() {
        self.transactionsCount = transactions?.count ?? 0
        self.amount = transactions?.reduce(0, { $0 + $1.amount }) ?? 0
        self.average = transactionsCount == 0 ? 0 : amount / Decimal(transactionsCount)
        self.delete()
    }
    func remove(transaction: Transaction) {
        self.transactions?.removeAll(where: { $0 === transaction })
        self.update()
    }
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case transactions
        case transactionsCount
        case amount
        case average
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
        transactionsCount = try container.decode(Int.self, forKey: .transactionsCount)
        amount = try container.decode(Decimal.self, forKey: .amount)
        average = try container.decode(Decimal.self, forKey: .average)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(transactionsCount, forKey: .transactionsCount)
        try container.encode(amount, forKey: .amount)
        try container.encode(average, forKey: .average)
    }
}
