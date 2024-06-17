// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData
import MapKit

@Model class Shop: Codable {
    // MARK: Properties
    var name: String
    var address: String
    
    // MARK: Helpers for non-suppported SwiftData types
    private var latitude: Double = 0
    private var longitude: Double = 0
    private var colorData: UInt?
    
    // MARK: Relationships
    var transactions: [Transaction]? = []
    
    // MARK: Transient
    @Transient var color: Color! {
        get {
            guard let colorData: UInt = colorData else { return .primary }
            return Color.init(hex: colorData)
        }
        set {
            colorData = newValue?.hex
        }
    }
    
    @Transient var mapItem: MKMapItem {
        get {
            let mapItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)))
            mapItem.name = self.name
            return mapItem
        }
        set(newValue) {
            if let name = newValue.name, name != "Unknown Location" { self.name = name }
            latitude = newValue.placemark.coordinate.latitude
            longitude = newValue.placemark.coordinate.longitude
        }
    }
    
    @Attribute(.ephemeral) var searchTerm: String {
        return name + address + "\(latitude)\(longitude)" + (mapItem.name ?? "")
    }
    
    // MARK: Transient KeyPath, manual because cant sort by transient
//    @Transient var transactionsCount: Int { transactions?.count }
    var transactionsCount: Int = 0
//    @Transient var amount: Decimal { transactions?.reduce(0, { $0 + $1.amount }) ?? 0 }
    var amount: Decimal = Decimal(0)
    // @Transient var average: Decimal { transactionsCount == 0 ? 0 : amount / Decimal(transactionsCount) }
    var average: Decimal = Decimal(0)    /// average per transaction
    
    // MARK: init
    /// only relationships default initialized, because they get set in transaction, so not necessarry for init
    init(name: String, address: String, mapItem: MKMapItem, color: Color?) {
        self.name = name
        self.address = address
        // self.coordinates = coordinates
        self.mapItem = mapItem
        self.colorData = color?.hex
    }
    
    // MARK: Functions
    func updateTransient() {
        self.transactionsCount = transactions?.count ?? 0
        self.amount = transactions?.reduce(0, { $0 + $1.amount }) ?? 0
        self.average = transactionsCount == 0 ? 0 : amount / Decimal(transactionsCount)
    }
    func delete() {
        /// only delete if empty
        guard transactions?.isEmpty ?? false else { return }
        self.modelContext?.delete(self)
    }
    func update() {
        updateTransient()
        self.delete()
    }
    func remove(transaction: Transaction) {
        self.transactions?.removeAll(where: { $0 === transaction })
        self.update()
    }
    
    // MARK: Codable
    private enum CodingKeys: String, CodingKey {
        case name
        case address
        case latitude
        case longitude
        case colorData
        case transactions
        case transactionsCount
        case amount
        case average
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        address = try container.decode(String.self, forKey: .address)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        colorData = try container.decode(UInt.self, forKey: .colorData)
        transactions = try container.decode([Transaction].self, forKey: .transactions)
        transactionsCount = try container.decode(Int.self, forKey: .transactionsCount)
        amount = try container.decode(Decimal.self, forKey: .amount)
        average = try container.decode(Decimal.self, forKey: .average)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(address, forKey: .address)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encode(colorData, forKey: .colorData)
        try container.encode(transactions, forKey: .transactions)
        try container.encode(transactionsCount, forKey: .transactionsCount)
        try container.encode(amount, forKey: .amount)
        try container.encode(average, forKey: .average)
    }
}
