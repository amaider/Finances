// 14.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct TransactionNewSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query(sort: \Category.name) var categories: [Category]
    
    var transaction: Transaction?
    
    // MARK: Inputs
    @State var shopInput: String = ""
    @State var locationInput: String = ""
    @State var dateInput: Date
    @State var itemsInput: [Item]
    @State var documentsInput: [Document]
    @State var categoryInput: Category
    @State var noteInput: String = ""
    
    @FocusState private var currFocus: FocusableFields?
    @State private var filePickerIsPresented: Bool = false
    
    init(transaction: Transaction?) {
        self.transaction = transaction
        _shopInput = State(initialValue: transaction?.shop?.name ?? "")
        _locationInput = State(initialValue: transaction?.shop?.location ?? "")
        _dateInput = State(initialValue: transaction?.date ?? .now)
        _itemsInput = State(initialValue: transaction?.items ?? [])
        _documentsInput = State(initialValue: transaction?.documents ?? [])
        _categoryInput = State(initialValue: (transaction?.category ?? Category(name: "other", amount: Decimal(0))))
        _noteInput = State(initialValue: transaction?.note ?? "")
    }
    
    var body: some View {
        Form(content: {
            Section(content: {
                TextField("Shop", text: $shopInput).focused($currFocus, equals: .shopName)
                TextField("Location", text: $locationInput).focused($currFocus, equals: .shopLocation)
            })
            
            DatePicker("Date", selection: $dateInput, displayedComponents: .date).focusable().focused($currFocus, equals: .date)
            
            Section(content: {
                List(content: {
                    ForEach(itemsInput, content: { item in
                        NavigationLink(destination: {
                            ItemEditView(item: item, itemsInput: $itemsInput)
                        }, label: {
                            ItemRowView(item: item)
                        })
                    })
                    .onDelete(perform: deleteItem)
                })
                NavigationLink("Add Item", destination: {
                    ItemEditView(item: nil, itemsInput: $itemsInput)
                })
                .focused($currFocus, equals: .itemAdd)
            }, header: {
                HStack(content: {
                    Text("Items")
                    Text(itemsInput.reduce(Decimal(0), { $0 + $1.amount }), format: .currency(code: "EUR"))
                })
            })
            
            Section("Documents", content: {
                ForEach(documentsInput, content: { document in
                    DocumentRowView(url: document.url)
                })
                HStack(spacing: 5, content: {
                    Image(systemName: "plus.circle")
                    Text("Anhang hinzufügen...")
                        .opacity(0.5)
                })
                .clipShape(Rectangle())
                .onTapGesture(perform: { filePickerIsPresented.toggle() })
                .fileImporter(isPresented: $filePickerIsPresented, allowedContentTypes: [.content], onCompletion: fileImporterCompletion)
//                .focused($currFocus, equals: .documentAdd)
            })
            
            Section(content: {
                Picker("Category", selection: $categoryInput, content: {
                    ForEach(categories, content: { category in
                        Text(category.name).tag(category)
                    })
                })
                .focused($currFocus, equals: .categoryPicker)
                .onAppear(perform: {
                    guard let category: Category = categories.first(where: { $0.name == transaction?.category?.name }) ?? categories.first else { return }
                    categoryInput = category
                })
                TextField("Notes", text: $noteInput, prompt: Text("Notes"), axis: .vertical)
                    .frame(height: 100)
                    .background(.red.opacity(0.3))
                    .focused($currFocus, equals: .notes)
            })
            
            Section(content: {
                Button("Delete", role: .destructive, action: deleteTransaction)
                    .frame(maxWidth: .infinity)
            })
        })
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                Button("Cancel", action: { dismiss() })
                    .focusedButton($currFocus, equals: .cancel)
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button("Save", action: saveTransaction)
                    .disabled(shopInput.isEmpty)
                    .focusedButton($currFocus, equals: .enter)
            })
        })
        .onAppear(perform: {
            if shopInput.isEmpty { currFocus = .shopName }
        })
        .onSubmit({
            print(" oldFocus: \(currFocus)")
            switch currFocus {
                default: currFocus?.next()
            }
        })
        .onChange(of: currFocus, { print("currFocus: \($0) -> \($1)") })
        .navigationTitle(transaction == nil ? "Transaction" : "Edit")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
    
    // MARK: Functions
    private func fileImporterCompletion(_ result: Result<URL, any Error>) {
        switch result {
            case .success(let url):
                let newDocument: Document = Document(url: url, size: 0)
                documentsInput.append(newDocument)
            case .failure(let error):
                print("Error fileImporter: \(error.localizedDescription)")
        }
    }
    
    private func deleteItem(at offsets: IndexSet) {
        itemsInput.remove(atOffsets: offsets)
    }
    
    private func deleteTransaction() {
        transaction?.deleteOtherRelationships()
        dismiss()
    }
    
    
    // todo: check for existing transaction like shop/category so you can combine both ifs into one branch/thing
    private func saveTransaction() {
        if transaction == nil {
            let transaction: Transaction = .init(date: dateInput, note: noteInput)
            modelContext.insert(transaction)
            
            itemsInput.forEach({ transaction.items?.append(Item(name: $0.name, note: $0.note, volume: $0.volume, amount: $0.amount, transaction: nil, date: dateInput))})
            transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
            
            let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
            let shop: Shop = shops?.first(where: { $0.name == shopInput && $0.location == locationInput }) ?? Shop(name: shopInput, location: locationInput, color: nil, transactionsCount: 0, amount: Decimal(0))
            shop.transactionsCount = shop.transactions?.count ?? 0
            shop.amount += transaction.amount
            transaction.shop = shop
            
            transaction.documents = documentsInput
            
            let category: Category = categories.first(where: { $0 == categoryInput }) ?? categories.first(where: { $0.name == "nil" }) ?? Category(name: "nil", amount: Decimal(0))
            category.amount += transaction.amount
            transaction.category = category
            
            transaction.searchTerms = getSearchTerms(from: transaction).joined()
        } else {
            transaction?.date = dateInput
            transaction?.note = noteInput
            
            if transaction?.items != itemsInput {
                print("different items maybe delete old items?")
//                transaction?.items?.forEach({ $0.delete() })    // delete old items
                
                itemsInput.forEach({ transaction?.items?.append(Item(name: $0.name, note: $0.note, volume: $0.volume, amount: $0.amount, transaction: nil, date: dateInput)) })
                transaction?.amount = transaction?.items?.reduce(0, { $0 + $1.amount }) ?? Decimal(0)
            }
            
            if transaction?.shop?.name != shopInput || transaction?.shop?.location != locationInput {
                print("different shop")
                // transaction?.shop?.delete()
                
                let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
                let shop: Shop = shops?.first(where: { $0.name == shopInput && $0.location == locationInput }) ?? Shop(name: shopInput, location: locationInput, color: nil, transactionsCount: 0, amount: Decimal(0))
                shop.amount += transaction!.amount
                transaction?.shop = shop
                shop.transactionsCount = shop.transactions?.count ?? 0
            }
            
//            transaction?.documents?.forEach({ $0.delete() })
            transaction?.documents = documentsInput
            
            if transaction?.category != categoryInput {
                print("diff category")
                // transaction?.category?.delete()
                
                let category: Category = categories.first(where: { $0 == categoryInput }) ?? categories.first(where: { $0.name == "nil" }) ?? Category(name: "nil", amount: Decimal(0))
                category.amount += transaction!.amount
                transaction?.category = category
            }
            
            transaction?.searchTerms = getSearchTerms(from: transaction!).joined()
        }
        
        
        dismiss()
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
    
    // MARK: FocusFields
    enum FocusableFields: Hashable, CaseIterable {
        case shopName, shopLocation, date, itemAdd, documentAdd, categoryPicker, notes, enter, cancel
        
        mutating func next() {
            let allCases = type(of: self).allCases
            self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
        }
    }
}
             

#Preview {
    TransactionNewSheet(transaction: nil)
}
