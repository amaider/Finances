// 19.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import Charts

struct DatePickerPopover: View {
    @Binding var currDate: Date
    
    @State var showMonthSelect: Bool = false
    
    var body: some View {
        VStack(content: {
            HStack(content: {
                Group(content: {
                    Text(currDate.formatted(.dateTime.year().month(.wide)))
                        .bold()
                        .foregroundStyle(showMonthSelect ? .blue : .primary)
                    Image(systemName: showMonthSelect ? "chevron.down" : "chevron.right")
                        .foregroundStyle(.blue)
                        .font(.subheadline)
                })
                .clipShape(Rectangle())
                .onTapGesture(perform: { showMonthSelect.toggle() })
                
                Spacer()
                
                Group(content: {
                    Image(systemName: "chevron.left")
                        .onTapGesture(perform: { currDate = currDate.getPreviousMonth() })
                    Spacer()
                        .frame(width: 25)
                    Image(systemName: "chevron.right")
                        .onTapGesture(perform: { currDate = currDate.getNextMonth() })
                })
                .bold()
                .foregroundStyle(.blue)
            })
            .fontWeight(.medium)
            
            if showMonthSelect {
                HStack(spacing: 0, content: {
                    let monthBinding: Binding<Int> = Binding(
                        get: { Calendar.current.component(.month, from: currDate) + 119 },
                        set: { currDate = .iso8601(year: Calendar.current.component(.year, from: currDate), month: ($0+1) % 12) }
                    )
                    let yearBinding: Binding<Int> = Binding(
                        get: { Calendar.current.component(.year, from: currDate) },
                        set: { currDate = .iso8601(year: $0, month: Calendar.current.component(.month, from: currDate)) }
                    )
                    Picker("month", selection: monthBinding, content: {
                        ForEach(0...240, id: \.self, content: { month in
                            HStack(content: {
                                Text("\(monthName[month % 12])").tag(month)
                                    .fixedSize()
                                Spacer()
                            })
                        })
                    })
                    .frame(width: 150)
                    Picker("year", selection: yearBinding, content: {
                        ForEach(1900..<2900, id: \.self, content: { year in
                            Text(year, format: .number).tag(year)
                        })
                    })
                    .frame(width: 100)
                })
                .pickerStyle(.wheel)
            }
            
            // DatePicker("DatePicker", selection: $currDate, displayedComponents: .date)
            //     .datePickerStyle(.graphical)
            //     .labelsHidden()
        })
        .presentationCompactAdaptation(.popover)
        .padding()
    }
    
    let monthName: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
}

#Preview {
    DatePickerPopover(currDate: .constant(.now))
}
