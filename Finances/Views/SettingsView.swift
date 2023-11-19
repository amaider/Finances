// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct SettingsView: View {
    @AppStorage("currency") var currency: String = "EUR"
    @AppStorage("backupSetting") var backupSetting: Int = 0
    @AppStorage("lastBackup") var lastBackup: String = ""
    
    @State private var showFileImporter: Bool = false
    @State private var showFileExporter: Bool = false
    
    let items: [String] = ["3","666","999"]
    
    var body: some View {
        Form(content: {
            Picker("Currency", selection: $currency, content: {
                Text("EUR").tag("EUR")
                Text("DLR").tag("Dlr")
            })
            
            Section(content: {
                Picker("Backup Interval", selection: $backupSetting, content: {
                    Text("Never/Aus").tag(0)
                    Text("Daily").tag(1)
                    Text("Weekly").tag(2)
                    Text("Monthly").tag(3)
                })
                
                Button("Export JSON", action: { showFileExporter.toggle() })
                Button("Import JSON", action: { showFileImporter.toggle() })
            }, header: {
                Text("Backup")
            }, footer: {
                Text("Last Backup: \(Formatter.dateFormatter.date(from: lastBackup)?.formatted(date: .abbreviated, time: .omitted) ?? "-")")
            })
        })
        .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.json], onCompletion: fileImporterCompletion)
        .fileExporter(isPresented: $showFileExporter, items: items, contentTypes: [.text], onCompletion: { result in
            switch result {
                case .success(let urls):
                    print(urls)
                case .failure(let error):
                    NSLog("Error exporting: \(error.localizedDescription)")
            }
        })
    }
    
    // MARK: Functions
    private func fileImporterCompletion(_ result: Result<URL, any Error>) {
        switch result {
            case .success(let url):
                if let data = try? Data(contentsOf: url) {
//                    if let jsonDecoded = try? JSONDecoder().decode([Transaction], from: data) {
//                        
//                    }
                }
            case .failure(let error):
                print("Error fileImporter: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SettingsView()
}
