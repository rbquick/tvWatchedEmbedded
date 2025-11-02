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
        guard let show = MyShows.first(where: { $0.id == myshowid }),
              let episodes = show.episodes else {
            return false
        }
        return episodes.contains(where: { $0.id == episodeid })
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
