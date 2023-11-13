// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

@main
struct FinancesApp: App {
    var body: some Scene {
        WindowGroup {
             FirstView()
                .monospaced()
        }
        .modelContainer(for: Transaction.self)
//        .modelContainer(for: Transaction.self, inMemory: false, isAutosaveEnabled: true, isUndoEnabled: true)
    }
}
