// 18.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers

// struct JSONDocument: FileDocument {
//     static var readableContentTypes: [UTType] = [.json]
//     
//     var data: [Transaction]
//     
//     init(data: [Transaction]) {
//         self.data = data
//     }
//     
//     init(configuration: ReadConfiguration) throws {
//         guard let data = try? JSONDecoder().decode([Transaction].self, from: configuration.file.regularFileContents!) else {
//             throw CocoaError(.fileReadCorruptFile)
//         }
//         
//         self.data = data
//     }
//     
//     func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
//         let jsonData = try JSONEncoder().encode(data)
//         
//         return FileWrapper(regularFileWithContents: jsonData)
//     }
// }
