// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import Foundation
import SwiftData
import SwiftUI

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
                
                let shopColorsDict: Dictionary<String, Color> = [
                    "Rewe" : .red,
                    "Netto" : .yellow,
                    "Bäcker" : .cyan,
                    "Studienkosten": Color.green,
                    "unity-media": Color.blue,
                    "aliexpress": Color.red
                ]
                let shopCategoryDict: Dictionary<String, String> = [
                    "Rewe" : "Food",
                    "Netto" : "Food",
                    "Bäcker" : "Food",
                    "Studienkosten": "Taschengeld",
                    "unity-media": "Rent",
                    "aliexpress": "Hobby"
                ]
                
                let colorInput: Color? = shopColorsDict[columns[1]]
                
                let categoryInput: String = shopCategoryDict[columns[1]] ?? "other"
                let category: Category = Category(name: categoryInput, amount: Decimal(0))
                
                let shop: Shop = .init(name: columns[1], location: "", color: colorInput, amount: Decimal(0))
                let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .now
                let amount: Decimal = Decimal((Double(columns[3]) ?? 0) * 100) * -1
                let note: String = [columns[4], columns[6]].joined(separator: "\n")
                let transaction: Transaction = .init(shop: shop, date: date, amount: amount, items: [], documents: [], category: category, note: note, searchTerms: "")
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
