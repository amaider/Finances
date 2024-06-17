// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

@main
struct FinancesApp: App {
    @State var navPath: NavigationPath = .init()
    @State var firstView: Bool = true
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $navPath, root: {
                SideBarView()
                    .navigationDestination(isPresented: $firstView, destination: {
                        TransactionsView()
//                         ShopsView()
                        // SettingsView()
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
        .modelContainer(for: Transaction.self)
//        .modelContainer(for: Transaction.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
    }
}

func testThis(name: String, function: () -> Void) {
    let startTime = DispatchTime.now()
    function()
    let endTime = DispatchTime.now()
    let elapsedTime = endTime.uptimeNanoseconds - startTime.uptimeNanoseconds
    let elapsedTimeInSeconds = Double(elapsedTime) / 1_000_000_000
    print("\(name): \(elapsedTimeInSeconds) sec".replacingOccurrences(of: ".", with: ","))
}
