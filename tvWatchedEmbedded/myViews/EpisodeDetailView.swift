//
//  EpisodeDetailView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct EpisodeDetailView: View {
    let episode: Episodes
    var body: some View {
        Text(episode.name ?? "Unknown")
            .font(.headline)
        if let season = episode.season, let number = episode.number, let aired = episode.airdate {
            Text("Season \(season), Episode \(number), Aired \(aired)")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    let episode = Episodes(id: 1, name: "Test Episode", season: 1, number: 1, airdate: "2025-10-29")
    EpisodeDetailView(episode: episode)
}
