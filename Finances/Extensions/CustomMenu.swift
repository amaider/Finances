// 16.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct CustomMenu<Content: View>: View {
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .frame(width: 234)
        .background(
            Color(UIColor.systemBackground)
                .opacity(0.8)
                .blur(radius: 50)
        )
        .cornerRadius(14)
    }
}

struct CustomMenuButtonStyle: ButtonStyle {
    let symbol: String
    let color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.label
            Spacer()
            Image(systemName: symbol)
        }
        .padding(.horizontal, 16)
        .foregroundColor(color)
        .background(configuration.isPressed ? Color(UIColor.secondarySystemBackground) : Color.clear)
        .frame(height: 44)
    }
}

