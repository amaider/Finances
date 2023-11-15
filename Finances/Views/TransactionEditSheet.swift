// 11.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
// import MobileCoreServices

struct TransactionEditSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @Query var documents: [Document]
    
    let transaction: Transaction
    
    // MARK: Inputs
    @State var shopInput: String
    @State var locationInput: String
    @State var dateInput: Date
    @State var amountInput: Int
    @State var categoryInput: String
    @State var itemsInput: [Item]
    @State var documentsInput: [Document]
    @State var noteInput: String
    
    @State private var thumbnail: CGImage? = nil
    @State private var selectedDocumentURL: URL?
    @State private var filePickerPresent: Bool = false
    @FocusState private var currFocus: FocusableFields?
    
    var categorySuggestions: [String] {
        do {
            let categories: [Category] = try modelContext.fetch(
                FetchDescriptor<Category>(
                    predicate: #Predicate { $0.name.localizedStandardContains(categoryInput) && $0.name != categoryInput },
                    sortBy: [SortDescriptor<Category>(\.name)]
                )
            )
            return categories.map({ $0.name })
        } catch {
            return []
        }
    }
    var showCategorySuggestions: Bool {
        !categorySuggestions.isEmpty || !categoryInput.isEmpty
    }

//    init(transaction: Transaction, dimissParentClosure: @escaping () -> Void) {
    init(transaction: Transaction) {
        self.transaction = transaction
//        self.dismissParentClosure = dimissParentClosure
        _shopInput = State(initialValue: transaction.shop?.name ?? "")
        _locationInput = State(initialValue: transaction.shop?.location ?? "")
        _dateInput = State(initialValue: transaction.date)
        _amountInput = State(initialValue: transaction.amount)
        _itemsInput = State(initialValue: [])
        _documentsInput = State(initialValue: [])
        _categoryInput = State(initialValue: transaction.category?.name ?? "")
        _noteInput = State(initialValue: transaction.note ?? "")
    }
    
    var body: some View {
        NavigationView(content: {
            Form(content: {
                Section(content: {
                    TextField("Shop", text: $shopInput)
                    TextField("Location", text: $locationInput)
                })
                
                DatePicker("Date", selection: $dateInput, displayedComponents: .date)
                
                Section("Items", content: {
                    
                })
                TextField("Amount", value: $amountInput, format: .number)
                    .labelStyle(.titleAndIcon)
                #if os(iOS)
                    .keyboardType(.numberPad)
                #endif
                
                
                
                Section(content: {
                    ForEach(documentsInput, content: { document in
                        // DocumentRowView(url: document.url)
                    })
                    HStack(spacing: 5, content: {
                        Image(systemName: "plus.circle")
                        Text("Anhang hinzufügen...")
                            .opacity(0.5)
                    })
                    .clipShape(Rectangle())
                    .onTapGesture(perform: { filePickerPresent.toggle() })
                    .fileImporter(isPresented: $filePickerPresent, allowedContentTypes: [.content], onCompletion: fileImporterCompletion)
                })
                
                Section(content: {
                    LabeledContent(content: {
                        Image(systemName: "tag")
                    }, label: {
                         TextField("Category", text: $categoryInput)
                         //     .popover(isPresented: $showCategorySuggestions, content: {
                         //         VStack(content: {
                         //             ForEach(categorySuggestions, id: \.self, content: { categoryName in
                         //                 Button(categoryName, action: { categoryInput = categoryName })
                         //             })
                         //         })
                         //         .presentationCompactAdaptation((.popover))
                         //    })
                            // .textFieldStyle(.custom)
                    })
                    TextField("Notes", text: $noteInput, prompt: Text("Notes"), axis: .vertical)
                        .frame(height: 100)
                        .background(.red.opacity(0.3))
                })
                
                Section(content: {
                    Button("delete", role: .destructive, action: deleteTransaction)
                        .frame(maxWidth: .infinity)
                })
            })
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading, content: {
                    Button("cancel", action: { dismiss() })
                })
                ToolbarItem(placement: .topBarTrailing, content: {
                    Button("save", action: updateTransaction)
                        .disabled(shopInput.isEmpty || categoryInput.isEmpty)
                })
            })
            .navigationTitle("Edit")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
        })
    }
    
    private func updateTransaction() {
        let shop: Shop = Shop(name: shopInput, location: locationInput.isEmpty ? nil : locationInput)
        let category: Category = Category(name: categoryInput)
        
        let newTransaction: Transaction = .init(shop: shop, date: dateInput, amount: amountInput, category: category)
        transaction.update(with: newTransaction)
    }
    
    private func deleteTransaction() {
        transaction.deleteOtherRelationships()
    }
    
    private func fileImporterCompletion(_ result: Result<URL, any Error>) {
        switch result {
            case .success(let url):
                selectedDocumentURL = url
                let newDocument: Document = Document(url: url)
                documentsInput.append(newDocument)
            case .failure(let error):
                print("Error fileImporter: \(error.localizedDescription)")
        }
    }
}

extension TransactionEditSheet {
    // MARK: FocusFields
    enum FocusableFields: Hashable, CaseIterable {
        case shop, price, itemName, itemReceiptID, itemVolume, itemPrice, itemEnter, itemCancel, tag, enter, cancel
        case date
        
        mutating func next() {
            let allCases = type(of: self).allCases
            self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
        }
    }
}

#Preview {
    TransactionEditSheet(transaction: Transaction.example())
}
