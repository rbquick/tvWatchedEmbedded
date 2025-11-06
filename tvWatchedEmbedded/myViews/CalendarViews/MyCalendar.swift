//
//  MyCalendar.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-11-04.
//

import SwiftUI

struct MyCalendar: View {
    @State var showDatePicker = false
    @State var selectedDate = Date()
    var body: some View {
        VStack {
            Button("click me") {
                showDatePicker = true
            }
            if showDatePicker {
                VStack {
                    HStack {
                        Button("Save Date  ") {
                            showDatePicker = false
                            print("Save Date")
                        }
                        Button("Today") {
                            showDatePicker = false
                            print("Today")
                        }
                        Button("Cancel") {
                            showDatePicker = false
                            print("Cancel")
                        }
                    }
                    DatePicker("Select Watched Date", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                    
                }
            }
        }
    }
}

#Preview {
    MyCalendar()
}
