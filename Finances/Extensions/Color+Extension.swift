// 12.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI

struct ColorData: Codable, Comparable {
    var red: Double = 1
    var green: Double = 1
    var blue: Double = 1
    var opacity: Double = 1
    
    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    init(_ color: Color) {
        let resolved = color.resolve(in: EnvironmentValues())
        self.red = Double(resolved.red)
        self.green = Double(resolved.green)
        self.blue = Double(resolved.blue)
        self.opacity = Double(resolved.opacity)
    }
    
    init(_ red: Double, _ green: Double, _ blue: Double, _ opacity: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.opacity = opacity
    }
    
    public static func < (lhs: ColorData, rhs: ColorData) -> Bool {
        let lhsResolved = lhs.color.resolve(in: EnvironmentValues())
        let lhsLum = 0.2126 * lhsResolved.red + 0.7152 * lhsResolved.green + 0.0722 * lhsResolved.blue
        let rhsResolved = rhs.color.resolve(in: EnvironmentValues())
        let rhsLum = 0.2126 * rhsResolved.red + 0.7152 * rhsResolved.green + 0.0722 * rhsResolved.blue
        return lhsLum < rhsLum
    }
}

extension Color: Comparable {
    public static func < (lhs: Color, rhs: Color) -> Bool {
        let lhsResolved = lhs.resolve(in: EnvironmentValues())
        let lhsLum = 0.2126 * lhsResolved.red + 0.7152 * lhsResolved.green + 0.0722 * lhsResolved.blue
        let rhsResolved = rhs.resolve(in: EnvironmentValues())
        let rhsLum = 0.2126 * rhsResolved.red + 0.7152 * rhsResolved.green + 0.0722 * rhsResolved.blue
        return lhsLum < rhsLum
    }
    
    var isDark: Bool {
        let resolved = self.resolve(in: EnvironmentValues())
        let lum = 0.2126 * resolved.red + 0.7152 * resolved.green + 0.0722 * resolved.blue
        return lum < 0.5
    }
    
    func gradientArray(_ count: Int) -> [Color] {
        let step: Double = 1.0 / Double(count)
        return (0..<count).map({ i in Color.init(hue: Double(i) * step, saturation: 1, brightness: 1)})
    }
    
    func uint32_t() -> UInt32 {
        let result: UInt32 = 0
        
        let components = self.cgColor?.components
        // let red = components?[0]
        // let green = components?[1]
        // let blue = components?[2]
        
        //        result = red << green << blue
        
        return result
    }
}
