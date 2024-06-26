// 14.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct ReceiptView: View {
    let transaction: Transaction
    
    var body: some View {
        GroupBox(content: {
            VStack(spacing: 3, content: {
                Text(transaction.shop?.name ?? "nil")
                    .font(.title)
                    .bold()
                
                if let address: String = transaction.shop?.address {
                    Text(address)
                        .font(.subheadline)
                }
                
                Text(transaction.date.formatted(.dateTime.year().month().day()))
                    .foregroundStyle(.gray)
                
                // one empty line of space
                Text("")
                
                // MARK: Items
                if transaction.items?.isEmpty ?? true {
                    HStack(content: {
                        Text("No Items")
                            .opacity(0.5)
                        Spacer()
                    })
                } else {
                    Grid(content: {
                        ForEach(transaction.items!, content: { item in
                            GridRow(content: {
                                Text(item.name).gridColumnAlignment(.leading)
                                Text(item.note).opacity(0.6).gridColumnAlignment(.leading)
                                Spacer()
                                Text(item.volume).opacity(0.6).gridColumnAlignment(.trailing)
                                Text(item.amount, format: .currency(code: "EUR")).gridColumnAlignment(.trailing)
                            })
                        })
                    })
                    .font(.pSectionBody)
                }
                
                Divider()
                Divider()
                
                HStack(alignment: .lastTextBaseline, content: {
                    Text("Total")
                    Spacer()
                    Text(transaction.amount, format: .currency(code: "EUR"))
                })
                .lineLimit(1)
                .font(.title2)
                .bold()
            })
        })
//        .monospaced()
    }
}

#Preview {
    ReceiptView(transaction: Transaction.example())
}
