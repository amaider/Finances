// 12.11.23, Swift 5.0, macOS 14.0, Xcode 12.4
// Copyright © __YEAR__ amaider. All rights reserved.

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
