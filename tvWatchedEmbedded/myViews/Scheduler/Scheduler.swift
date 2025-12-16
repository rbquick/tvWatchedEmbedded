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
    @State private var viewStyle: CalendarViewStyle = .previous
    @State private var currentDate: Date = Date()
    // Computed property instead of local let in body
    private var sortedDates: [Date] {
        episodeDates.keys.sorted()
    }
    
    enum CalendarViewStyle: String, CaseIterable, Identifiable {
        case previous = "<<"
        case current = "current"
        case next = ">>"
        var id: String { self.rawValue }
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Scheduler - Calendar View")
                    .font(.title2)
                Spacer()
                HStack(spacing: 8) {
                    Button("<<") {
                        viewStyle = .previous
                        let interval = calendarInterval(for: .previous)
                        currentDate = interval.start
                    }
                    .buttonStyle(.bordered)

                    Button("current") {
                        viewStyle = .current
                        let interval = calendarInterval(for: .current)
                        currentDate = interval.start
                    }
                    .buttonStyle(.bordered)

                    Button(">>") {
                        viewStyle = .next
                        let interval = calendarInterval(for: .next)
                        currentDate = interval.start
                    }
                    .buttonStyle(.bordered)
                }
                .frame(width: 200)
            }.padding(.horizontal)
            Divider()

                SimpleCalendarGrid(currentdate: currentDate)
                    .frame(maxHeight: 360)
                    .padding()

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
        let calendar = Calendar.current
        switch style {
        case .current:
            // Keep currentDate as-is and return the interval for its month
            if let interval = calendar.dateInterval(of: .month, for: Date()) {
                return interval
            }
            // Fallback to now's month if needed
            return calendar.dateInterval(of: .month, for: Date()) ?? DateInterval(start: Date(), end: Date())

        case .previous:
            // Move currentDate back one month and return that month interval
            if let prev = calendar.date(byAdding: .month, value: -1, to: currentDate),
               let interval = calendar.dateInterval(of: .month, for: prev) {
                currentDate = prev
                return interval
            }
            // Fallback: use current month interval
            return calendar.dateInterval(of: .month, for: currentDate) ?? DateInterval(start: currentDate, end: currentDate)

        case .next:
            // Move currentDate forward one month and return that month interval
            if let next = calendar.date(byAdding: .month, value: 1, to: currentDate),
               let interval = calendar.dateInterval(of: .month, for: next) {
                currentDate = next
                return interval
            }
            // Fallback: use current month interval
            return calendar.dateInterval(of: .month, for: currentDate) ?? DateInterval(start: currentDate, end: currentDate)
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

