// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import Foundation
import SwiftUI
import SwiftData

struct ItemRowView: View {
    let item: Item
    
    var body: some View {
        HStack(content: {
            Text(item.name)
            Text(item.note)
            Spacer()
            Text(item.volume)
            Text(item.amount, format: .currency(code: "EUR"))
        })
    }
}

struct  ItemEditView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext
    @Query var items: [Item]
    
    let item: Item?
    @Binding var itemsInput: [Item]
    
    // MARK: Inputs
    @State var nameInput: String
    @State var volumeInput: String
    @State var amountInput: Decimal
    @State var noteInput: String
    
    @FocusState private var currFocus: FocusableFields?
    
    init(item: Item?, itemsInput: Binding<[Item]>) {
        self.item = item
        _itemsInput = itemsInput
        _nameInput = State(initialValue: item?.name ?? "")
        _volumeInput = State(initialValue: item?.volume ?? "")
        _amountInput = State(initialValue: item?.amount ?? Decimal(0.0))
        _noteInput = State(initialValue: item?.note ?? "")
    }
    
    var body: some View {
        Form(content: {
            Section(content: {
                TextField("Name", text: $nameInput)
                    .focused($currFocus, equals: .name)
                
                TextField("Note", text: $noteInput)
                    .focused($currFocus, equals: .note)
                    .onChange(of: noteInput, {
                        if $1.count > 10 { noteInput = String($0.prefix(10)) }
                    })
                
                TextField("Volume", text: $volumeInput, prompt: Text("1x, 100g, 1L"))
                    .focused($currFocus, equals: .volume)
                
                TextField("Amount", value: $amountInput, format: .currency(code: "EUR"))
                    .focused($currFocus, equals: .amount)
                    .keyboardType(.decimalPad)
            })
            
            Section("Items", content: {
                if let itemsSearch: [Item] = try? items.filter(#Predicate {
                    return (
                        (nameInput.isEmpty ? true : $0.name.localizedStandardContains(nameInput))
                        && (noteInput.isEmpty ? true : $0.note.localizedStandardContains(noteInput))
                        && (volumeInput.isEmpty ? true : $0.volume.localizedStandardContains(volumeInput))
                        && (amountInput != 0.0 ? true : $0.amount == amountInput)
                    )
                }), !itemsSearch.isEmpty {
                    ForEach(itemsSearch, content: { item in
                        ItemRowView(item: item)
                            .clipShape(Rectangle())
                            .onTapGesture(perform: {
                                nameInput = item.name
                                volumeInput = item.volume
                                amountInput = item.amount
                                noteInput = item.note
                            })
                    })
                } else {
                    Text("No matching items found")
                        .foregroundStyle(.gray)
                }
            })
        })
        .toolbar(content: {
            Button(item == nil ? "Add" : "Save", action: addItem)
                .focusedButton($currFocus, equals: .enter)
                .disabled(nameInput.isEmpty)
        })
        .onAppear(perform: {
            currFocus = nameInput.isEmpty ? .name : nil
        })
        .onSubmit({
            switch currFocus {
                // case .amount:   addItem()
                case .enter:    addItem()
                default:        currFocus?.next()
            }
        })
    }
    
    private func addItem() {
        if item == nil {
            let item: Item = .init(name: nameInput, note: noteInput, volume: volumeInput, amount: amountInput, transaction: nil, date: nil)
            itemsInput.append(item)
//            modelContext.insert(item)
        } else {
            item?.name = nameInput
            item?.note = noteInput
            item?.volume = volumeInput
            item?.amount = amountInput
        }
        dismiss()
    }
    
    // MARK: FocusFields
    enum FocusableFields: Hashable, CaseIterable {
        case name, note, volume, amount, enter, cancel
        
        mutating func next() {
            let allCases = type(of: self).allCases
            self = allCases[(allCases.firstIndex(of: self)! + 1) % allCases.count]
            print("next: \(String(describing: self))")
        }
    }
}

#Preview {
    ItemEditView(item: nil, itemsInput: .constant([]))
}
