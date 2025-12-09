//
//  SimpleCanendarView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-12-01.
//

import SwiftUI

struct SimpleCalendarGrid: View {
    let currentdate: Date
    @State private var selectedDate: Date? = nil
    
    @EnvironmentObject var myshowsmodel: MyShowsModel

    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

    var body: some View {
        let today = Date()
        let monthDates = generateDates(for: today)

        VStack {
            Text("\(selectedDate ?? Date())")
            // Days of week headers
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
            }
            // Calendar grid
            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 7), spacing: 8) {
                ForEach(monthDates, id: \.self) { date in
                    Button(action: {
                        selectedDate = date
                        
                    }) {
                        Text(dateText(date))
                            .frame(maxWidth: .infinity, minHeight: 36)
                            .background(myshowsmodel.upcomingEpisodes.keys.contains(date) ? Color.blue.opacity(0.2) : Color.clear)
                        // this colours the selected date when clicked
//                            .background(isSameDay(date1: date, date2: selectedDate) ? Color.blue.opacity(0.2) : Color.clear)
                            .clipShape(Circle())
                    }
                    .foregroundColor(isSameDay(date1: date, date2: selectedDate) ? .blue : .primary)
                    .disabled(!calendar.isDate(date, equalTo: today, toGranularity: .month))
                }
            }
        }
        .padding()
        .onAppear() {
            selectedDate = currentdate
            // Filter for upcoming only
            myshowsmodel.upcomingEpisodes = myshowsmodel.episodeDates.filter { date, _ in
                   date > Date()
               }
        }
    }

    // Generate all days to show in the grid (including leading/trailing days for alignment)
    func generateDates(for referenceDate: Date) -> [Date] {
        let components = calendar.dateComponents([.year, .month], from: referenceDate)
        guard let monthStart = calendar.date(from: components) else { return [] }

        let range = calendar.range(of: .day, in: .month, for: monthStart)!
        let firstWeekday = calendar.component(.weekday, from: monthStart)
        let daysInMonth = range.count

        // Fill leading days from previous month
        var dates: [Date] = []
        for i in 1..<(firstWeekday) {
            if let date = calendar.date(byAdding: .day, value: i - firstWeekday, to: monthStart) {
                dates.append(date)
            }
        }
        // Fill current month days
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                dates.append(date)
            }
        }
        // Fill trailing days to complete last week row
        while dates.count % 7 != 0 {
            if let date = calendar.date(byAdding: .day, value: dates.count - firstWeekday + 1, to: monthStart) {
                dates.append(date)
            }
        }
        return dates
    }

    func isSameDay(date1: Date?, date2: Date?) -> Bool {
        guard let d1 = date1, let d2 = date2 else { return false }
        return calendar.isDate(d1, inSameDayAs: d2)
    }

    func dateText(_ date: Date) -> String {
        let day = calendar.component(.day, from: date)
        return "\(day)"
    }
}

#Preview {
    SimpleCalendarGrid(currentdate: Date())
}
