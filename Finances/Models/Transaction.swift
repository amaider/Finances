// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftData
import SwiftUI

@Model class Transaction: Codable {
    var date: Date
    var amount: Decimal
    var note: String
    
    var shop: Shop?
    // @Relationship(inverse: \Item.transactions)
    var items: [Item]?
    // @Relationship(inverse: \Document.transaction)
    var documents: [Document]?
    var category: Category?
    
//    @Transient
//    @Attribute(.ephemeral) var searchTerms: Set<String> {
//        var result: Set<String> = []
//
//        if let shopString = shop?.name { result.insert(shopString) }
//        result.insert(Formatter.dateFormatter.string(from: date))
//        if let amountString: String = Formatter.currencyFormatter.string(from: amount as NSDecimalNumber) { result.insert(amountString) }
//        if let categoryString: String = category?.name { result.insert(categoryString) }
//        items?.forEach({
//            $0.name.split(separator: " ").map(String.init).forEach({ result.insert($0) })
//            $0.note.split(separator: " ").map(String.init).forEach({ result.insert($0) })
//            result.insert($0.volume)
//            if let amountString: String = Formatter.currencyFormatter.string(from: $0.amount as NSDecimalNumber) { result.insert(amountString) }
//        })
//        documents?.forEach({ result.insert($0.url.lastPathComponent) })
//        note.split(separator: " ").map(String.init).forEach({ result.insert($0) })
//
//        return result
//    }
    var searchTerms: String
    
    
    init(shop: Shop? = nil, date: Date, amount: Decimal = Decimal(0), items: [Item]? = [], documents: [Document]? = [], category: Category? = nil, note: String, searchTerms: String = "") {
        self.shop = shop
        self.date = date
        self.amount = amount
        self.category = category
        self.items = items
        self.documents = documents
        self.note = note
        self.searchTerms = searchTerms
    }
    
    /// create "local" transaction with all new relationships
    /// this function looks for existing relationships and replaces them if necessarry
    func add(modelContext: ModelContext) {
        do {
            let shops: [Shop] = try modelContext.fetch(FetchDescriptor<Shop>())
            // let shop: Shop = shops.first(where: { $0.name == self.shop?.name }) ?? self.shop ?? Shop(name: "nan")
            // if !shops.contains(shop) {
            //     modelContext.insert(shop)
            // }
            let categories: [Category] = try modelContext.fetch(FetchDescriptor<Category>())
            // let category: Category = categories.first(where: { $0.name == self.category?.name }) ?? self.category ?? Category(name: "nan")
            // if !categories.contains(category) {
            //     modelContext.insert(category)
            // }
            
            // let transaction: Transaction = .init(shop: shop, date: self.date, amount: self.amount, category: category, note: self.note)
//             category.transactions.append(transaction)
//             shop.transactions.append(transaction)
            print(shops.count, categories.count)
            modelContext.insert(self)
        } catch {
            fatalError("lol fuck me 123 \(error.localizedDescription)")
        }
    }
    
    func duplicate() {
        guard let context = self.modelContext else { return }
        
        let transaction: Transaction = .init(shop: self.shop, date: self.date, amount: self.amount, items: self.items, documents: self.documents, category: self.category, note: self.note, searchTerms: self.searchTerms)
//        self.shop?.transactions.append(transaction)
//        self.category?.transactions.append(transaction)
        context.insert(transaction)
    }
    
    // func update2(shop: Shop?, date: Date, amount: Decimal, category: Category?, items: [Item]?, documents: [Document]?, note: String) {
    //     self.shop = shop
    //     self.date = date
    //     self.amount = amount
    //     self.category = category
    //     self.items = items
    //     self.documents = documents
    //     self.note = note
    // }
    // func update(with newTransaction: Transaction) {
    //     if self.shop?.name != newTransaction.shop?.name {
    //         /// save old shop for late so we can delete old shop if empty
    //         let oldShop: Shop? = self.shop
    //         
    //         /// find new shop
    //         let shops: [Shop]? = try? self.modelContext?.fetch(FetchDescriptor<Shop>())
    //         let shop: Shop = shops?.first(where: { $0.name == newTransaction.shop?.name }) ?? Shop(name: newTransaction.shop?.name ?? "Nan", location: "", color: nil, amount: Decimal(0), transactionsCount: 0)
    //         if !(shops?.contains(shop) ?? false) { self.modelContext?.insert(shop) }
    //         
    //         self.shop = shop
    //         oldShop?.delete()
    //     }
    //     
    //     self.date = newTransaction.date
    //     self.amount = newTransaction.amount
    //     
    //     if self.category?.name != newTransaction.category?.name {
    //         // save old category for late so we can delete old category if empty
    //         let oldCategory: Category? = self.category
    //         
    //         // find new category
    //         let categories: [Category]? = try? self.modelContext?.fetch(FetchDescriptor<Category>())
    //         let category: Category = categories?.first(where: { $0.name == self.category?.name }) ?? Category(name: newTransaction.category?.name ?? "Nan", amount: Decimal(0))
    //         if !(categories?.contains(category) ?? false) { self.modelContext?.insert(category) }
    //         
    //         self.category = category
    //         oldCategory?.delete()
    //     }
    //     
    //     self.note = newTransaction.note
    // }
    
    /// users can only delete transactions, so delete from other @Models as well
    func deleteOtherRelationships() {
        /// delete transaction from modelContext
        guard let context = self.modelContext else { return }
        context.delete(self)
        
        
        /// replace these with @Relationship(deleteRules:) ?
        if let shop: Shop = self.shop {
            /// delete from shop
            shop.transactions?.removeAll(where: { $0 === self })
            /// delete shop if empty
            if shop.transactions?.isEmpty ?? true { context.delete(shop) }
        }
        if let category: Category = self.category {
            /// delete from category
            category.transactions?.removeAll(where: { $0 === self })
            /// delete category if empty
            if category.transactions?.isEmpty ?? true { context.delete(category) }
        }
        // for item in self.items ?? [] {
        //     /// delete from item
        //     item.transactions.removeAll(where: { $0 === self })
        //     /// delete item if empty
        //     if item.transactions.isEmpty { context.delete(item) }
        // }
        // for document in self.documents ?? [] {
        //     /// delete from document
        //     document.self = nil
        //     context.delete(document)
        // }
    }
    
    static func example() -> Transaction {
        let transaction: Transaction = .init(shop: nil, date: .now, amount: Decimal(1234), items: nil, documents: nil, category: nil, note: "", searchTerms: "")
        transaction.shop = .init(name: "Rewe", location: "Mitte", color: .red, transactionsCount: 0, amount: Decimal(0))
        transaction.category = .init(name: "Food", amount: Decimal(0))
        return transaction
    }
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case date
        case amount
        case note
        case shop
        case items
        case documents
        case category
        case searchTerms
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        amount = try container.decode(Decimal.self, forKey: .amount)
        note = try container.decode(String.self, forKey: .note)
        shop = try container.decode(Shop.self, forKey: .shop)
        items = try container.decode([Item].self, forKey: .items)
        documents = try container.decode([Document].self, forKey: .documents)
        category = try container.decode(Category.self, forKey: .category)
        searchTerms = try container.decode(String.self, forKey: .searchTerms)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encode(amount, forKey: .amount)
        try container.encode(note, forKey: .note)
        try container.encode(shop, forKey: .shop)
        try container.encode(items, forKey: .items)
        try container.encode(documents, forKey: .documents)
        try container.encode(category, forKey: .category)
        try container.encode(searchTerms, forKey: .searchTerms)
    }
}
