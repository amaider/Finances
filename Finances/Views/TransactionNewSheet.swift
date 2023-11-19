// 14.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers
import SwiftData

struct TransactionNewSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @Query var categories: [Category]
    
    var transaction: Transaction?
    
    // MARK: Inputs
    @State var shopInput: String = ""
    @State var locationInput: String = ""
    @State var dateInput: Date
    @State var itemsInput: [Item]
    @State var documentsInput: [Document]
    @State var categoryInput: Category
    @State var noteInput: String = ""
    
    var amountInput: Decimal { itemsInput.reduce(Decimal(0), { $0 + $1.amount }) }
    
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
                TextField("Shop", text: $shopInput)
                TextField("Location", text: $locationInput)
            })
            
            DatePicker("Date", selection: $dateInput, displayedComponents: .date)
            
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
            }, header: {
                HStack(content: {
                    Text("Items")
                    Text(amountInput, format: .currency(code: "EUR"))
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
            })
            
            Section(content: {
                Picker("Category", selection: $categoryInput, content: {
                    ForEach(categories, content: { category in
                        Text(category.name).tag(category)
                    })
                })
                .onAppear(perform: {
                    guard let category: Category = categories.first(where: { $0.name == "none" }) ?? categories.first else { return }
                    categoryInput = category
                })
                TextField("Notes", text: $noteInput, prompt: Text("Notes"), axis: .vertical)
                    .frame(height: 100)
                    .background(.red.opacity(0.3))
            })
            
            Section(content: {
                Button("Delete", role: .destructive, action: deleteTransaction)
                    .frame(maxWidth: .infinity)
            })
        })
        .toolbar(content: {
            ToolbarItem(placement: .topBarLeading, content: {
                Button("Dancel", action: { dismiss() })
            })
            ToolbarItem(placement: .topBarTrailing, content: {
                Button("Save", action: saveTransaction)
                    .disabled(shopInput.isEmpty)
            })
        })
        .navigationTitle(transaction == nil ? "Transaction" : "Edit")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
    
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
    
    private func saveTransaction() {
        if transaction == nil {
            let transaction: Transaction = .init(shop: nil, date: dateInput, amount: Decimal(0), items: [], documents: [], category: nil, note: noteInput, searchTerms: [])
            modelContext.insert(transaction)
            
            itemsInput.forEach({ transaction.items?.append(Item(name: $0.name, note: $0.note, volume: $0.volume, amount: $0.amount, transaction: nil, date: dateInput))})
            transaction.amount = transaction.items?.reduce(0, { $0 + $1.amount }) ?? 0
            
            let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
            let shop: Shop = shops?.first(where: { $0.name == shopInput}) ?? Shop(name: shopInput, location: locationInput, amount: Decimal(0))
            shop.amount += transaction.amount
            transaction.shop = shop
            
            transaction.documents = documentsInput
            
            let category: Category = categories.first(where: { $0 == categoryInput }) ?? Category(name: "nil", amount: Decimal(0))
            category.amount += transaction.amount
            transaction.category = category
            
            transaction.searchTerms = getSearchTerms(from: transaction)
        } else {
            transaction?.date = dateInput
            transaction?.note = noteInput
            
            if transaction?.items != itemsInput {
                print("different items maybe delete old items?")
//                transaction?.items?.forEach({ $0.delete() })    // delete old items
                
                itemsInput.forEach({ transaction?.items?.append(Item(name: $0.name, note: $0.note, volume: $0.volume, amount: $0.amount, transaction: nil, date: dateInput)) })
                transaction?.amount = transaction?.items?.reduce(0, { $0 + $1.amount }) ?? Decimal(0)
            }
            
            if transaction?.shop?.name != shopInput {
                print("different shop")
                // transaction?.shop?.delete()
                
                let shops: [Shop]? = try? modelContext.fetch(FetchDescriptor<Shop>())
                let shop: Shop = shops?.first(where: { $0.name == shopInput && $0.location == locationInput }) ?? Shop(name: shopInput, location: locationInput, amount: Decimal(0))
                shop.amount += transaction!.amount
                transaction?.shop = shop
            }
            
//            transaction?.documents?.forEach({ $0.delete() })
            transaction?.documents = documentsInput
            
            if transaction?.category != categoryInput {
                print("diff category")
                // transaction?.category?.delete()
                
                let category: Category = categories.first(where: { $0 == categoryInput }) ?? Category(name: "nil", amount: Decimal(0))
                category.amount += transaction!.amount
                transaction?.category = category
            }
            
            transaction?.searchTerms = getSearchTerms(from: transaction!)
        }
        
        
        dismiss()
    }
    
    private func getSearchTerms(from transaction: Transaction) -> [String] {
        var result: Set<String> = []
        
        if let shopString = transaction.shop?.name { result.insert(shopString) }
        result.insert(Formatter.dateFormatter.string(from: transaction.date))
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
    TransactionNewSheet(transaction: nil)
}
