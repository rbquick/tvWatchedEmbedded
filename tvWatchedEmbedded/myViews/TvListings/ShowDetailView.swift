//
//  ShowDetailView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct ShowDetailView: View {
    let myshow: MyShow
    @State private var apollo: Bool = false
    @State private var kodi: Bool = false
    @State private var watching: Bool = false
    @State private var comments: String = ""
    @State private var scrollepisodeID: Int = 0
    @State var show: ShowBase = ShowBase()
    @EnvironmentObject var myshowsmodel: MyShowsModel
    
    
    @State private var error: String?
    
//    init(myshow: MyShow) {
//        self.myshow = myshow
//         // Initialize the state from myshow property
//         _apollo = State(initialValue: myshow.Apollo)
//        _kodi = State(initialValue: myshow.Kodi)
//        if myshow.episodes.count > 0 {
//            _scrollepisodeID = State(initialValue: myshow.episodes[0].id)
//        }
//     }
    
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
        VStack(alignment: .leading, spacing: 0) {
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
                VStack(alignment: .leading) {
                    HStack {
                        Text(myshow.name)
                            .font(.largeTitle)
                            .bold()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    HStack(alignment: .center, spacing: 16) {
                        HStack(spacing: 4) {
                            Toggle("", isOn: $watching)
                                .labelsHidden()
                                .toggleStyle(.switch)
                                .frame(minWidth: 0, alignment: .leading)
                            Text(watching ? "watching" : "NOT watching")
                        }
                        HStack(spacing: 4) {
                            Toggle("", isOn: $apollo)
                                .labelStyle(.automatic)
                                .frame(minWidth: 0, alignment: .leading)
                            Text(apollo ? "On Appollo" : "NOT on Appollo")
                        }
                        HStack(spacing: 4) {
                            Toggle("", isOn: $kodi)
                                .labelStyle(.automatic)
                                .frame(minWidth: 0, alignment: .leading)
                            Text(kodi ? "On Kodi" : "NOT on Kodi")
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    TextEditor(text: $comments)
                        .frame(minHeight: 48, maxHeight: 80) // Adjust minHeight as desired for two lines
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.vertical, 4)
                    // Placeholder isn't natively supported, but label is clear from context
                    HStack {
                        Spacer()
                        Button("Save") {
                            print("Save..............")
                            myshowsmodel.updatedevice(myshowid: myshow.id, apollo: apollo, kodi: kodi, watching: watching, comments: comments)
                        }
                        .buttonStyle(myButtonStyle(backgroundColor: .clear))
                    }
                }
                .frame(maxHeight: .infinity, alignment: .top)
            }
            .frame(height: 200)
            .padding(.horizontal)
            .background(.yellow.opacity(1.0))

            if let episodes = show.embedded?.episodes, !episodes.isEmpty {
                ScrollViewReader { proxy in
                    List(sortedEpisodes, id: \.id) { episode in
                        HStack {
                            Spacer()
                            EpisodeDetailView(myshowid: myshow.id, episode: episode)
                            Spacer()
                        }
                        .padding(.vertical, 4)
                        .id(episode.id)
                    }
                    .onAppear {
                        proxy.scrollTo(scrollepisodeID, anchor: .center)
                    }
                    .onChange(of: show.id) { _, _ in
                        if myshow.episodes.isEmpty { return }
                        scrollepisodeID = myshow.episodes.first!.id
                        proxy.scrollTo(scrollepisodeID, anchor: .center)
                    }
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
            refreshShowDetails()
        }
        .onChange(of: myshow.id) { _, _ in
            refreshShowDetails()
        }
        .onDisappear {
            myshowsmodel.saveMy()
        }
        .padding()
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
            print(error.localizedDescription)
            self.error = error.localizedDescription
        }
    }
    private func refreshShowDetails() {
        Task {
            await loadShows(query: myshow.id)
        }
        apollo = myshow.Apollo
        kodi = myshow.Kodi
        watching = myshow.Watching
        comments = myshow.comments ?? ""
        if myshow.episodes.count > 0 {
            scrollepisodeID = myshow.episodes[0].id
        }
    }
}

#Preview {
    ShowDetailView(myshow: MyShow())
        .environmentObject(MyShowsModel())
}

