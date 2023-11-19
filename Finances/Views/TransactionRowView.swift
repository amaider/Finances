// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction
    var body: some View {
        HStack(alignment: .lastTextBaseline, content: {
            Text(transaction.shop!.name)
            
            Text(transaction.date, format: .dateTime.day().month().year())
                .opacity(0.6)
                .font(.pDate)
            
            Spacer()
            
            Group(content: {
//                 if transaction.items != nil {
//                     Image(systemName: "list.bullet")
//                 }
                // if transaction.documents != nil {
                //     Image(systemName: "paperclip")
                // }
            })
            .font(.pDate)
            
            Text(transaction.amount, format: .currency(code: "EUR"))
                .foregroundColor(transaction.amount > 0 ? .green : .red)
                .shadow(radius: 10)
        })
        // .foregroundColor(transaction.shop?.color ?? .red)
        .lineLimit(1)
        .font(.pTitle)
        .cardView(transaction.shop!.color.opacity(0.2))
    }
}

struct TransactionRowViewSmall: View {
    let transaction: Transaction
    let isSelected: Bool
    
    var transactionColor: Color { transaction.shop?.color ?? .primary }
    var color1: Color { transactionColor.opacity(isSelected ? 1.0 : 0.2) }
    var color2: Color { isSelected ? transactionColor.isDark ? .white : .black : transactionColor }
    
    var body: some View {
        HStack(alignment: .center, spacing: 3, content: {
            transactionColor
                .frame(width: 3)
            
            Text(transaction.date.formatted(.dateTime.day(.twoDigits)))
                .bold()
                .font(.footnote)
            
//            Color.gray.frame(width: 1)
           Divider()
           //     .font(.caption2)
            
            Text(transaction.shop?.name ?? "no Shop")
                .foregroundColor(color2)
            
            Spacer()
            
            Group(content: {
                if !(transaction.items?.isEmpty ?? false) {
                    Image(systemName: "list.bullet")
                }
                if !(transaction.documents?.isEmpty ?? false) {
                    Image(systemName: "paperclip")
                }
                if !transaction.note.isEmpty {
                    Image(systemName: "note.text")
                }
            })
            .font(.caption)
            
            Text(transaction.amount, format: .currency(code: "EUR"))
                .foregroundColor(transaction.amount > 0 ? .green : .red)
            
            Color.clear // todo replace with emptyview ??
                .frame(width: 3)
        })
        .background(color1)
         // .cardViewH(color1, padding: 5)
        .clipShape(RoundedRectangle(cornerRadius: 4.5, style: .continuous))
        // .font(.title2)
        .lineLimit(1)
//        .cardView(transaction.shop!.color.opacity(0.2))
        // .contentShape(Rectangle())
        .contextMenu(menuItems: {
            NavigationLink(destination: {
                NavigationView(content: {
                    TransactionNewSheet(transaction: transaction)                    
                })
            }, label: { Label("Edit", systemImage: "square.and.pencil")})
            Button("Duplicate", systemImage: "doc.on.doc.fill", action: { transaction.duplicate() })
            Button("Delete", systemImage: "trash", role: .destructive, action: { transaction.deleteOtherRelationships() })
        }, preview: {
            ReceiptView(transaction: transaction)
        })
    }
}

#Preview {
    ModelPreview(content: { transaction in
        VStack(content: {
            TransactionRowView(transaction: transaction)
            TransactionRowViewSmall(transaction: transaction, isSelected: false)
            TransactionRowViewSmall(transaction: transaction, isSelected: true)
        })
        .fixedSize()
    })
}
