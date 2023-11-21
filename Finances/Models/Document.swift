// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

@Model class Document: Codable {
    var url: URL
    // @Attribute(.externalStorage) var data: Data
    
    @Relationship(inverse: \Transaction.documents) var transaction: Transaction?
    
//    var size: Int { filesizekey }
    var size: Int
    
    init(url: URL, transaction: Transaction? = nil, size: Int) {
        self.url = url
//        self.data = data
        self.transaction = transaction
        self.size = size
    }
    
    func delete() {
        guard let context = self.modelContext else { return }
        context.delete(self)
    }
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case url
//        case data
        case transaction
        case size
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        url = try container.decode(URL.self, forKey: .url)
//        data = try container.decode(Data.self, forKey: .data)
        transaction = try container.decode(Transaction.self, forKey: .transaction)
        size = try container.decode(Int.self, forKey: .size)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
//        try container.encode(data, forKey: .data)
        try container.encode(transaction, forKey: .transaction)
        try container.encode(size, forKey: .size)
    }
}
