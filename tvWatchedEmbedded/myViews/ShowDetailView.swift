//
//  ShowDetailView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct ShowDetailView: View {
    let myshow: MyShow
    @State var show: ShowBase = ShowBase()
    
    @State private var error: String?
    var sortedEpisodes: [Episodes] {
        (show.embedded?.episodes ?? []).sorted {
            if let season0 = $0.season, let season1 = $1.season, season0 != season1 {
                return season0 > season1 // descending season
            }
            if let number0 = $0.number, let number1 = $1.number {
                return number0 > number1 // descending episode number
            }
            return false
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                
                if let image = show.image?.medium {
                    AsyncImage(url: URL(string: image)) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 200)
                    } placeholder: {
                        ProgressView()
                    }
                }
                Text(myshow.name)
                    .font(.largeTitle)
                    .bold()
            }
            
            
            if let episodes = show.embedded?.episodes, !episodes.isEmpty {
                List(sortedEpisodes, id: \.id) { episode in
                    VStack(alignment: .leading) {
                        EpisodeDetailView(episode: episode)
//                        Text(episode.name ?? "Unknown")
//                            .font(.headline)
//                        if let season = episode.season, let number = episode.number, let aired = episode.airdate {
//                            Text("Season \(season), Episode \(number), Aired \(aired)")
//                                .font(.subheadline)
//                                .foregroundColor(.secondary)
//                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                Text("No episodes available")
                    .foregroundColor(.secondary)
            }
            
            if let error = error {
                Text("Error: \(error)")
                    .foregroundColor(.red)
            }
        }
        .onAppear {
            Task {
                await loadShows(query: myshow.name)
            }
        }
        .padding()
    }
    func loadShows(query: String) async {
        guard let url = URL(string: "https://api.tvmaze.com/singlesearch/shows?q=\(query)&embed=episodes") else {
            error = "Invalid URL"
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let results = try JSONDecoder().decode(ShowBase.self, from: data)
            show = results
            
            //            var episodes: [MyEpisode] = []
            //             let epid = show.embedded?.episodes?[0].id ?? 0
            //            let newepisode1 = MyEpisode(id: epid, dateWatched: "2024-10-10")
            //            episodes.append(newepisode1)
            //            var myshowsxx: [MyShow] = []
            //            let showxx = MyShow(id: show.id ?? 0, name: show.name ?? "No Name", episodes: episodes)
            //            myshowsxx.append(showxx)
            //
            //            DataStore.shared.saveShows(myshowsxx)
            //            print(showxx)
            //            let a = 1
        } catch {
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    ShowDetailView(myshow: MyShow())
}
