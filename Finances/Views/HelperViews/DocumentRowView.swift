// 14.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import QuickLook

struct DocumentRowView: View {
    let url: URL
    
    @State private var quickLookURL: URL?
    @State private var thumbnail: CGImage? = nil
    @State private var showQuickLook: Bool = false
    
    var body: some View {
        HStack(content: {
            if let thumbnail: CGImage = thumbnail {
                Image(thumbnail, scale: 1.0, label: Text(url.lastPathComponent))
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "doc.fill")
                    .resizable()
                    .scaledToFit()
            }
            
           VStack(alignment: .leading, content: {
               Text(url.lastPathComponent)
               Text("\((try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize) ?? 0) kB")
                  .font(.footnote)
           })
            
        })
        // .frame(height: 100)
        .onAppear(perform: generateThumbnail)
        .onTapGesture(perform: {
            if quickLookURL != nil { quickLookURL = nil }
            else { quickLookURL = url }
        })
        .quickLookPreview($quickLookURL)
    }
    
    func generateThumbnail() {
        let size: CGSize = CGSize(width: 200, height: 200)
        let scale: CGFloat = 1.0
        
        let request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .all)
        
        QLThumbnailGenerator.shared.generateRepresentations(for: request,update: { (thumbnail, type, error) in
            DispatchQueue.main.async(execute: {
                if thumbnail == nil || error != nil {
                    NSLog("Error creating thumbnail \(error?.localizedDescription ?? "")")
                } else {
                    self.thumbnail = thumbnail?.cgImage
                }
            })
        })
    }
}

#Preview {
    DocumentRowView(url: URL(fileURLWithPath: ""))
}
