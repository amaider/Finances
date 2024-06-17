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
    @Environment(\.modelContext) var modelContext
    
    @State var currDate: Date = .iso8601(year: 2023, month: 8)
    @State var showDatePickerPopover: Bool = false
    @State var showTransactionNewSheet: Bool = false
    @State var showSumCategorySheet: Bool = false
    
    @State var dateSpan: Calendar.Component = .year
    @State var searchTerm: String = ""
    
    /// SortDescriptor with sortOrder in .tag() is not selectable
    @State var sortDescriptorPicker = SortDescriptor(\Transaction.shop?.name)
    @State var sortOrder: SortOrder = .forward
    var sortDescriptors: [SortDescriptor<Transaction>] {
        var sortDescriptor = sortDescriptorPicker
        sortDescriptor.order = sortOrder
        return [sortDescriptor, SortDescriptor(\.shop?.name)]
    }
    
    var transactions: [Transaction] {
        let startDate: Date = currDate.startOf(dateSpan)
        let endDate: Date = currDate.endOf(dateSpan)
        let predicate: Predicate<Transaction> = #Predicate {
            if searchTerm.isEmpty {
                return $0.date >= startDate && $0.date <= endDate
            } else {
                return $0.searchTerms.localizedStandardContains(searchTerm)
            }
        }
        
        var sort: SortDescriptor = sortDescriptorPicker
        sort.order = sortOrder
        let sortBy: [SortDescriptor<Transaction>] = [sort, SortDescriptor(\.shop?.name)]
        
        let transactionDescription: FetchDescriptor<Transaction> = FetchDescriptor<Transaction>(predicate: predicate, sortBy: sortBy)
        let transactions: [Transaction]? = try? modelContext.fetch(transactionDescription)
        return transactions ?? []
    }
    var sumAmount: Decimal { transactions.reduce(0, { $0 + $1.amount })}
    
    var body: some View {
        List(content: {
            if transactions.isEmpty {
                ContentUnavailableView("No Transactions", systemImage: "doc.richtext")
                    .listRowSeparator(.hidden)
            } else {
                ForEach(transactions, content: { transaction in
                    NavigationLink(destination: {
                        TransactionDetailView(transaction: transaction)
                    }, label: {
                        TransactionRowViewSmall(transaction: transaction, isSelected: false)
                    })
                    .buttonStyle(.plain)
                })
                .listRowSeparator(.hidden)
            }
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
                    Picker("Sort", selection: $sortDescriptorPicker, content: {
                        Text("Date").tag(SortDescriptor<Transaction>(\Transaction.date))
                        Text("Shop").tag(SortDescriptor<Transaction>(\Transaction.shop?.name))
                        Text("Amount").tag(SortDescriptor<Transaction>(\Transaction.amount))
                    })
                    Picker("Order", selection: $sortOrder, content: {
                        Text("Forward").tag(SortOrder.forward)
                        Text("Reverse").tag(SortOrder.reverse)
                    })
                    Picker("Date Span", selection: $dateSpan, content: {
                        Text("Month").tag(Calendar.Component.month)
                        Text("Year").tag(Calendar.Component.year)
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
                Button("New Transaction", systemImage: "plus", action: { showTransactionNewSheet.toggle() })
            })
            
            ToolbarItem(placement: .bottomBar, content: {
                HStack(alignment: .lastTextBaseline, content: {
                    Text("Total")
                    Spacer()
                    Text(sumAmount, format: .currency(code: "EUR"))
                        .foregroundColor(sumAmount > 0 ? .green : .red)
                })
                .font(.title2)
                .bold()
                .onTapGesture(perform: { showSumCategorySheet.toggle() })
            })
        })
        .sheet(isPresented: $showSumCategorySheet, content: {
            CategorySheet(transactions: transactions)
                .padding(.horizontal)
                .presentationDetents([.medium])
                .presentationBackgroundInteraction(.enabled)
        })
    }
}

// #Preview {
//     NavigationStack(root: {
//         TransactionsView()
//             .modelContainer(previewContainer)
//     })
// }
