//
//  MyCalendar.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-11-04.
//

import SwiftUI

struct MyCalendarView: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    
    @Environment(\.selectedTab) var selectedTab
    @Environment(\.selectedShowID) var selectedShowID
    
    // Holds all base shows loaded asynchronously
    @State private var show: ShowBase = ShowBase()
    @State private var allBaseShows: [ShowBase] = []
    
    // number of episodes that will be listed on a show
    @State var episodecnt = 2
    
    // Holds any error messages during loading (not yet used)
    @State private var error: String?
    
    var body: some View {
        
        VStack {
//            List(showsWithUpcomingEpisodes, id: \.id) { myShow in
            // new let and list start
            let showsWithFutureEpisodes = showsWithUpcomingEpisodes.filter { show in
                if let lastWatched = show.episodes.filter({ !$0.dateWatched.isEmpty }).max(by: {
                    ($0.season ?? 0, $0.number ?? 0) < ($1.season ?? 0, $1.number ?? 0) }) {
                    if let baseShow = allBaseShows.first(where: { $0.id == show.id }) {
                        let upcoming = upcomingEpisodes(after: lastWatched, in: baseShow)
                        return !upcoming.isEmpty
                    }
                }
                return false
            }
            HStack {
                Text("My Calendar \(myshowsmodel.MyShows.count)")
                Text("allBaseShows: \(showsWithFutureEpisodes.count)")
                Spacer()
                Text("Number of episodes to showing \(episodecnt):")
                    Stepper(value: $episodecnt, in: 1...30) {
                        EmptyView() // No label inside Stepper, so only the +/- buttons show
                    }
                    .frame(width: 100) // Optional: fix width of Stepper to keep it tight
                
            }
            .padding(.horizontal)
            List(showsWithFutureEpisodes, id: \.id) { myShow in
            // nes let and list end
                VStack(alignment: .leading) {
                    // ai start only list last episode watched with upcoming episodes after that episode
                    if let lastWatched = myShow.episodes
                        .filter({ !$0.dateWatched.isEmpty })
                        .max(by: {
                            ($0.season ?? 0, $0.number ?? 0) < ($1.season ?? 0, $1.number ?? 0)
                        }) {
                        
                        // Use lastWatched episode here
                        let thisEpisodeName = baseShowEpisodeName(showid: myShow.id, season: lastWatched.season ?? 0, episode: lastWatched.number ?? 0)
                        
                        
                        if let baseShow = allBaseShows.first(where: { $0.id == myShow.id }) {
                            let upcoming = upcomingEpisodes(after: lastWatched, in: baseShow)
                            if !upcoming.isEmpty {
                                HStack {
                                    Text(myShow.name)
                                        .font(.title)
                                    Spacer()
                                    if myShow.Apollo {
                                        Button("Apollo") {
                                            print("Today..............")
                                            selectedTab?.wrappedValue = 0
                                            selectedShowID?.wrappedValue = myShow.id
                                        }
                                        .buttonStyle(myButtonStyle())
                                    }
                                    if myShow.Kodi {
                                        Button("Koli") {
                                            print("Today..............")
                                            selectedTab?.wrappedValue = 0
                                            selectedShowID?.wrappedValue = myShow.id
                                        }
                                        .buttonStyle(myButtonStyle())
                                    }
                                }
                                HStack {
                                    Text("Watched: S\(lastWatched.season ?? 0)E\(lastWatched.number ?? 0) \(thisEpisodeName)")
                                        .font(.subheadline)
                                    Spacer()
                                    Text("\(upcoming.count) episodes coming")
                                }
                                
                                let limitedupcoming = Array(upcoming.prefix(episodecnt))
                                ForEach(limitedupcoming, id: \.id) { ep in                                        Text("Upcoming: S\(ep.season)E\(ep.episode) - \(ep.title) (Airdate: \(ep.airdate))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
        }
        // Load all base shows when view appears
        .onAppear {
            Task {
                await loadAllShows()
            }
        }
    }
    func baseShowEpisodeName(showid: Int, season: Int, episode: Int) -> String {
        guard let baseshow = allBaseShows.first(where: {$0.id ?? 0 == showid}) else { return ""}
        guard let baseepisodes = baseshow.embedded?.episodes else { return ""}
        if let episode = baseepisodes.first(where: {$0.season == season && $0.number == episode}) {
            return episode.name ?? ""
        }
        return ""
    }
    /// Computed property that filters MyShows to those that have upcoming episodes after any watched episode
    var showsWithUpcomingEpisodes: [MyShow] {
        myshowsmodel.MyShows.filter { myShow in
            // Find corresponding base show
            guard let baseShow = allBaseShows.first(where: { $0.id == myShow.id }) else {
                return false
            }
            
            // Check if any watched episode has a following episode in base show
            for watchedEpisode in myShow.episodes where !watchedEpisode.dateWatched.isEmpty {
                // If any upcoming episode exists after this watched episode, include this show
                if !upcomingEpisodes(after: watchedEpisode, in: baseShow).isEmpty {
                    return true
                }
            }
            
            return false
        }
    }
    
    /// Loads all base shows asynchronously - placeholder implementation
    func loadAllShows() async {
        // For demo: simulate async loading delay and load empty or dummy data
        // Replace this with real API or data fetching logic as needed
        
        // Simulate delay
//        try? await Task.sleep(nanoseconds: 500_000_000)
        allBaseShows.removeAll()
        var i = 0
        repeat {
//            if !myshowsmodel.MyShows[i].episodes.isEmpty  {
                await loadShows(query: myshowsmodel.MyShows[i].id)
//            }
                i += 1
            } while i < myshowsmodel.MyShows.count
        
    }
    func loadShows(query: Int) async {
        guard let url = URL(string: "https://api.tvmaze.com/shows/\(query)?embed=episodes") else {
            error = "Invalid URL"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(ShowBase.self, from: data)
            show = results
            allBaseShows.append(show)
        } catch {
            self.error = error.localizedDescription
        }
    }
    /// Returns episodes from the base show that come after the given watched episode
    /// Compares via season and episode numbers since airdate strings may be unreliable
    func upcomingEpisodes(after watchedEpisode: MyEpisode, in baseShow: ShowBase) -> [EpisodeBase] {
        // Get all episodes from the base show
        let allEpisodes = baseShow.embedded?.episodes ?? []
        let upcoming = allEpisodes.filter { ep in
            if let epSeason = ep.season, let watchedSeason = watchedEpisode.season, epSeason > watchedSeason {
                return true
            } else if ep.season == watchedEpisode.season,
                      let epNumber = ep.number, let watchedNumber = watchedEpisode.number,
                      epNumber > watchedNumber {
                return true
            }
            return false
        }.map { ep in
            EpisodeBase(id: ep.id ?? 0, season: ep.season ?? 0, episode: ep.number ?? 0, title: ep.name ?? "", airdate: ep.airdate ?? "")
        }
        return upcoming
    }
}

// MARK: - Dummy Data Models for Preview and Compilation

// Base show model representing the original show data (episodes)
struct ShowBaseAI: Identifiable {
    let id: Int
    let name: String
    let episodes: [EpisodeBase]
}

struct EpisodeBase: Identifiable {
    let id: Int
    let season: Int
    let episode: Int
    let title: String
    let airdate: String // Assume format "YYYY-MM-DD"
}


//// Dummy MyShowsModel for compilation and preview purposes
//class MyShowsModelPreview: ObservableObject {
//    @Published var MyShows: [MyShow] = []
//}

#Preview {
    MyCalendarView()
        .environmentObject(MyShowsModel())
}

