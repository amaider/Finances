// 14.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import UniformTypeIdentifiers
import QuickLookThumbnailing

struct DocumentRowView: View {
    let url: URL
    @State private var thumbnail: CGImage? = nil
    
    var body: some View {
        HStack(content: {
            if let thumbnail: CGImage = thumbnail {
                Image(thumbnail, scale: 1.0, label: Text("url.lastPathComponent"))
            } else {
                Image(systemName: fileTypeImage(for: url))
                    // .onAppear(perform: generateThumbnail)
            }
            
            VStack(alignment: .leading, content: {
                Text(url.lastPathComponent)
                Text("fileSize kB")
                    .font(.subheadline)
            })
            
        })
    }
    
    private func fileTypeImage(for url: URL) -> String {
        let typeIdentifier = UTType(filenameExtension: url.pathExtension)?.preferredMIMEType ?? ""
        
        switch typeIdentifier {
            case "public.image":
                return "photo"
            case "public.text":
                return "doc.text"
            case "public.pdf":
                return "doc.text"
            case "com.apple.iwork.pages.pages":
                return "doc.text"
            default:
                return "questionmark"
        }
    }
    
    private func generateThumbnail() {
        let size: CGSize = CGSize(width: 100, height: 100)
        let scale: CGFloat = UIScreen.main.scale
        let request: QLThumbnailGenerator.Request = QLThumbnailGenerator.Request(fileAt: url, size: size, scale: scale, representationTypes: .lowQualityThumbnail)
        request.iconMode = true
        let generator = QLThumbnailGenerator.shared
        
        generator.generateRepresentations(for: request) { (thumbnail, type, error) in
            DispatchQueue.main.async {
                if thumbnail == nil || error != nil {
                    print("fuck")
                    // assert(false, "Thumbnail failed to generate")
                } else {
                    DispatchQueue.main.async {
                        self.thumbnail = thumbnail!.cgImage
                    }
                }
            }
        }
    }
}

#Preview {
    DocumentRowView(url: URL(fileURLWithPath: ""))
}
