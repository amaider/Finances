// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.


// todo context menu with reciept as preview and buttons(edit, duplicate, delete)
// instead of dismissParent from subview add .onChange(... .isDeletec(), {dimsiss()}) to parentview
import SwiftUI
import SwiftData

struct FirstView: View {
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var shops: [Shop]
    @Query var categories: [Category]
    
    enum Sorting: String, CaseIterable, Identifiable {
        case date = "Date"
        case shop = "Shop"
        case amount = "Amount"
        case category = "Category"
        
        var id: Self { self }
    }
    @AppStorage("sorting") var sorting: Sorting = .category
    @State var sortDescriptor: SortDescriptor = SortDescriptor(\Transaction.date)
    @State var sortKeyPath: KeyPath = \Transaction.date.description
    
    @State var sortKeyPathHelper: Int = 0
    @State var sortOrder: SortOrder = .forward
    
    @State var currDate: Date = .iso8601(year: 2023, month: 8)
    
    @State var collapseHelper: Set<String> = ["Food"]
    @State var searchTerm: String = ""
    
    // var categoryList: [Category] {
    //     let categoryDict = transactions.reduce(into: [String: [Transaction]](), { result, transaction in
    //         result[transaction.category!.name, default: []].append(transaction)
    //     })
    //     
    //     return categoryDict.reduce(into: [Category](), { result, entry in
    //         result.append(Category(name: entry.key, transactions: entry.value))
    //     })
    // }
    // var categorySet: Set<Category> {
    //     let categoryDict = transactions.reduce(into: [String: [Transaction]](), { result, transaction in
    //         result[transaction.category!.name, default: []].append(transaction)
    //     })
    //     
    //     return categoryDict.reduce(into: Set<Category>(), { result, entry in
    //         result.insert(Category(name: entry.key, transactions: entry.value))
    //     })
    // }
    
    
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
            FirstSecondView(date: currDate, sort: [SortDescriptor(sortKeyPath, order: sortOrder)], searchTerm: searchTerm)
                .searchable(text: $searchTerm)
                .toolbar(content: {
                    ToolbarItemGroup(placement: .topBarLeading, content: {
                        // Button("Search", systemImage: "magnifyingglass", action: {})
                        
                        // Menu("Sort", systemImage: "line.3.horizontal.decrease.circle", content: {
                        //     Picker("Sort", selection: $sorting, content: {
                        //         ForEach(Sorting.allCases, content: { sort in
                        //             Text(sort.rawValue)
                        //         })
                        //
                        //     })
                        // })
                        Menu("Sort", systemImage: "line.3.horizontal.decrease.circle", content: {
                             Picker("Sort", selection: $sortDescriptor, content: {
                                 Text("Shop").tag(SortDescriptor(\Transaction.shop?.name, order: sortOrder))
                                 Text("Date").tag(SortDescriptor(\Transaction.date, order: sortOrder))
                                 Text("Amount").tag(SortDescriptor(\Transaction.amount, order: sortOrder))
                             })
                            // .pickerStyle(.inline)
//                             Picker("Sort", selection: $sortKeyPathHelper, content: {
//                                 Text("Category").tag(0)
//                                 Text("Shop").tag(1)
//                                 Text("Date").tag(2)
//                                 Text("Amount").tag(3)
//                             })
                            
                            Divider()
                            
                            Picker("Order", selection: $sortOrder, content: {
                                Text("Forward").tag(SortOrder.forward)
                                Text("Reverse").tag(SortOrder.reverse)
                            })
                            .onChange(of: sortOrder, {
                                switch 0 {
                                    case 1: sortDescriptor = SortDescriptor(\Transaction.shop?.name, order: sortOrder)
                                    case 2: sortDescriptor = SortDescriptor(\Transaction.date, order: sortOrder)
                                    case 3: sortDescriptor = SortDescriptor(\Transaction.amount, order: sortOrder)
                                    default: break
                                }
                            })
                        })
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .onTapGesture(perform: {
                                print("new \(type(of: sortKeyPath))")
                            })
                        .contextMenu {
                            Menu("This is a menu") {
                                Button {} label: {
                                    Text("Do something")
                                }
                            }
                            
                            Button {
                            } label: {
                                Text("Something")
                            }
                            
                            Divider()
                            
                            Picker("Order", selection: $sortOrder, content: {
                                Text("Forward").tag(SortOrder.forward)
                                Text("Reverse").tag(SortOrder.reverse)
                            }).pickerStyle(.segmented)
                        } preview: {
                            Text("recieptview here") // you can add anything that conforms to View here
                        }
                    })
                    ToolbarItem(placement: .principal, content: {
                        DatePicker("DatePicker", selection: $currDate, displayedComponents: .date)
                            .labelsHidden()
                    })
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button("new a", systemImage: "minus", action: addFromCSV)
                    })
                    ToolbarItem(placement: .topBarTrailing, content: {
                        Button("new Transaction", systemImage: "plus", action: {})
                    })
                })
        })
    }
    
    private func collapseSectionAction(_ section: String) {
        if collapseHelper.remove(section) == nil {
            collapseHelper.insert(section)
        }
    }
    
    private func addFromCSV() {
        transactions.forEach({ Transaction.deleteOtherRelationships($0) })
        
        let rows = financesCSV.components(separatedBy: "\n")
        print("rows: \(rows.count)")
        
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
        }
    }
}

#Preview {
    NavigationStack(root: {
        FirstView()
            .modelContainer(previewContainer)
    })
}
