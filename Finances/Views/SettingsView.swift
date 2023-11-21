// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData

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
    
    let items: [String] = ["3","666","999"]
    
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

                Button("Import JSON \(showFileImporterJSON ? "on" : "off")", action: { showFileImporterJSON.toggle() })
                Button("Import CSV1", action: csvImport1)
                    .sheet(isPresented: .constant(importMax != 0), content: {
                        ProgressView(value: (importCounter / importMax), label: {
                            Text("Importing from CSV")
                        }, currentValueLabel: {
                            Text("Importing \(importCounter + 1)/\(importMax)")
                        })
                    })
                Button("Import CSV2", action: csvImport2)
                Button("Export JSON \(showFileExporter ? "on" : "off")", action: { showFileExporter.toggle() })
            }, header: {
                Text("Backup")
            }, footer: {
                Text("Last Backup: \(Formatter.dateFormatter.date(from: lastBackup)?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
            })
            // .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json], onCompletion: fileImporterCompletion)
            .fileImporter(isPresented: $showFileImporterJSON, allowedContentTypes: [.commaSeparatedText], onCompletion: fileImporterCompletion)
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
        switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url) {
                    if let content: String = String(data: data, encoding: .utf8) {
                        let lines: [String] = content.components(separatedBy: .newlines)
                        for line in lines {
                            let cells = line.components(separatedBy: ",")
                            
                            let date: Date = Formatter.dateFormatter.date(from: cells[0]) ?? .iso8601(year: 1000, month: 1)
                            let place: String = cells[1]
                            let product: String = cells[2]
                            let spending: Decimal = (try? Decimal(cells[3], format: .number)) ?? 0
                            let tags: [String] = cells[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
                            let receipt: String = cells[5]
                            let comment: String = cells[6]
                            let card: String = cells[7]
                            
                            let tagsString: String = tags.joined(separator: "\n")
                            let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
                            let colorInput: Color? = shopColorsDict[place]
                            let categoryInput: String = shopCategoryDict[place] ?? "other"

                            let transaction: Transaction = .init(date: date, note: noteInput)
                            modelContext.insert(transaction)
                            
                            transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
                            transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
                            
                            let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
                            let shop: Shop = shops?.first(where: { $0.name == place && $0.location == "" }) ?? Shop(name: place, location: "", color: colorInput, transactionsCount: 0, amount: Decimal(0))
                            shop.amount += transaction.amount
                            transaction.shop = shop
                            shop.transactionsCount = shop.transactions?.count ?? 0
                            
                            // transaction.documents = documentsInput
                            
                            let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
                            let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? categories?.first(where: { $0.name == "nil" }) ?? Category(name: "nil", amount: Decimal(0))
                            category.amount += transaction.amount
                            transaction.category = category
                            
                            transaction.searchTerms = getSearchTerms(from: transaction).joined()
                        }
                    }
                    
                }
            case .failure(let error):
                print("Error fileImporter: \(error.localizedDescription)")
        }
    }
    
    private func csvImport1() {
        let rows: [String] = financesCSV1.components(separatedBy: .newlines)
        importMax = Double(rows.count)
        importCounter = 0
        
        DispatchQueue.main.async(execute: {
            for row in rows {
                importCounter += 1
                print(importCounter, importMax)
                
                let columns = row.components(separatedBy: ",")
                
                let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
                let place: String = columns[1]
                let product: String = columns[2]
                let spending: Decimal = ((try? Decimal(Double(columns[3]) ?? 6969696)) ?? 0) * -1
                let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
                let receipt: String = columns[5]
                let comment: String = columns[6]
                let card: String = columns[7]
                
                let tagsString: String = tags.joined(separator: "\n")
                let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
                let colorInput: Color? = shopColorsDict[place]
                let categoryInput: String = shopCategoryDict[place] ?? "other"
                
                let transaction: Transaction = .init(date: date, note: noteInput)
                modelContext.insert(transaction)
                
                transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
                transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
                
                let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
                let shop: Shop = shops?.first(where: { $0.name == place && $0.location == "" }) ?? Shop(name: place, location: "", color: colorInput, transactionsCount: 0, amount: Decimal(0))
                shop.amount += transaction.amount
                transaction.shop = shop
                shop.transactionsCount = shop.transactions?.count ?? 0
                
                // transaction.documents = documentsInput
                
                let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
                let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? categories?.first(where: { $0.name == "nil" }) ?? Category(name: "nil", amount: Decimal(0))
                category.amount += transaction.amount
                transaction.category = category
                
                transaction.searchTerms = getSearchTerms(from: transaction).joined()
            }
            importMax = 0
        })
    }
    private func csvImport2() {
        let rows: [String] = financesCSV2.components(separatedBy: .newlines)
        importMax = Double(rows.count)
        importCounter = 0
        
        DispatchQueue.main.async(execute: {
            for row in rows {
                importCounter += 1
                print(importCounter, importMax)
                
                let columns = row.components(separatedBy: ",")
                
                let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .iso8601(year: 1000, month: 1)
                let place: String = columns[1]
                let product: String = columns[2]
                let spending: Decimal = ((try? Decimal((Double(columns[3]) ?? 696969) / 100.0)) ?? 0) * -1
                let tags: [String] = columns[4].components(separatedBy: .whitespaces).map({ "#" + $0 })
                let receipt: String = columns[5]
                let comment: String = columns[6]
                let card: String = columns[7]
                
                let tagsString: String = tags.joined(separator: "\n")
                let noteInput: String = [tagsString, receipt, comment].joined(separator: "\n")
                let colorInput: Color? = shopColorsDict[place]
                let categoryInput: String = shopCategoryDict[place] ?? "other"
                
                let transaction: Transaction = .init(date: date, note: noteInput)
                modelContext.insert(transaction)
                
                transaction.items?.append(Item(name: product.isEmpty ? place : product, note: "", volume: "", amount: spending, date: date))
                transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
                
                let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
                let shop: Shop = shops?.first(where: { $0.name == place && $0.location == "" }) ?? Shop(name: place, location: "", color: colorInput, transactionsCount: 0, amount: Decimal(0))
                shop.amount += transaction.amount
                transaction.shop = shop
                shop.transactionsCount = shop.transactions?.count ?? 0
                
                // transaction.documents = documentsInput
                
                let categories: [Category]? = try? modelContext.fetch(FetchDescriptor<Category>())
                let category: Category = categories?.first(where: { $0.name == categoryInput }) ?? categories?.first(where: { $0.name == "nil" }) ?? Category(name: "nil", amount: Decimal(0))
                category.amount += transaction.amount
                transaction.category = category
                
                transaction.searchTerms = getSearchTerms(from: transaction).joined()
            }
            importMax = 0
        })
    }
    private func getSearchTerms(from transaction: Transaction) -> [String] {
        var result: Set<String> = []
        
        if let shopString = transaction.shop?.name { result.insert(shopString) }
        result.insert(Formatter.dateFormatter.string(from: transaction.date))
        result.insert(transaction.date.formatted(date: .complete, time: .omitted))
        if let amountString: String = Formatter.currencyFormatter.string(from: transaction.amount as NSDecimalNumber) { result.insert(amountString) }
        if let categoryString: String = transaction.category?.name { result.insert(categoryString) }
        transaction.items?.forEach({
            $0.name.split(separator: " ").map(String.init).forEach({ result.insert($0) })
            $0.note.split(separator: " ").map(String.init).forEach({ result.insert($0) })
            result.insert($0.volume)
            if let amountString: String = Formatter.currencyFormatter.string(from: $0.amount as NSDecimalNumber) { result.insert(amountString) }
        })
        transaction.documents?.forEach({ result.insert($0.url.lastPathComponent) })
        transaction.note.split(separator: " ").map(String.init).forEach({ result.insert($0) })
        
        return result.sorted()
    }
}

#Preview {
    SettingsView()
}
