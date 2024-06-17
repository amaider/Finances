// 17.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

// todo: maybe move faceid to app file?
// todo: .isEmpty ?? false/true -> .isEmpty == false
import SwiftUI
import SwiftData
import LocalAuthentication

struct SideBarView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isNotAuthenticated = false
    @State private var faceIDDescription: String = ""
    
    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    @Query var shops: [Shop]
    @Query var documents: [Document]
    @Query var items: [Item]
    @Query var categories: [Category]
    
    
    var body: some View {
        List(content: {
            Section(content: {
                NavigationLink(destination: { TransactionsView() }, label: { Label("Transactions", systemImage: "cart") })
                NavigationLink(destination: { Text("todo") },       label: { Label("Recently deleted", systemImage: "trash") })
            })
            
            Section(content: {
                NavigationLink(destination: { ShopsView() },        label: { Label("Shops", systemImage: "house") })
                NavigationLink(destination: { ItemsView() },        label: { Label("Items", systemImage: "archivebox") })
                NavigationLink(destination: { DocumentsView() },    label: { Label("Documents", systemImage: "paperclip") })
                NavigationLink(destination: { CategoriesView() },   label: { Label("Categories", systemImage: "tag") })
            })
            
            Section(content: {
                NavigationLink(destination: { SettingsView() },     label: { Label("Settings", systemImage: "gear") })
            }, footer: {
               Text("t: \(transactions.count), s: \(shops.count), c: \(categories.count), d: \(documents.count), i: \(items.count)")
            })
        })
        .navigationTitle("Lists")
        .onChange(of: scenePhase, {
            switch $1 {
                case .active: authenticate()
                case .background: isNotAuthenticated = true
                default: break
            }
        })
        .fullScreenCover(isPresented: $isNotAuthenticated, content: {
            ContentUnavailableView("Use FaceID to unlock your data", systemImage: "lock.fill", description: Text(faceIDDescription))
                .onTapGesture(perform: authenticate)
        })
    }
    
    private func authenticate() {
        // dont request faceid if already unlocked or application is not active
        if !isNotAuthenticated || scenePhase != .active { return }
        
        let context = LAContext()
        var error: NSError?
        
        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "We need to unlock your data."
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason, reply: { success, error in
                isNotAuthenticated = !success
                if error != nil { faceIDDescription = "\(error?.localizedDescription ?? "FaceID Unknown Error")\nTap to retry FaceID"}
            })
        } else {
            NSLog("Authentication Error: \(error?.localizedDescription ?? "")")
        }
    }
}
