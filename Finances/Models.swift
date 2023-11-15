// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftData
import SwiftUI

@Model class Transaction {
    var shop: Shop?
    var date: Date
    var amount: Int
//    var amount: Int { items.reduce($0, $1.amount) }
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
    
    // create "local" transaction with all new relationships
    // this function looks for existing relationships and replaces them if necessarry
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
        
        let transaction: Transaction = .init(shop: self.shop, date: self.date, amount: self.amount, category: self.category)
//        self.shop?.transactions.append(transaction)
//        self.category?.transactions.append(transaction)
        context.insert(transaction)
    }
    
    func update(with newTransaction: Transaction) {
        if self.shop?.name != newTransaction.shop?.name {
            // save old shop for late so we can delete old shop if empty
            let oldShop: Shop? = self.shop
            
            // find new shop
            let shops: [Shop]? = try? self.modelContext?.fetch(FetchDescriptor<Shop>())
            let shop: Shop = shops?.first(where: { $0.name == newTransaction.shop?.name }) ?? Shop(name: newTransaction.shop?.name ?? "Nan")
            if !(shops?.contains(shop) ?? false) { self.modelContext?.insert(shop) }
            
            self.shop = shop
            oldShop?.delete()
        }
        
        self.date = newTransaction.date
        self.amount = newTransaction.amount
        
        if self.category?.name != newTransaction.category?.name {
            // save old category for late so we can delete old category if empty
            let oldCategory: Category? = self.category
            
            // find new category
            let categories: [Category]? = try? self.modelContext?.fetch(FetchDescriptor<Category>())
            let category: Category = categories?.first(where: { $0.name == self.category?.name }) ?? Category(name: newTransaction.category?.name ?? "Nan")
            if !(categories?.contains(category) ?? false) { self.modelContext?.insert(category) }
            
            self.category = category
            oldCategory?.delete()
        }
        
        self.note = newTransaction.note
    }
    
    // users can only delete transactions, so delete from other @Models as well
    func deleteOtherRelationships() {
        // delete transaction from modelContext
        guard let context = self.modelContext else { return }
        context.delete(self)
        
        
        // replace these with @Relationship(deleteRules:) ?
        if let shop: Shop = self.shop {
            // delete from shop
            shop.transactions.removeAll(where: { $0 === self })
            // delete shop if empty
            if shop.transactions.isEmpty { context.delete(shop) }
        }
        if let category: Category = self.category {
            // delete from category
            category.transactions.removeAll(where: { $0 === self })
            // delete category if empty
            if category.transactions.isEmpty { context.delete(category) }
        }
        // for item in self.items ?? [] {
        //     // delete from item
        //     item.transactions.removeAll(where: { $0 === self })
        //     // delete item if empty
        //     if item.transactions.isEmpty { context.delete(item) }
        // }
        // for document in self.documents ?? [] {
        //     // delete from document
        //     document.self = nil
        //     context.delete(document)
        // }
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
    var url: URL
    // @Attribute(.externalStorage) var data: Data
    
    var transaction: Transaction?
    
    init(url: URL) {
        self.url = url
//        self.data = data
    }
}
