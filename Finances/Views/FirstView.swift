// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

// move faceid to app file and add go "into background"/"unfocus app" check

// in searchfield, groupbox for ever persistentmodel with the first five result showing and tap on groupbox to show all search result for specific selected persistentmodel
// or add filter lol

// instead of dismissParent from subview add .onChange(... .isDeletec(), {dimsiss()}) to parentview
// move deleted Transactions to Deleted "Folder"
import SwiftUI
import SwiftData
import LocalAuthentication

struct FirstView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var shops: [Shop]
    @Query var categories: [Category]
    
    @Environment(\.scenePhase) var scenePhase
    @State private var isNotAuthenticated = false
    @State private var faceIDDescription: String = ""
    
    @State var currDate: Date = .iso8601(year: 2023, month: 8)
    @State var searchTerm: String = ""
    
    @State var showMonthReceiptSheet: Bool = false
    var monthAmount: Int { transactions.reduce(0, { $0 + $1.amount })}
    @State var monthPresentationDetent: PresentationDetent = .height(50)
    
    
    @AppStorage("sortKeyPathHelper") var sortKeyPathHelper: Int = 0
    @AppStorage("sortOrder") var sortOrder: Bool = true
    var sortDescriptor: SortDescriptor<Transaction> {
        let sortOrder: SortOrder = sortOrder ? .forward : .reverse
        switch sortKeyPathHelper {
            case 1: return SortDescriptor(\Transaction.shop?.name, order: sortOrder)
            case 2: return SortDescriptor(\Transaction.amount, order: sortOrder)
            default: return SortDescriptor(\Transaction.date, order: sortOrder)
        }
    }
    
    var body: some View {
        NavigationStack(root: {
            FirstSecondView(date: currDate, sort: [sortDescriptor, SortDescriptor(\.shop?.name)], searchTerm: searchTerm)
                .searchable(text: $searchTerm)
                .toolbar(content: {
                    // ToolbarItemGroup(placement: .topBarLeading, content: {
                    //     Menu("Sort", systemImage: "line.3.horizontal.decrease.circle", content: {
                    //         Picker("Sort", selection: $sortKeyPathHelper, content: {
                    //             Text("Date").tag(0)
                    //             Text("Shop").tag(1)
                    //             Text("Amount").tag(2)
                    //         })
                    //         Picker("Order", selection: $sortOrder, content: {
                    //             Text("Forward").tag(true)
                    //             Text("Reverse").tag(false)
                    //         })
                    //     })
                    //     Menu("Info", systemImage: "info.circle", content: {
                    //         Text("t: \(transactions.count), s: \(shops.count), c: \(categories.count)")
                    //     })
                    // })
                    ToolbarItem(placement: .principal, content: {
                        DatePicker("DatePicker", selection: $currDate, displayedComponents: .date)
                            .labelsHidden()
                    })
                    ToolbarItem(placement: .topBarLeading, content: {
//                        Menu(currDate.formatted(.dateTime.year().month()), content: {
//                            Text("nice")
//                        })
                        Text(currDate.formatted(.dateTime.year().month()))
                            .padding(3)
                            .background(.gray)
                            .onTapGesture {
                                showMonthReceiptSheet.toggle()
                            }
                            .overlay(content: {
                                if showMonthReceiptSheet {
                                    Group(content: {
                                        Rectangle()
                                            .foregroundColor(Color.black.opacity(0.5))
                                            .edgesIgnoringSafeArea(.all)
                                            .overlay(
                                                GeometryReader { geometry in
                                                    RoundedRectangle(cornerRadius: 16)
                                                        .foregroundColor(.white)
                                                        .frame(width: 100, height: 100)
                                                        .overlay(Text("nice"))
                                                }
                                            )                                    })
                                }
                            })
                            // .popover(isPresented: $showMonthReceiptSheet, content: {
                            //     Text("nice")
                            //         .presentationCompactAdaptation(.popover)
                            // })
                    })
                    //                        ToolbarItem(placement: .topBarTrailing, content: {
                    //                            Button("new a", systemImage: "minus", action: addFromCSV)
                    //                        })
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button("new Transaction", systemImage: "plus", action: {
                        })
                    })
                    
                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack(alignment: .lastTextBaseline, content: {
                            Text("Total")
                            Spacer()
                            Text(Double(monthAmount) / 100.0, format: .currency(code: "EUR"))
                                .foregroundColor(monthAmount > 0 ? .green : .red)
                        })
                        .buttonStyle(.plain)
                        .font(.title2)
                        .bold()
                    }
                })
            
        })
//         .sheet(isPresented: .constant(true), content: {
//             // let shop: Shop = Shop(name: currDate.formatted(.dateTime.year().month()))
//             // let trans: Transaction = Transaction(shop: nil, date: .now, amount: 0, category: nil)
//             VStack(content: {
//                 Divider()
//                 Divider()
//                 
//                 HStack(alignment: .lastTextBaseline, content: {
//                     Text("Total")
//                     Spacer()
//                     Text(Double(monthAmount) / 100.0, format: .currency(code: "EUR"))
//                         .foregroundColor(monthAmount > 0 ? .green : .red)
//                 })
//                 .font(.title2)
//                 .bold()
//             })
//             .padding(.horizontal)
//             .onTapGesture(perform: { monthPresentationDetent = .medium })
//             .presentationDetents([.height(50), .medium], selection: $monthPresentationDetent)
//             .presentationBackgroundInteraction(.enabled)
// //                .ignoresSafeArea()
//         })
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

#Preview {
    NavigationStack(root: {
        FirstView()
            .modelContainer(previewContainer)
    })
}
