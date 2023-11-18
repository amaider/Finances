// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

@main
struct FinancesApp: App {
    @State var navPath: NavigationPath = .init()
    @State var troll: Bool = true
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navPath, root: {
                SideBarView()
                    .navigationDestination(isPresented: $troll, destination: {
                        TransactionsView()
                    })
            })
             // NavigationSplitView(sidebar: {
             // }, content: {
             //     TransactionsView()
             // }, detail: {
             //     Text("Detail")
             // })
                .monospaced()
        }
        .modelContainer(for: [Transaction.self, Document.self, Item.self])
//        .modelContainer(for: Transaction.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
    }
}

enum ViewPane {
    
}
