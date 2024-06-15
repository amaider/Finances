// 19.11.23, Swift 5.0, macOS 14.0, Xcode 15.0.1
// Copyright © 2023 amaider. All rights reserved.

import SwiftUI
import SwiftData
import Charts

struct DatePickerPopover: View {
//    @Environment(\.modelContext) var modelContext
    @Query var transactions: [Transaction]
    
    @Binding var currDate: Date
    
    @State var showMonthSelect: Bool = false
    
    @State private var years: Set<Int> = []
    @State private var months: Set<Int> = []
    
    let fmt: ISO8601DateFormatter = {
        let fmt = ISO8601DateFormatter()
        fmt.formatOptions = [.withFullTime, .withFullDate]
        return fmt
    }()
    
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
                    // MARK: Month Picker
                    let monthBinding: Binding<Int> = Binding(
                        get: { Calendar.current.component(.month, from: currDate) },
                        set: { 
//                            currDate = .iso8601(year: Calendar.current.component(.year, from: currDate), month: ($0+1) % 12, day: 1)
                            currDate = .iso8601(year: Calendar.current.component(.year, from: currDate), month: $0, day: 1)
                            print("new month: \($0)", fmt.string(from: currDate))
                        }
                    )
                    Picker("month", selection: monthBinding, content: {
                        ForEach(months.sorted(), id: \.self, content: { month in
                            HStack(content: {
//                                Text(monthName(from: month)).tag(month)
                                Text("\(month)").tag(month)
                                    .fixedSize()
                                Spacer()
                            })
                        })
                    })
                    .frame(width: 150)
                    
                    // MARK: Year Picker
                    let yearBinding: Binding<Int> = Binding(
                        get: { Calendar.current.component(.year, from: currDate) },
                        set: { newValue in
                            currDate = .iso8601(year: newValue, month: Calendar.current.component(.month, from: currDate))
                            months = Set(transactions.filter({ Calendar.current.component(.year, from: $0.date) == newValue }).map({ Calendar.current.component(.month, from: $0.date) }))
                        }
                    )
                    Picker("year", selection: yearBinding, content: {
                        ForEach(years.sorted(), id: \.self, content: { year in
                            Text("\(year)").tag(year)
                        })
                    })
                    .frame(width: 100)
                    .onAppear(perform: {
                        DispatchQueue.global(qos: .background).async(execute: {
                            months = Set(transactions.filter({ Calendar.current.component(.year, from: $0.date) == years.sorted().first }).map({ Calendar.current.component(.month, from: $0.date) }))
                        })
                    })
                })
                .pickerStyle(.wheel)
            }
            
            // DatePicker("DatePicker", selection: $currDate, displayedComponents: .date)
            //     .datePickerStyle(.graphical)
            //     .labelsHidden()
        })
        .presentationCompactAdaptation(.popover)
        .padding()
        .onAppear(perform: {
            showMonthSelect = true
            DispatchQueue.global(qos: .background).async(execute: {
                /// add all years
                years = Set(transactions.map({ Calendar.current.component(.year, from: $0.date) }))
            })
        })
    }
    
    let monthName: [String] = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    
    func monthName(from monthNumber: Int) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let dateComponents = DateComponents(calendar: Calendar.current, month: monthNumber)
        let date = Calendar.current.date(from: dateComponents)!
        return dateFormatter.string(from: date)
    }
}

#Preview {
    DatePickerPopover(currDate: .constant(.now))
}
