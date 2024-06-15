// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

// add appstorage("lastBackup") and do auto export swiftdata to json like whatsapp?
// https://www.hackingwithswift.com/quick-start/swiftdata/how-to-get-natural-string-sorting-for-swiftdata-queries

// in searchfield, groupbox for ever persistentmodel with the first five result showing and tap on groupbox to show all search result for specific selected persistentmodel
// or add filter lol

// instead of dismissParent from subview add .onChange(... .isDeletec(), {dimsiss()}) to parentview
// move deleted Transactions to Deleted "Folder"

// Double -> Int https://stackoverflow.com/questions/28421176/which-swift-datatype-do-i-use-for-currency

// !!! move transient variables assignment inside @Model and use .update() to update the variables. probably wont work with date (maybe .update(with date: Date))


import SwiftUI
import SwiftData

struct TransactionsView: View {
    @State var currDate: Date = .iso8601(year: 2023, month: 11)
    @State var showDatePickerPopover: Bool = false
    @State var showTransactionNewSheet: Bool = false
    
    @AppStorage("tSortKey") var sortKeyPathHelper: Int = 0
    @AppStorage("sortOrder") var sortOrder: Bool = true
    var sortDescriptor: SortDescriptor<Transaction> {
        let sortOrder: SortOrder = sortOrder ? .forward : .reverse
        switch sortKeyPathHelper {
            case 1: return SortDescriptor(\Transaction.shop?.name, order: sortOrder)
            case 2: return SortDescriptor(\Transaction.amount, order: sortOrder)
            default: return SortDescriptor(\Transaction.date, order: sortOrder)
        }
    }
    @State var searchTerm: String = ""
    
    var body: some View {
        List(content: {
            TransactionForEachView(date: currDate, sort: [sortDescriptor, SortDescriptor(\.shop?.name)], searchTerm: searchTerm)
        })
        .listStyle(.plain)
        // TransactionsListView(date: currDate, sort: [sortDescriptor, SortDescriptor(\.shop?.name)], searchTerm: searchTerm)
            .searchable(text: $searchTerm)
            .sheet(isPresented: $showTransactionNewSheet, content: {
                NavigationView(content: {
                    TransactionNewSheet(transaction: nil)                    
                })
            })
            .toolbar(content: {
                ToolbarItemGroup(placement: .topBarTrailing, content: {
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
                })
                ToolbarItemGroup(placement: .principal, content: {
                    Button(action: { showDatePickerPopover.toggle() }, label: {
                        Text(currDate.formatted(.dateTime.year().month()))
                    })
                    .buttonStyle(.bordered)
                    .foregroundStyle(showDatePickerPopover ? Color.accentColor : Color.primary)
                    .popover(isPresented: $showDatePickerPopover, content: {
                        DatePickerPopover(currDate: $currDate)
                            .frame(minWidth: 300)
                            .padding(.horizontal)
                    })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button("new Transaction", systemImage: "plus", action: { showTransactionNewSheet.toggle() })
                })
                
                // ToolbarItem(placement: .bottomBar, content: {
                //     HStack(alignment: .lastTextBaseline, content: {
                //         Text("Total")
                //         Spacer()
                //         Text(12, format: .currency(code: "EUR"))
                //             .foregroundColor(12 > 0 ? .green : .red)
                //     })
                //     .font(.title2)
                //     .bold()
                //     .onTapGesture(perform: {  })
                // })
            })
    }
}

// #Preview {
//     NavigationStack(root: {
//         TransactionsView()
//             .modelContainer(previewContainer)
//     })
// }
