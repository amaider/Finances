// 2024-06-16, Swift 5.0, macOS 14.4, Xcode 15.2
// Copyright © 2024 amaider. All rights reserved.

import SwiftUI

struct TransactionToolbar: ViewModifier {
    @State private var showSumReceiptSheet: Bool = false
    let transactions: [Transaction]
    var sumAmount: Decimal {
        transactions.reduce(0, { $0 + $1.amount })
    }
    
    func body(content: Content) -> some View {
        content
            .toolbar(content: {
                ToolbarItemGroup(placement: .bottomBar, content: {
                    HStack(alignment: .lastTextBaseline, content: {
                        Text("Total")
                        Spacer()
                        Text(sumAmount, format: .currency(code: "EUR"))
                            .foregroundColor(sumAmount > 0 ? .green : .red)
                    })
                    .font(.title2)
                    .bold()
                    .onTapGesture(perform: { showSumReceiptSheet.toggle() })
                })
            })
            .sheet(isPresented: $showSumReceiptSheet, content: {
                CategorySheet(transactions: transactions)
                    .padding(.horizontal)
                    .presentationDetents([.medium])
                    .presentationBackgroundInteraction(.enabled)
            })
    }
}

extension View {
    func transactionToolbar(transactions: [Transaction], sumAmount: Decimal) -> some View {
        self.modifier(TransactionToolbar(transactions: []))
    }
}
