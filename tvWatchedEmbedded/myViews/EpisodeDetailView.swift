//
//  EpisodeDetailView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct EpisodeDetailView: View {
    let myshowid: Int
    let episode: Episodes
    @EnvironmentObject var myshowsmodel: MyShowsModel
    @State var isOnFile: Bool = false
    @State var isOnSummary: Bool = false
    
     // State for selected date as Date type
     @State private var selectedDate: Date = Date()
     // For showing or hiding the picker
     @State private var showDatePicker: Bool = false
     
     // Date formatter to convert between String and Date
     private var dateFormatter: DateFormatter {
         let df = DateFormatter()
         df.dateFormat = "yyyy-MM-dd" // match your date string format
         return df
     }
    var body: some View {
        Text(episode.name ?? "Unknown")
            .font(.headline)
        if let id = episode.id,
            let season = episode.season,
            let number = episode.number,
            let aired = episode.airdate {

            if let summary = episode.summary {
                Button("Show Summary") {
                    isOnSummary.toggle()
                }
                
                if isOnSummary {
                    Text(summary)
                }
            }

            Text("Season \(season), Episode \(number), Aired \(aired)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
            Button {
                showDatePicker.toggle()
            } label: {
                Text(isOnFile ? "Watched \(dateFormatter.string(from: selectedDate))" : "Not Watched")
            }
            .foregroundColor(
                isOnFile ? .red : .blue
            )
            .buttonStyle(.plain) // Avoid default button styles for text-only button
            .onAppear {
                isOnFile = myshowsmodel.showepisodeOnFile(myshowid: myshowid, episodeid: id)
                let dateString = myshowsmodel.showepisodeDatewatched(myshowid: myshowid, episodeid: id)
                if let date = dateFormatter.date(from: dateString) {
                    selectedDate = date
                }
            }
            if showDatePicker {
                 DatePicker("Select Watched Date", selection: $selectedDate, displayedComponents: .date)
                     .datePickerStyle(.graphical) // you can use .compact or .wheel styles too
                     .onChange(of: selectedDate) { oldValue, newValue in
                         let newDateString = dateFormatter.string(from: newValue)
                         _ = myshowsmodel.changeEpisode(myshowid: myshowid, episodeid: id, datewatched: newDateString)
                         isOnFile = true
                         showDatePicker.toggle()
                     }
             }
        }
    }
}

#Preview {
    let episode = Episodes(id: 1, name: "Test Episode", season: 1, number: 1, airdate: "2025-10-29")
    EpisodeDetailView(myshowid: 1, episode: episode)
        .environmentObject(MyShowsModel())
}
