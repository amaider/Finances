// 17.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

// todo: maybe move faceid to app file?
import SwiftUI
import SwiftData
import LocalAuthentication

struct SideBarView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isNotAuthenticated = false
    @State private var faceIDDescription: String = ""
    
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var shops: [Shop]
    @Query var categories: [Category]
    @Query var documents: [Document]
    @Query var items: [Item]
    
    
    var body: some View {
        List(content: {
            Section(content: {
                NavigationLink(destination: {
                    TransactionsView()
                }, label: {
                    Label("Transactions", systemImage: "cart")
                })
                NavigationLink(destination: {
                    Text("recently deleted")
                }, label: {
                    Label("Recently deleted", systemImage: "trash")
                })
            })
            
            Section(content: {
                NavigationLink(destination: {
                    ShopsView()
                }, label: {
                    Label("Shops", systemImage: "house")
                })
                NavigationLink(destination: {
                    Text("Categories")
                }, label: {
                    Label("Categories", systemImage: "tag")
                })
                NavigationLink(destination: {
                    Text("items")
                }, label: {
                    Label("Items", systemImage: "archivebox")
                })
                NavigationLink(destination: {
                    Text("Documents")
                }, label: {
                    Label("Documents", systemImage: "paperclip")
                })
            })
            
            Section(content: {
                NavigationLink(destination: {
                    Text("Backup")
                }, label: {
                    Label("Backup", systemImage: "externaldrive.badge.timemachine")
                })
                NavigationLink(destination: {
                    Text("Settings")
                }, label: {
                    Label("Settings", systemImage: "gear")
                })
            }, footer: {
               Text("t: \(transactions.count), s: \(shops.count), c: \(categories.count), d: \(documents.count), i: \(items.count)")
            })
            
            Button("Add transactions", systemImage: "minus", action: addFromCSV)
        })
        .navigationTitle("Lists")
        .onChange(of: scenePhase, {
            switch $1 {
                case .active: authenticate()
                case .background: isNotAuthenticated = true
                default: break
            }
        })
        .fullScreenCover(isPresented: $isNotAuthenticated, content: {
            ContentUnavailableView("Use FaceID to unlock your data", systemImage: "lock.fill", description: Text(faceIDDescription))
                .onTapGesture(perform: authenticate)
        })
    }
    
    private func authenticate() {
        // dont request faceid if already unlocked or application is not active
        if !isNotAuthenticated || scenePhase != .active { return }
        
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { success, error in
                isNotAuthenticated = !success
                if error != nil { faceIDDescription = "\(error?.localizedDescription ?? "FaceID Unknown Error")\nTap to retry FaceID"}
            })
        } else {
            NSLog("Authentication Error: \(error?.localizedDescription ?? "")")
        }
    }
    
    private func addFromCSV() {
        do {
            let transactions: [Transaction] = try modelContext.fetch(FetchDescriptor<Transaction>())
            transactions.forEach({ Transaction.deleteOtherRelationships($0) })
        } catch {
            print("asdfgqre")
        }
        
        let rows = financesCSV.components(separatedBy: "\n")
        
        let maxRows = rows.count
        var counter = 0
        
        for row in rows {
            do {
                print("row \(counter)/\(maxRows)")
                counter += 1
                let shops: [Shop] = try modelContext.fetch(FetchDescriptor<Shop>())
                let categories: [Category] = try modelContext.fetch(FetchDescriptor<Category>())
                
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
                
                let color: Color? = shopColorsDict[columns[1]]
                let colorData: ColorData? = color != nil ? .init(color!) : nil
                
                let shopInput: String = columns[1]
                let shop: Shop = shops.first(where: { $0.name == shopInput}) ?? Shop(name: shopInput, colorData: colorData)
                if !shops.contains(shop) {
                    modelContext.insert(shop)
                }
                
                let categoryInput: String = shopCategoryDict[columns[1]] ?? "other"
                let category: Category = categories.first(where: { $0.name == categoryInput }) ?? Category(name: categoryInput)
                if !categories.contains(category) {
                    modelContext.insert(category)
                }
                
                let date: Date = Formatter.dateFormatter.date(from: columns[0]) ?? .now
                let amount: Int = Int((Double(columns[3]) ?? 0) * 100) * -1
                let note: String = [columns[4], columns[6]].joined(separator: "\n")
                
                let transaction: Transaction = .init(shop: shop, date: date, amount: amount, category: category, note: note == "\n" ? nil : note)
                category.transactions.append(transaction)
                shop.transactions.append(transaction)
            } catch {
                fatalError("nodsjfasdj")
            }
        }
    }
}
