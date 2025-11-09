//
//  MyCalendar.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-11-04.
//

import SwiftUI

struct MyCalendar: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    
    // Holds all base shows loaded asynchronously
    @State private var allBaseShows: [ShowBase] = []
    
    // Holds any error messages during loading (not yet used)
    @State private var error: String?
    
    var body: some View {
        VStack {
            // Display list of shows with upcoming episodes after watched ones
//            List(showsWithUpcomingEpisodes, id: \.id) { myShow in
//                VStack(alignment: .leading) {
//                    Text(myShow.name)
//                        .font(.headline)
//                    
//                    ForEach(myshowsmodel.myShow.episodes.filter { episode in
//                        // Filter episodes that have been watched (dateWatched not empty)
//                        !episode.dateWatched.isEmpty
//                    }, id: \.id) { watchedEpisode in
//                        // Show info about the watched episode
//                        Text("Watched: S\(watchedEpisode.season)E\(watchedEpisode.episode) - \(watchedEpisode.title)")
//                            .font(.subheadline)
//                        
//                        // Find next upcoming episode(s) in base show after this watched episode
//                        if let baseShow = allBaseShows.first(where: { $0.id == myShow.id }) {
//                            let upcoming = upcomingEpisodes(after: watchedEpisode, in: baseShow)
//                            if !upcoming.isEmpty {
//                                ForEach(upcoming, id: \.id) { ep in
//                                    Text("Upcoming: S\(ep.season)E\(ep.episode) - \(ep.title) (Airdate: \(ep.airdate))")
//                                        .font(.caption)
//                                        .foregroundColor(.secondary)
//                                }
//                            }
//                        }
//                    }
//                }
//                .padding(.vertical, 4)
//            }
        }
        // Load all base shows when view appears
        .task {
            await loadAllShows()
        }
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
        try? await Task.sleep(nanoseconds: 500_000_000)
        
        // Placeholder: empty array or dummy show bases
        // Here we create dummy data to avoid preview errors
        let dummyepisodes: [Episodes] = [
            Episodes(id: 1, name: "Pilot", season: 1, number: 1, airdate: "2025-01-01"),
            Episodes(id: 2, name: "Second Episode", season: 1, number: 2, airdate: "2025-01-08")
        ]
        let dummyembedded = _embedded(episodes: dummyepisodes)
        let dummyShowBase = ShowBase(
            id: 1,
            name: "Dummy Show",
            embedded: dummyembedded
        )
        // Assign dummy data for now
        self.allBaseShows = [dummyShowBase]
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
        } catch {
            self.error = error.localizedDescription
        }
    }
    /// Returns episodes from the base show that come after the given watched episode
    /// Compares via season and episode numbers since airdate strings may be unreliable
    func upcomingEpisodes(after watchedEpisode: Episode, in baseShow: ShowBase) -> [EpisodeBase] {
        // Flatten all episodes in base show
        let allEpisodes = baseShow.episodes
        
        // Filter episodes that come after the watched episode
        allEpisodes.filter { ep in
            // Compare season first, then episode number
            if ep.season > watchedEpisode.season {
                return true
            } else if ep.season == watchedEpisode.season && ep.episode > watchedEpisode.episode {
                return true
            }
            return false
        }
    }
}

// MARK: - Dummy Data Models for Preview and Compilation

// Base show model representing the original show data (episodes)
struct ShowBaseAI: Identifiable {
    let id: String
    let name: String
    let episodes: [EpisodeBase]
}

struct EpisodeBase: Identifiable {
    let id: String
    let season: Int
    let episode: Int
    let title: String
    let airdate: String // Assume format "YYYY-MM-DD"
}


//// Dummy MyShowsModel for compilation and preview purposes
//class MyShowsModelPreview: ObservableObject {
//    @Published var MyShows: [MyShow] = []
//}
//
//#Preview {
//    MyCalendar()
//        .environmentObject(MyShowsModelPreview())
//}

