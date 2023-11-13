// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftData
import SwiftUI

@Model class Transaction {
    var shop: Shop?
    var date: Date
    var amount: Int
    var category: Category?
     // @Relationship(inverse: \Item.transactions) var items: [Item]?
    // var documents: [Document]?
    var note: String?
    
    @Transient var searchTerms: Set<String> {
        var result: Set<String> = []
        
        if let shopString = shop?.name { result.insert(shopString) }
        result.insert(Formatter.dateFormatter.string(from: date))
        if let amountString: String = Formatter.currencyFormatter.string(from: Double(amount) / 100.0 as NSNumber) { result.insert(amountString) }
        if let categoryString: String = category?.name { result.insert(categoryString) }
        //        items?.forEach({
        //            $0.name.split(separator: " ").map(String.init).forEach({ result.insert($0) })
        //            if let noteString: String = $0.note { result.insert(noteString) }
        //            result.insert($0.volume)
        //            if let amountString: String = Formatter.currencyFormatter.string(from: Double($0.amount) / 100.0 as NSNumber) { result.insert(amountString) }
        //        })
        // documents?.forEach({ result.insert($0.name) })
        note?.split(separator: " ").map(String.init).forEach({ result.insert($0) })
        
        return result
    }
    
    init(shop: Shop?, date: Date, amount: Int, category: Category?, items: [Item]? = nil, documents: [Document]? = nil, note: String? = nil) {
        self.shop = shop
        self.date = date
        self.amount = amount
        self.category = category
        // self.items = items
        // self.documents = documents
        self.note = note
    }
    
    // users can only delete transactions, so delete from other @Models as well
    static func deleteOtherRelationships(_ transaction: Transaction) {
        // delete transaction from modelContext
        guard let context = transaction.modelContext else { return }
        context.delete(transaction)
        
        
        // replace these with @Relationship(deleteRules:) ?
        if let shop: Shop = transaction.shop {
            // delete from shop
            shop.transactions.removeAll(where: { $0 === transaction })
            // delete shop if empty
            if shop.transactions.isEmpty { context.delete(shop) }
        }
        if let category: Category = transaction.category {
            // delete from category
            category.transactions.removeAll(where: { $0 === transaction })
            // delete category if empty
            if category.transactions.isEmpty { context.delete(category) }
        }
        // for item in transaction.items ?? [] {
        //     // delete from item
        //     item.transactions.removeAll(where: { $0 === transaction })
        //     // delete item if empty
        //     if item.transactions.isEmpty { context.delete(item) }
        // }
        // for document in transaction.documents ?? [] {
        //     // delete from document
        //     document.transaction = nil
        //     context.delete(document)
        // }
    }
    
    static func example() -> Transaction {
        let transaction: Transaction = .init(shop: nil, date: .now, amount: 123, category: nil, items: nil, documents: nil)
        transaction.shop = .init(name: "Rewe", location: "Mitte", colorData: .init(.red))
        transaction.category = .init(name: "Food")
        return transaction
    }
}

@Model class Shop {
    var name: String
    var location: String?
    var colorData: ColorData?
    var transactions: [Transaction] = []
    
    @Transient var color: Color { colorData?.color ?? .primary }
    
    init(name: String, location: String? = nil, colorData: ColorData? = nil) {
        self.name = name
        self.location = location
        self.colorData = colorData
    }
    
    // only delete if empty
    func delete() {
        if !transactions.isEmpty { return }
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
    
    static func delete(_ shop: Shop) {
        if !shop.transactions.isEmpty { return }
        guard let context = shop.modelContext else { return }
        context.delete(shop)
    }
}

@Model class Category {
    //   @Attribute(.unique)
    var name: String
    
    //    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction] = []
    
    init(name: String) {
        self.name = name
    }
    init(name: String, transactions: [Transaction]) {
        self.name = name
        self.transactions = transactions
    }
    
    func delete() {
        if !transactions.isEmpty { return }
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
}

@Model class Item {
    var name: String
    var amount: Int
    var volume: String
    var note: String?
    
    var transactions: [Transaction] = []
    
    init(name: String, amount: Int, volume: String, note: String?) {
        self.name = name
        self.amount = amount
        self.volume = volume
    }
}

@Model class Document {
    var name: String
    var dataType: String
    @Attribute(.externalStorage) var data: Data
    
    var transaction: Transaction?
    
    init(name: String, dataType: String, data: Data) {
        self.name = name
        self.dataType = dataType
        self.data = data
    }
}
