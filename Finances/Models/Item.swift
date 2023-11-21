// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import Foundation
import SwiftUI
import SwiftData

@Model class Item: Codable {
    // MARK: Properties
    var name: String
    var note: String
    var volume: String
    var amount: Decimal

    // MARK: Relationships
    var transaction: Transaction?
    
    // MARK: Transient KeyPath
//    @Transient var date: Date { transaction.date }
    var date: Date?
    
    // MARK: init
    init(name: String, note: String, volume: String, amount: Decimal, transaction: Transaction? = nil, date: Date?) {
        self.name = name
        self.note = note
        self.volume = volume
        self.amount = amount
        self.transaction = transaction
        self.date = date
    }
    
    // MARK: Functions
    func delete() {
        if transaction == nil { return }
        self.modelContext?.delete(self)
    }
    func update() {
        self.date = transaction?.date
        delete()
    }
    func remove(transaction: Transaction) {
        self.transaction = nil
        self.update()
    }
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case note
        case volume
        case amount
        case transaction
        case date
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        note = try container.decode(String.self, forKey: .note)
        volume = try container.decode(String.self, forKey: .volume)
        amount = try container.decode(Decimal.self, forKey: .amount)
        transaction = try container.decode(Transaction.self, forKey: .transaction)
        date = try container.decode(Date.self, forKey: .date)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(note, forKey: .note)
        try container.encode(volume, forKey: .volume)
        try container.encode(amount, forKey: .amount)
        try container.encode(transaction, forKey: .transaction)
        try container.encode(date, forKey: .date)
    }
}
