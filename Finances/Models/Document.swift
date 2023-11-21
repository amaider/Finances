// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Document: Codable {
    // MARK: Properties
    var url: URL
    // @Attribute(.externalStorage) var data: Data
    
    // MARK: Relationships
    // @Relationship(inverse: \Transaction.documents) 
    var transaction: Transaction?
    
    // MARK: Transient KeyPath
//    @Transient var size: Int { filesizekey }
    var size: Int
//    @Transient var date: Date? { transaction?.date }
    var date: Date?
    
    // MARK: init
    init(url: URL, transaction: Transaction? = nil) {
        self.url = url
//        self.data = data
        self.transaction = transaction
        self.size = 0
        self.date = nil
    }
    
    // MARK: Functions
    func delete() {
        self.modelContext?.delete(self)
    }
    func update() {
        self.size = 0   // todo
        self.date = transaction?.date
    }
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case url
//        case data
        case transaction
        case size
        case date
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
//        data = try container.decode(Data.self, forKey: .data)
        transaction = try container.decode(Transaction.self, forKey: .transaction)
        size = try container.decode(Int.self, forKey: .size)
        date = try container.decode(Date.self, forKey: .date)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
//        try container.encode(data, forKey: .data)
        try container.encode(transaction, forKey: .transaction)
        try container.encode(size, forKey: .size)
        try container.encode(date, forKey: .date)
    }
}
