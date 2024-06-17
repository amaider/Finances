// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData
import Dispatch
import MapKit

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    
    @AppStorage("currency") var currency: String = "EUR"
    @AppStorage("backupSetting") var backupSetting: Int = 0
    @AppStorage("lastBackup") var lastBackup: String = ""
    
    @State private var importCounter: Double = 0
    @State private var importMax: Double = 0
    @State private var showFileImporterJSON: Bool = false
    @State private var showFileImporterCSV1: Bool = false
    @State private var showFileImporterCSV2: Bool = false
    @State private var showFileExporter: Bool = false
    
    @State private var showImportSheet: Bool = false
    
    var body: some View {
        Form(content: {
            Picker("Currency", selection: $currency, content: {
                Text("EUR").tag("EUR")
                Text("DLR").tag("Dlr")
            })
            
            Section(content: {
                Picker("Backup Interval", selection: $backupSetting, content: {
                    Text("Never/Aus").tag(0)
                    Text("Daily").tag(1)
                    Text("Weekly").tag(2)
                    Text("Monthly").tag(3)
                })

                // Button("Import JSON \(showFileImporterJSON ? "on" : "off")", action: { showFileImporterJSON.toggle() })
                //     .sheet(isPresented: .constant(importMax != 0), content: {
                //         ProgressView(value: (importCounter / importMax), label: {
                //             Text("Importing from CSV")
                //         }, currentValueLabel: {
                //             Text("Importing \(importCounter + 1)/\(importMax)")
                //         })
                //     })
                Button("Export JSON \(showFileExporter ? "on" : "off")", action: { showFileExporter.toggle() })
                // Button("ImportCSV1.13", action: { testThis(name: "csv1.13", function: csvImport113) })
                // Button("ImportCSV1.2", action: { testThis(name: "csv1.2", function: csvImport12) })
                Button("Import JSON v3", action: { testThis(name: "csv3", function: csvImportv3 )})
                    .sheet(isPresented: $showImportSheet, content: {
                        ProgressView(value: (importCounter / importMax), label: {
                            Text("Importing from CSV")
                        }, currentValueLabel: {
                            Text("Importing \(importCounter + 1)/\(importMax)")
                        })
                    })
                Button("csv v4", action: csvImport4)
                Button("Delete v4", action: deleteV4)
                Button("Delete All", action: { testThis(name: "deleteAll", function: deleteModelContext) })
            }, header: {
                Text("Backup")
            }, footer: {
                Text("Last Backup: \(Formatter.dateFormatter.date(from: lastBackup)?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
            })
            // .fileImporter(isPresented: $showFileImporterJSON, allowedContentTypes: [.json], onCompletion: fileImporterCompletion)
            // .fileImporter(isPresented: $showFileImporterCSV1, allowedContentTypes: [.commaSeparatedText], onCompletion: fileImporterCompletionCSV1)
            // .fileExporter(isPresented: $showFileExporter, items: items, contentTypes: [.text], onCompletion: { result in
            //     switch result {
            //         case .success(let urls):
            //             print(urls)
            //         case .failure(let error):
            //             NSLog("Error exporting: \(error.localizedDescription)")
            //     }
            // })
        })
    }
    
    // MARK: Functions
    private func fileImporterCompletion(_ result: Result<URL, any Error>) {
        switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url) {
                    if let decodedTransactions = try? JSONDecoder().decode([Transaction].self, from: data) {
                        print(decodedTransactions.count)
                   }
                }
            case .failure(let error):
                print("Error fileImporter: \(error.localizedDescription)")
        }
    }
    
    private func fileImporterCompletionCSV1(_ result: Result<URL, any Error>) {
        // switch result {
        //     case .success(let url):
        //         if let data = try? Data(contentsOf: url) {
        //             if let content: String = String(data: data, encoding: .utf8) {
        //                 let lines: [String] = content.components(separatedBy: .newlines)
        //                 for line in lines {
        //                     let cells = line.components(separatedBy: ",")
        //                     
        //                     let date: Date = Formatter.dateFormatter.date(from: cells[0]) ?? .iso8601(year: 1000, month: 1)
        //                     let place: String = cells[1]
        //                     let product: String = cells[2]
        //                     let spending: Decimal = (try? Decimal(cells[3], format: .number)) ?? 0
        //                     let tags: [String] = cells[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
        //                     let receipt: String = cells[5]
        //                     let comment: String = cells[6]
        //                     let card: String = cells[7]
        //                     
        //                     let tagsString: String = tags.joined(separator: "\n")
        //                     let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
        //                     let colorInput: Color? = shopColorsDict[place]
        //                     let categoryInput: String = shopCategoryDict[place] ?? "other"
        // 
        //                     let transaction: Transaction = .init(date: date, note: noteInput)
        //                     modelContext.insert(transaction)
        //                     
        //                     transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
        //                     transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
        //                     
        //                     let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
        //                     let shop: Shop = shops?.first(where: { $0.name == place && $0.address == "" }) ?? Shop(name: place, address: "", mapItem: previewMapItem, color: colorInput)
        //                     shop.amount += transaction.amount
        //                     transaction.shop = shop
        //                     shop.transactionsCount = shop.transactions?.count ?? 0
        //                     
        //                     // transaction.documents = documentsInput
        //                     
        //                     let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
        //                     let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? categories?.first(where: { $0.name == "nil" }) ?? Category(name: "nil")
        //                     category.amount += transaction.amount
        //                     transaction.category = category
        //                     
        //                     transaction.searchTerms = getSearchTerms(from: transaction).joined()
        //                 }
        //             }
        //             
        //         }
        //     case .failure(let error):
        //         print("Error fileImporter: \(error.localizedDescription)")
        // }
    }
    
    let queue = DispatchQueue(label: "com.io.concurrency", attributes: .concurrent)
    let safetyQueue = DispatchQueue(label: "com.io.concurrency.sync")
    
    // private func csvImport113() {
    //     let rows: [String] = financesCSV1.components(separatedBy: .newlines)
    //     importMax = Double(rows.count)
    //     importCounter = 0
    //     
    //     //        DispatchQueue.global(qos: .userInitiated).async(execute: {
    //     for row in rows {
    //         
    //         let columns = row.components(separatedBy: ",")
    //         
    //         let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
    //         let place: String = columns[1]
    //         let product: String = columns[2]
    //         let spending: Decimal = ((try? Decimal(Double(columns[3]) ?? 6969696)) ?? 0) * -1
    //         //                let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
    //         let tags: [String] = { columns[4].isEmpty ? [] : columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 }) }()
    //         let receipt: String = columns[5]
    //         let comment: String = columns[6]
    //         let card: String = columns[7]
    //         
    //         //                let tagsString: String = tags.joined(separator: "\n")
    //         let tagsString: String = { tags.isEmpty ? "" : tags.joined(separator: "\n") }()
    //         let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
    //         let colorInput: Color? = shopColorsDict[place]
    //         let categoryInput: String = shopCategoryDict[place] ?? "nil"
    //         
    //         let transaction: Transaction = .init(date: date, note: noteInput)
    //         modelContext.insert(transaction)
    //         
    //         transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
    //         transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
    //         
    //         var shopDescription: FetchDescriptor<Shop> = FetchDescriptor(predicate: #Predicate { $0.name == place && $0.address == "" })
    //         shopDescription.fetchLimit = 1
    //         let shops: [Shop]? = try? modelContext.fetch(shopDescription)
    //         let shop: Shop = shops?.first ?? Shop(name: place, address: "", mapItem: previewMapItem, color: colorInput)
    //         shop.amount += transaction.amount
    //         transaction.shop = shop
    //         shop.transactionsCount = shop.transactions?.count ?? 0
    //         
    //         // transaction.documents = documentsInput
    //         
    //         var categoryDescription: FetchDescriptor<Category> = FetchDescriptor(predicate: #Predicate { $0.name == categoryInput })
    //         categoryDescription.fetchLimit = 1
    //         let categories: [Category]? = try? modelContext.fetch(categoryDescription)
    //         let category: Category = categories?.first ?? Category(name: categoryInput)
    //         category.amount += transaction.amount
    //         transaction.category = category
    //         
    //         transaction.searchTerms = getSearchTerms(from: transaction).joined()
    //         // DispatchQueue.main.async {
    //         self.importCounter += 1
    //         print(importCounter, importMax)
    //         // }
    //     }
    //     importMax = 0
    //     //        })
    // }
    // private func csvImport12() {
    //     let rows: [String] = financesCSV1.components(separatedBy: .newlines)
    //     importMax = Double(rows.count)
    //     importCounter = 0
    //     
    //     //        DispatchQueue.global(qos: .userInitiated).async(execute: {
    //     for row in rows {
    //         
    //         let columns = row.components(separatedBy: ",")
    //         
    //         let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
    //         let place: String = columns[1]
    //         let product: String = columns[2]
    //         let spending: Decimal = ((try? Decimal(Double(columns[3]) ?? 6969696)) ?? 0) * -1
    //         //                let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
    //         let tags: [String] = { columns[4].isEmpty ? [] : columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 }) }()
    //         let receipt: String = columns[5]
    //         let comment: String = columns[6]
    //         let card: String = columns[7]
    //         
    //         //                let tagsString: String = tags.joined(separator: "\n")
    //         let tagsString: String = { tags.isEmpty ? "" : tags.joined(separator: "\n") }()
    //         let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
    //         let colorInput: Color? = shopColorsDict[place]
    //         let categoryInput: String = shopCategoryDict[place] ?? "nil"
    //         
    //         let transaction: Transaction = .init(date: date, note: noteInput)
    //         modelContext.insert(transaction)
    //         
    //         transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
    //         transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
    //         
    //         let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
    //         let shop: Shop = shops?.first(where: { $0.name == place && $0.address == "" }) ?? Shop(name: place, address: "", mapItem: previewMapItem, color: colorInput)
    //         shop.amount += transaction.amount
    //         transaction.shop = shop
    //         shop.transactionsCount = shop.transactions?.count ?? 0
    //         
    //         // transaction.documents = documentsInput
    //         
    //         let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
    //         let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? Category(name: categoryInput)
    //         category.amount += transaction.amount
    //         transaction.category = category
    //         
    //         transaction.searchTerms = getSearchTerms(from: transaction).joined()
    //         // DispatchQueue.main.async {
    //         self.importCounter += 1
    //         print(importCounter, importMax)
    //         // }
    //     }
    //     importMax = 0
    //     //        })
    // }
    // private func csvImport2() {
    //     let rows: [String] = financesCSV2.components(separatedBy: .newlines)
    //     importMax = Double(rows.count)
    //     importCounter = 0
    //     
    //     DispatchQueue.global().sync(execute: {
    //         for row in rows {
    //             importCounter += 1
    //             print(importCounter, importMax)
    //             
    //             let columns = row.components(separatedBy: ",")
    //             
    //             let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
    //             let place: String = columns[1]
    //             let product: String = columns[2]
    //             let spending: Decimal = ((try? Decimal((Double(columns[3]) ?? 696969) / 100.0)) ?? 0) * -1
    //             let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
    //             let receipt: String = columns[5]
    //             let comment: String = columns[6]
    //             let card: String = columns[7]
    //             
    //             let tagsString: String = tags.joined(separator: "\n")
    //             let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
    //             let colorInput: Color? = shopColorsDict[place]
    //             let categoryInput: String = shopCategoryDict[place] ?? "nan"
    //             
    //             let transaction: Transaction = .init(date: date, note: noteInput)
    //             modelContext.insert(transaction)
    //             
    //             transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
    //             transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
    //             
    //             let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
    //             let shop: Shop = shops?.first(where: { $0.name == place && $0.address == "" }) ?? Shop(name: place, address: "", mapItem: previewMapItem, color: colorInput)
    //             shop.amount += transaction.amount
    //             transaction.shop = shop
    //             shop.transactionsCount = shop.transactions?.count ?? 0
    //             
    //             // transaction.documents = documentsInput
    //             
    //             let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
    //             let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? Category(name: categoryInput)
    //             category.amount += transaction.amount
    //             transaction.category = category
    //             
    //             transaction.searchTerms = getSearchTerms(from: transaction).joined()
    //         }
    //         importMax = 0
    //     })
    // }
    // private func getSearchTerms(from transaction: Transaction) -> [String] {
    //     var result: Set<String> = []
    //     
    //     if let shopString = transaction.shop?.name { result.insert(shopString) }
    //     result.insert(Formatter.dateFormatter.string(from: transaction.date))
    //     result.insert(transaction.date.formatted(date: .complete, time: .omitted))
    //     if let amountString: String = Formatter.currencyFormatter.string(from: transaction.amount as NSDecimalNumber) { result.insert(amountString) }
    //     if let categoryString: String = transaction.category?.name { result.insert(categoryString) }
    //     transaction.items?.forEach({
    //         $0.name.split(separator: " ").map(String.init).forEach({ result.insert($0) })
    //         $0.note.split(separator: " ").map(String.init).forEach({ result.insert($0) })
    //         result.insert($0.volume)
    //         if let amountString: String = Formatter.currencyFormatter.string(from: $0.amount as NSDecimalNumber) { result.insert(amountString) }
    //     })
    //     transaction.documents?.forEach({ result.insert($0.url.lastPathComponent) })
    //     transaction.note.split(separator: " ").map(String.init).forEach({ result.insert($0) })
    //     
    //     return result.sorted()
    // }
    
    private func csvImportv3() {
        let rows: [String] = financesCSV2.components(separatedBy: .newlines) + fuckme.components(separatedBy: .newlines) + financesCSV1.components(separatedBy: .newlines)
        
        showImportSheet = true
        importMax = Double(rows.count)
        importCounter = 0
    
        Task {
            for row in rows {
                try? await Task.sleep(for: .milliseconds(1))
                let columns = row.components(separatedBy: ",")
                
                let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
                let shopName: String = columns[1]
                let product: String = columns[2]
                let amount: Decimal = Decimal((Double(columns[3]) ?? 696969) / 100.0) * -1
                let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
                let receipt: String = columns[5]
                let comment: String = columns[6]
                let bankCard: String = columns[7]
                
                let tagsString: String = tags.joined(separator: "\n")
                let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
                let colorInput: Color? = shopColorsDict[shopName]
                let categoryInput: String = shopCategoryDict[shopName] ?? "nil"
                
                let transaction: Transaction = Transaction(date: date, note: noteInput)
                modelContext.insert(transaction)
                
                // MARK: Items
                let itemName: String = product.isEmpty ? shopName : product
                let item: Item = Item(name: itemName, note: "", volume: "", amount: amount, transaction: nil, date: date)
                transaction.items?.append(item)
                
                // MARK: Shop
                do {
                    let shops: [Shop] = try modelContext.fetch(FetchDescriptor<Shop>())
                    let shopMapItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double.random(in: 50..<51)), longitude: CLLocationDegrees(Double.random(in: 9..<9.5)))))
                    let shop: Shop = shops.first(where: { $0.name == shopName }) ?? Shop(name: shopName, address: "", mapItem: shopMapItem, color: shopColorsDict[shopName])
                    transaction.shop = shop
                    shop.transactionsCount = shop.transactions?.count ?? 0
                } catch {
                    print("no shop for \(shopName):", error)
                }
                
                // MARK: Category
                let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
                let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? Category(name: categoryInput)
                category.amount += transaction.amount
                transaction.category = category
                
                transaction.updateTransient()
                
                print(importCounter, importMax)
                importCounter += 1
            }
        }
        showImportSheet = false
    }
    
    private func csvImport4() {
        let b = BackgroundImporter(modelContainer: self.modelContext.container)
        Task {
            try? await b.backgroundInsert()
        }
    }
    private func deleteV4() {
        let b = BackgroundImporter(modelContainer: self.modelContext.container)
        Task {
            try? await b.backgroundDelete()
        }
    }
    
    private func deleteModelContext() {
        var maxCount: Int = 0
        
        let documents: [Document] = (try? modelContext.fetch(FetchDescriptor<Document>())) ?? []
        maxCount = documents.count
        for (index, element) in documents.enumerated() {
            print("d\(index+1)/\(maxCount)")
            element.delete()
        }
        
        let items: [Item] = (try? modelContext.fetch(FetchDescriptor<Item>())) ?? []
        maxCount = items.count
        for (index, element) in items.enumerated() {
            print("i\(index+1)/\(maxCount)")
            element.delete()
        }
        
        let transactions: [Transaction] = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        maxCount = transactions.count
        for (index, element) in transactions.enumerated() {
            print("t\(index+1)/\(maxCount)")
            element.deleteOtherRelationships()
        }
    }
}

#Preview {
    SettingsView()
}

actor BackgroundImporter {
    var modelContainer: ModelContainer
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
    }
    
    func backgroundInsert() async throws {
        let modelContext = ModelContext(modelContainer)
        
        let rows: [String] = financesCSV2.components(separatedBy: .newlines) + fuckme.components(separatedBy: .newlines) + financesCSV1.components(separatedBy: .newlines)
        
        var importCounter: Int = 0
        let importMax: Int = rows.count
        
        for row in rows {
            try await Task.sleep(for: .milliseconds(10))
            let columns = row.components(separatedBy: ",")
            
            let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
            let shopName: String = columns[1]
            let product: String = columns[2]
            let amount: Decimal = Decimal((Double(columns[3]) ?? 696969) / 100.0) * -1
            let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
            let receipt: String = columns[5]
            let comment: String = columns[6]
            let bankCard: String = columns[7]
            
            let tagsString: String = tags.joined(separator: "\n")
            let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
            let colorInput: Color? = shopColorsDict[shopName]
            let categoryInput: String = shopCategoryDict[shopName] ?? "nil"
            
            let transaction: Transaction = Transaction(date: date, note: noteInput)
            modelContext.insert(transaction)
            
            // MARK: Items
            let itemName: String = product.isEmpty ? shopName : product
            let item: Item = Item(name: itemName, note: "", volume: "", amount: amount, transaction: nil, date: date)
            transaction.items?.append(item)
            
            // MARK: Shop
            do {
                let shops: [Shop] = try modelContext.fetch(FetchDescriptor<Shop>())
                let shopMapItem: MKMapItem = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: CLLocationDegrees(Double.random(in: 50..<51)), longitude: CLLocationDegrees(Double.random(in: 9..<9.5)))))
                let shop: Shop = shops.first(where: { $0.name == shopName }) ?? Shop(name: shopName, address: "", mapItem: shopMapItem, color: shopColorsDict[shopName])
                transaction.shop = shop
                shop.transactionsCount = shop.transactions?.count ?? 0
            } catch {
                print("no shop for \(shopName):", error)
            }
            
            // MARK: Category
            let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
            let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? Category(name: categoryInput)
            category.amount += transaction.amount
            transaction.category = category
            
            transaction.updateTransient()
            
            importCounter += 1
            print(importCounter, importMax)
            
            if (importCounter % 500) == 0 {
                try modelContext.save()
            }
        }
        
        try modelContext.save()
    }
    
    func backgroundDelete() async throws {
        let modelContext = ModelContext(modelContainer)
        
        var maxCount: Int = 0
        var counter: Int = 0
        
        let documents: [Document] = (try? modelContext.fetch(FetchDescriptor<Document>())) ?? []
        maxCount = documents.count
        counter = 0
        for element in documents {
            try await Task.sleep(for: .milliseconds(10))
            counter += 1
            print("d\(counter)/\(maxCount)")
            element.delete()
        }
        
        try modelContext.save()
        
        let items: [Item] = (try? modelContext.fetch(FetchDescriptor<Item>())) ?? []
        maxCount = items.count
        counter = 0
        for element in items {
            try await Task.sleep(for: .milliseconds(10))
            counter += 1
            print("i\(counter)/\(maxCount)")
            element.delete()
        }
        
        try modelContext.save()
        
        let transactions: [Transaction] = (try? modelContext.fetch(FetchDescriptor<Transaction>())) ?? []
        maxCount = transactions.count
        counter = 0
        for element in transactions {
            try await Task.sleep(for: .milliseconds(10))
            counter += 1
            print("t\(counter)/\(maxCount)")
            element.deleteOtherRelationships()
        }
        
        try modelContext.save()
    }
}
