//
//  MyShowsModel.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-31.
//

import SwiftUI
import Observation
import Combine


class MyShowsModel: ObservableObject {

    @Published var MyShows: [MyShow] = []
    @Published var allBaseShows: [ShowBase] = []
    @Published var allBaseShowsComplete: Bool = false
    
    var calendarDateParser: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        return df
    }
    // create a view showing an entry of the upcomingEpisodes showing the MyShow.name and the title from the EpisodeBase that matches the date from the Date: key
    @Published var episodeDates: [Date: [(MyShow, EpisodeBase)]] = [:]
    @Published var upcomingEpisodes: [Date: [(MyShow, EpisodeBase)]] = [:]
//    @Published var episodeDates: [Date] = []
    
    // Holds all base shows loaded asynchronously
    private var show: ShowBase = ShowBase()
    @State var error: String = ""
    
    internal init(MyShows: [MyShow] = []) {
        fetchMyShows()
    }

    func fetchMyShows() {

        if let loadedShows = DataStore.shared.loadShows([MyShow].self) {
            MyShows = loadedShows.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            loadTask()
            } else {
                MyShows = []
                print("Failed to load shows")
            }
        }
    
    func addShow(_ show: MyShow) {
        MyShows.append(show)
        MyShows.sort { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }
    func update(show: MyShow) {
        if let index = MyShows.firstIndex(of: show) {
            MyShows[index] = show
        }
    }
    func saveMy() {
        DataStore.shared.saveShows(MyShows)
    }
    func delete(at offsets: IndexSet) {
        MyShows.remove(atOffsets: offsets)
        saveMy()
    }
    func showOnFile(myshowid: Int) -> Bool {
        MyShows.contains(where: { $0.id == myshowid })
    }
    func showepisodeOnFile(myshowid: Int, episodeid: Int) -> Bool {
        guard let show = MyShows.first(where: { $0.id == myshowid })
               else {
            return false
        }
        let episodes = show.episodes
        return episodes.contains(where: { $0.id == episodeid })
    }
    func showepisodeDatewatched(myshowid: Int, episodeid: Int) -> String {
        guard let show = MyShows.first(where: { $0.id == myshowid })
               else {
            return ""
        }
        guard let episode = show.episodes.first(where: { $0.id == episodeid }) else { return ""}
        return episode.dateWatched
    }
    func changeEpisode(myshowid: Int, episodeid: Int, season: Int, number: Int, datewatched: String) -> String {
        guard let showIndex = MyShows.firstIndex(where: { $0.id == myshowid }) else {
            print("changeEpisode: no show")
            return ""
        }
        guard let episodeIndex = MyShows[showIndex].episodes.firstIndex(where: { $0.id == episodeid }) else {
            // there is no episode, so add it
            addepisode(myshowid: myshowid, episode: episodeid, season: season, number: number, datewatched: datewatched)
            print("changeEpisode: added episode")
            saveMy()
            return datewatched
        }
        // we have the episode, so update it from episodes array
        var episodes = MyShows[showIndex].episodes
        episodes[episodeIndex].season = season
        episodes[episodeIndex].number = number
        episodes[episodeIndex].dateWatched = datewatched
        episodes.sort {
            if $0.season == $1.season {
                return ($0.number ?? 0) > ($1.number ?? 0)
            } else {
                return ($0.season ?? 0) > ($1.season ?? 0)
            }
        }
        let show = MyShows[showIndex]
        let updatedShow = MyShow(id: show.id,
                                name: show.name,
                                Kodi: show.Kodi,
                                Apollo: show.Apollo,
                                Watching:  show.Watching,
                                episodes: episodes)
        print("changeEpisode: updated episode")
        MyShows[showIndex] = updatedShow
        saveMy()
        return ""
    }
    func getmyshow(myshowid: Int) -> MyShow {
        guard let showIndex = MyShows.firstIndex(where: { $0.id == myshowid }) else {
            let nofoundshow = MyShow(id: 0, name: "no show", Kodi: false, Apollo: false, Watching: false, episodes: [])
            return nofoundshow
        }
        print("getmyshow: \(MyShows[showIndex].name), \(MyShows[showIndex].episodes.count)")
        return MyShows[showIndex]
    }
    func getmyepisodeDateWatched(myshowid: Int, episodeid: Int) -> String {
        guard let showIndex = MyShows.firstIndex(where: { $0.id == myshowid }) else {
            return ""
        }
        guard let episodeIndex = MyShows[showIndex].episodes.firstIndex(where: { $0.id == episodeid }) else {
            return ""
        }
        // we have the episode, so update it from episodes array
        let episodes = MyShows[showIndex].episodes
        return episodes[episodeIndex].dateWatched

    }
    func addepisode(myshowid: Int, episode: Int, season: Int, number: Int, datewatched: String) {
        guard let index = MyShows.firstIndex(where: { $0.id == myshowid }) else { return }
        let newEpisode = MyEpisode(id: episode, season: season, number: number, dateWatched: datewatched)
        MyShows[index].episodes.append(newEpisode)
        MyShows[index].episodes.sort { 
            if $0.season == $1.season {
                return ($0.number ?? 0) > ($1.number ?? 0)
            } else {
                return ($0.season ?? 0) > ($1.season ?? 0)
            }
        }
    }
    func deleteepisode(myshowid: Int, episodeid: Int) {
        guard let showIndex = MyShows.firstIndex(where: { $0.id == myshowid }) else {
                    return
                }
                guard let episodeIndex = MyShows[showIndex].episodes.firstIndex(where: { $0.id == episodeid }) else {
                    return
                }
                // we have the episode, so update it from episodes array
            MyShows[showIndex].episodes.remove(atOffsets: [episodeIndex])
        }
    func updatedevice(myshowid: Int, apollo: Bool, kodi: Bool, watching: Bool) {
        guard let show = MyShows.first(where: { $0.id == myshowid })
                       else {
                    return
                }
        let newshow = MyShow(id: show.id, name: show.name, Kodi: kodi, Apollo: apollo, Watching: watching, episodes: show.episodes)
        
        update(show: newshow)
    }

    
    // code moved into here to support the allshowsbase
    
    func loadTask() {
        let work = Task {
                     print("start task work")
                     try? await loadAllShows()
                     print("completed task work")
            allBaseShowsComplete = true
                     // but as the task completes, this reference is released
                 }
        
        
        
        
//        Task {
//            await loadAllShows()
//        }
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
            if MyShows.count > 0 {
                if !MyShows[i].episodes.isEmpty  {
                    print("loadAllShows started loadShows")
                    await loadShows(query: MyShows[i].id)
                }
            }
                i += 1
            } while i < MyShows.count
        
    }
    func loadShows(query: Int) async {
        guard let url = URL(string: "https://api.tvmaze.com/shows/\(query)?embed=episodes") else {
            error = "Invalid URL"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(ShowBase.self, from: data)
//            let thisshow: ShowBase = results
            show = results
            allBaseShows.append(show)
            print("loadShows returned \(allBaseShows.count)")
        } catch {
            self.error = error.localizedDescription
        }
    }
    /// Computed property that filters MyShows to those that have upcoming episodes after any watched episode
    var showsWithUpcomingEpisodes: [MyShow] {
        MyShows.filter { myShow in
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
    /// Returns MyShow objects where the most recently watched episode has future upcoming episodes (strict)
    func showsWithFutureEpisodesStrict() -> [MyShow] {
//        return MyShows
        MyShows.filter { show in
            // Find the last watched episode
            if let lastWatched = show.episodes.filter({ !$0.dateWatched.isEmpty }).max(by: {
                ($0.season ?? 0, $0.number ?? 0) < ($1.season ?? 0, $1.number ?? 0) }) {
                if let baseShow = allBaseShows.first(where: { $0.id == show.id }) {
                    let upcoming = upcomingEpisodes(after: lastWatched, in: baseShow)
                    return !upcoming.isEmpty
                }
            }
            return false
        }
    }
    func inEpisodeSchedule(indate: Date, episodes: [EpisodeBase]) -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return episodes.contains(where: { dateFormatter.date(from: $0.airdate) == indate })
    }
    func getEpisodeSchedule(startDate: Date) {
        
        let myShows = showsWithFutureEpisodesStrict()
        for myShow in myShows {
            if let baseShow = allBaseShows.first(where: { $0.id == myShow.id }) {
                let episodes = baseShow.embedded?.episodes ?? []
                for ep in episodes {
                    if let airdate = ep.airdate, !airdate.isEmpty, let date = calendarDateParser.date(from: airdate) {
                        let converted = EpisodeBase(id: ep.id ?? 0, season: ep.season ?? 0, episode: ep.number ?? 0, title: ep.name ?? "", airdate: airdate)
                        episodeDates[date, default: []].append((myShow, converted))
                    }
                }
            }
        }
//        for i in 0..<myShows.count - 1 {
//            if let lastWatched = myShows[i].episodes
//                                    .filter({ !$0.dateWatched.isEmpty })
//                                    .max(by: {
//                                        ($0.season ?? 0, $0.number ?? 0) < ($1.season ?? 0, $1.number ?? 0)
//                                    })
//            {
//                let thisdate = myDateFormatter(inDate:
//                                                lastWatched.dateWatched) ?? Date()
//                episodeDates.append(thisdate)
//            }
//        }
    }
    /// Returns a limited array of upcoming EpisodeBase for a show after the last watched episode.
    /// - Parameters:
    ///   - show: The user's show instance.
    ///   - episodeLimit: The maximum number of upcoming episodes to return.
    /// - Returns: Array of EpisodeBase, limited to episodeLimit.
    func limitedUpcomingEpisodes(for show: MyShow, episodeLimit: Int) -> [EpisodeBase] {
        guard let lastWatched = show.episodes.filter({ !$0.dateWatched.isEmpty })
            .max(by: { ($0.season ?? 0, $0.number ?? 0) < ($1.season ?? 0, $1.number ?? 0) }),
              let baseShow = allBaseShows.first(where: { $0.id == show.id }) else {
            return []
        }
        let upcoming = upcomingEpisodes(after: lastWatched, in: baseShow)
        return Array(upcoming.prefix(episodeLimit))
    }
    /// Returns a flat array of all upcoming episodes (across all MyShows) that have an airdate on or after the provided start date.
    /// - Parameter startDate: The first date to include episodes.
    /// - Returns: Array of EpisodeBase for all upcoming episodes from all shows starting at the given date.
    func allUpcomingEpisodes(from startDate: Date) -> [EpisodeBase] {
        var result: [EpisodeBase] = []
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for show in MyShows {
            guard let lastWatched = show.episodes.filter({ !$0.dateWatched.isEmpty })
                .max(by: { ($0.season ?? 0, $0.number ?? 0) < ($1.season ?? 0, $1.number ?? 0) }),
                  let baseShow = allBaseShows.first(where: { $0.id == show.id }) else {
                continue
            }
            let upcoming = upcomingEpisodes(after: lastWatched, in: baseShow)
            let filtered = upcoming.filter { ep in
                if let airdate = dateFormatter.date(from: ep.airdate) {
                    return airdate >= startDate
                }
                return false
            }
            result.append(contentsOf: filtered)
        }
        return result
    }
}
        // sample code for tvmaze getting github going
//        var episodes: [MyEpisode] = []
//         let epid = show.embedded?.episodes?[0].id ?? 0
//        let newepisode1 = MyEpisode(id: epid, dateWatched: "2024-10-10")
//        episodes.append(newepisode1)
//        var myshowsxx: [MyShow] = []
//        let showxx = MyShow(id: show.id ?? 0, name: show.name ?? "No Name", episodes: episodes)
//        myshowsxx.append(showxx)
//
//        print(showxx)


