// 16.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

extension Font {
    // static let : Font = .system(size: 10.0)
    
    /// search bar
    static let searchBar: Font = .title
    /// dateselection icon fonts
    static let dateSelectionDate: Font = .footnote
    static let dateSelectionPrice: Font = .title3
    
    static let cardTitle: Font = .title2
    static let cardSubtitle: Font = .body
    
    
    /// card title and date
    static let swipeButtons: Font = .body
    static let pTitle: Font = .title2
    static let pDate: Font = .subheadline
    static let pSectionTitle: Font = .body.italic()
    static let pSectionBody: Font = .subheadline
    
    /// graph fonts
    static let graphAnnotation: Font = .footnote
    
    static let font1: Font = Font.custom("Helvetica", size: 12, relativeTo: TextStyle.footnote)
    
    
}
