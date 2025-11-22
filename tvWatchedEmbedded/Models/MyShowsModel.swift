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
    
    internal init(MyShows: [MyShow] = []) {
        fetchMyShows()
    }

    func fetchMyShows() {

        if let loadedShows = DataStore.shared.loadShows([MyShow].self) {
            MyShows = loadedShows.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
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


