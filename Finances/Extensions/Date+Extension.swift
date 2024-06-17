// 24.01.23, Swift 5.0, macOS 13.1, Xcode 12.4
// Copyright © 2023 amaider. All rights reserved.

import Foundation

extension Date {
    func matches(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Bool {
        Calendar.current.date(self, matchesComponents: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second))
    }
    
    func byAdding(_ component: Calendar.Component, value: Int) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self)!
    }
    
    func startOf(_ component: Calendar.Component) -> Date {
        var components: Set<Calendar.Component> = []
        
        switch component {
            case .second:   components.insert(.second); fallthrough
            case .minute:   components.insert(.minute); fallthrough
            case .hour:     components.insert(.hour); fallthrough
            case .day:      components.insert(.day); fallthrough
            case .month:    components.insert(.month); fallthrough
            case .year:     components.insert(.year); fallthrough
            case .era:      components.insert(.era)
            default: break
        }
        
        return Calendar.current.date(from: Calendar.current.dateComponents(components, from: self))!
    }
    
    func startOf(adding value: Int, _ component: Calendar.Component) -> Date {
        Calendar.current.date(byAdding: component, value: value, to: self.startOf(component))!
    }
    
    func endOf(_ component: Calendar.Component) -> Date {
        let startOf: Date = self.startOf(component)
        var components: DateComponents = DateComponents(nanosecond: -1_000_000)
        
        switch component {
            case .era:      components.era = 1
            case .year:     components.year = 1
            case .month:    components.month = 1
            case .day:      components.day = 1
            case .hour:     components.hour = 0
            case .minute:   components.minute = 0
            case .second:   components.second = 0
            default: break
        }
        return Calendar.current.date(byAdding: components, to: startOf)!
    }
    
    static func iso8601(year: Int, month: Int, day: Int = 1, hour: Int = 0, minutes: Int = 0, seconds: Int = 0) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minutes, second: seconds)) ?? Date()
    }
}
