//
//  ContentView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct ContentView: View {
    @State private var show : ShowBase = ShowBase()
    @State private var error: String?
    var body: some View {
        VStack {
            
            Text(show.name ?? "unKnown")
            Text(show.embedded?.episodes?[0].name ?? "Unknown episode")
        }
        .padding()
        .onAppear {
            Task {
                await loadShows(showName:  "A Man on the Inside")
            }
        }
    }
    func loadShows(showName: String) async {
//        guard let url = URL(string: "https://api.tvmaze.com/singlesearch/shows?q=\(showName)&embed=episodes") else {
            guard let url = URL(string: "https://api.tvmaze.com/shows/74443?embed=episodes") else {
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
}



