//
//  Scheduler.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-12-01.
//

import SwiftUI

struct Scheduler: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    @State private var episodeDates: [Date: [(MyShow, EpisodeBase)]] = [:]
    @State private var selectedDates: [Date] = []
    @State private var viewStyle: CalendarViewStyle = .monthly

    // Computed property instead of local let in body
    private var sortedDates: [Date] {
        episodeDates.keys.sorted()
    }
    
    enum CalendarViewStyle: String, CaseIterable, Identifiable {
        case monthly = "Month"
        case weekly = "Week"
        var id: String { self.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Scheduler - Calendar View")
                    .font(.title2)
                Spacer()
                Picker("View", selection: $viewStyle) {
                    ForEach(CalendarViewStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 160)
            }.padding(.horizontal)
            Divider()

            if #available(iOS 17.0, macOS 14.0, *) {
                SimpleCalendarGrid(currentdate: Date(), selectedDate: Date())
                    .frame(maxHeight: 360)
                    .padding()
            } else {
                Text("CalendarView requires iOS 17 or macOS 14+")
                    .foregroundColor(.red)
            }
            Divider()

            if !selectedDates.isEmpty {
                Text("Episodes on Selected Dates:")
                    .font(.headline)
                ForEach(selectedDates, id: \.self) { date in
                    if let episodes = episodeDates[date] {
                        ForEach(episodes, id: \.1.id) { (show, episode) in
                            Text("\(show.name): S\(episode.season)E\(episode.episode) \(episode.title)")
                                .font(.subheadline)
                        }
                    }
                }
            } else {
                Text("Select a date to see episodes.")
            }
        }
        .onAppear { loadEpisodeDates() }
    }

    func calendarInterval(for style: CalendarViewStyle) -> DateInterval {
        let now = Date()
        let calendar = Calendar.current
        switch style {
        case .monthly:
            let start = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) ?? now
            let end = calendar.date(byAdding: .month, value: 1, to: start) ?? now
            return DateInterval(start: start, end: end)
        case .weekly:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)) ?? now
            let end = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? now
            return DateInterval(start: weekStart, end: end)
        }
    }

    func loadEpisodeDates() {
        myshowsmodel.episodeDates.removeAll()
        for myShow in myshowsmodel.MyShows {
            if let baseShow = myshowsmodel.allBaseShows.first(where: { $0.id == myShow.id }) {
                let episodes = baseShow.embedded?.episodes ?? []
                for ep in episodes {
                    if let airdate = ep.airdate, !airdate.isEmpty, let date = calendarDateParser.date(from: airdate) {
                        let converted = EpisodeBase(id: ep.id ?? 0, season: ep.season ?? 0, episode: ep.number ?? 0, title: ep.name ?? "", airdate: airdate)
                        myshowsmodel.episodeDates[date, default: []].append((myShow, converted))
                    }
                }
            }
        }
    }

    func didTap(date: Date) {
        if selectedDates.contains(date) {
            selectedDates.removeAll(where: { $0 == date })
        } else {
            selectedDates.append(date)
        }
    }

    var calendarDayFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "d"
        return df
    }
    var calendarDateParser: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
}

#Preview {
    Scheduler()
        .environmentObject(MyShowsModel())
}
