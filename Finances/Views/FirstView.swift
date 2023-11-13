// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.


// in searchfield, groupbox for ever persistentmodel with the first five result showing and tap on groupbox to show all search result for specific selected persistentmodel
// or add filter lol

// instead of dismissParent from subview add .onChange(... .isDeletec(), {dimsiss()}) to parentview
import SwiftUI
import SwiftData

struct FirstView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var shops: [Shop]
    @Query var categories: [Category]
    
    @State var currDate: Date = .iso8601(year: 2023, month: 8)
    @State var searchTerm: String = ""
    
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
//             ScrollView(content: {
//             switch sorting {
//                 case .category:
//                    ForEach(categoryList, content: { category in
//                        Button(action: { collapseSectionAction(category.name) }, label: {
//                            HStack(content: {
//                                Text(category.name)
//                                Spacer()
//                                Text(Double(category.transactions.reduce(0, { $0 + $1.amount })) / 100.0, format: .currency(code: "EUR"))
//                                Image(systemName: collapseHelper.contains(category.name) ? "chevron.down" : "chevron.left")
//                                    .frame(width: 20, height: 20)
//                                    .foregroundColor(.gray)
//                            })
//                            .font(.title3)
//                            .contentShape(Rectangle())
//                        })
//                        .buttonStyle(.plain)
// 
//                        if collapseHelper.contains(category.name) {
//                            ForEach(category.transactions.sorted(by: { $0.date < $1.date }), id: \.self, content: { transaction in
//                                TransactionRowViewSmall(transaction: transaction, isSelected: false)
//                                    .contentShape(Rectangle())
//                            })
// //                           .onDelete(perform: { self.deleteTransaction(at: $0, category: category) })
//                            .padding(.leading, 8)
//                            .padding(.trailing, 20)
//                            
//                        }
//                    })
//                 default:
//                     ForEach(transactions, content: { transaction in
//                         NavigationLink(destination: {
//                             
//                         }, label: {
//                             TransactionRowViewSmall(transaction: transaction, isSelected: false)
//                                 .contentShape(Rectangle())
//                                 .fixedSize(horizontal: false, vertical: true)
//                         })
//                     })
// //                    .onDelete(perform: { self.deleteTransaction(at: $0) })
//                     .padding(.leading, 8)
//                     .padding(.trailing, 20)
//                     
//             }
//             })
//             .searchable(text: $searchTerm)
//             .padding()
//             .listStyle(.plain)
//            List(transactions, rowContent: {
//                Text($0.shop?.name ?? "noname")
//            })
                FirstSecondView(date: currDate, sort: [sortDescriptor, SortDescriptor(\.shop?.name)], searchTerm: searchTerm)
                    .searchable(text: $searchTerm)
                    .toolbar(content: {
                        ToolbarItemGroup(placement: .topBarLeading, content: {
                            Menu("Sort", systemImage: "line.3.horizontal.decrease.circle", content: {
                                Picker("Sort", selection: $sortKeyPathHelper, content: {
                                    Text("Date").tag(0)
                                    Text("Shop").tag(1)
                                    Text("Amount").tag(2)
                                })
                                Picker("Order", selection: $sortOrder, content: {
                                    Text("Forward").tag(true)
                                    Text("Reverse").tag(false)
                                })
                            })
                            Text("t: \(transactions.count), s: \(shops.count), c: \(categories.count)")
                        })
                        ToolbarItem(placement: .principal, content: {
                            DatePicker("DatePicker", selection: $currDate, displayedComponents: .date)
                                .labelsHidden()
                        })
//                        ToolbarItem(placement: .topBarTrailing, content: {
//                            Button("new a", systemImage: "minus", action: addFromCSV)
//                        })
                        ToolbarItem(placement: .topBarTrailing, content: {
                            Button("new Transaction", systemImage: "plus", action: {
                            })
                        })
                    })
        })
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
