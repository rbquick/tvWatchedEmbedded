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
    var body: some View {
        Text(episode.name ?? "Unknown")
            .font(.headline)
        if let id = episode.id, let season = episode.season, let number = episode.number, let aired = episode.airdate {
            Text("Season \(season), Episode \(number), Aired \(aired)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Button("On File") {
                                    // Add any action here if needed; or leave empty for visual only
                                }
                                .foregroundColor(
                                    myshowsmodel.showepisodeOnFile(myshowid: myshowid, episodeid: id) ? .red : .blue
                                )
                                .buttonStyle(.plain) // Avoid default button styles for text-only button
                            
        }
    }
}

#Preview {
    let episode = Episodes(id: 1, name: "Test Episode", season: 1, number: 1, airdate: "2025-10-29")
    EpisodeDetailView(myshowid: 1, episode: episode)
}
