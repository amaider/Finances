// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import Foundation
import SwiftData
import SwiftUI
import MapKit

let previewContainer: ModelContainer = {
    do {
        let schema = Schema([Transaction.self, Shop.self, Category.self, Item.self, Document.self])
        let container = try ModelContainer(for: schema, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        
        Task { @MainActor in
            let context = container.mainContext
            
            // Date,Place,Product,Spending,Tags,Receipt,Comment,Card
            let rows = financesCSV.components(separatedBy: "\n")
            for row in rows {
                let columns = row.components(separatedBy: ",")
                
                let mapItem: MKMapItem = shopMapItemDict[columns[1]] ?? previewMapItem
                let colorInput: Color? = shopColorsDict[columns[1]]
                
                let categoryInput: String = shopCategoryDict[columns[1]] ?? "other"
                let category: Category = Category(name: categoryInput)
                
                let shop: Shop = .init(name: columns[1], address: "", mapItem: mapItem, color: colorInput)
                let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .now
                let amount: Decimal = Decimal((Double(columns[3]) ?? 0) * 100) * -1
                let note: String = [columns[4], columns[6]].joined(separator: "\n")
                let item: Item = Item(name: shop.name, note: "", volume: "", amount: amount, transaction: nil, date: nil)
                let transaction: Transaction = .init(shop: shop, date: date, items: [item], documents: [], category: category, note: note)
                context.insert(transaction)
            }
            
        }
        return container
    } catch {
        fatalError("previewContainer Error: \(error.localizedDescription)")
    }
}()

struct ModelPreview<Model: PersistentModel, Content: View>: View {
    var content: (Model) -> Content
    
    init(@ViewBuilder content: @escaping (Model) -> Content) {
        self.content = content
    }
    
    var body: some View {
        PreviewContentView(content: content)
            .modelContainer(previewContainer)
    }
    
    struct PreviewContentView: View {
        @Query private var models: [Model]
        var content: (Model) -> Content
        
        var body: some View {
            if let model = models.first {
                content(model)
            } else {
                ContentUnavailableView("Could not load model for previews", image: "xmark")
            }
        }
    }
}
