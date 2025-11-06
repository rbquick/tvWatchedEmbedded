//
//  ShowDetailView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct ShowDetailView: View {
    let myshow: MyShow
    @State private var apollo: Bool
    @State private var kodi: Bool
    @State var show: ShowBase = ShowBase()
    @EnvironmentObject var myshowsmodel: MyShowsModel
    
    
    @State private var error: String?
    
    init(myshow: MyShow) {
         self.myshow = myshow
         // Initialize the state from myshow property
         _apollo = State(initialValue: myshow.Apollo)
        _kodi = State(initialValue: myshow.Kodi)
     }
    
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
                VStack {
                    Text(myshow.name)
                        .font(.largeTitle)
                        .bold()
                
                HStack() {
                    Toggle(isOn: $apollo) {
                        Text(apollo ? "On Appollo" : "NOT on Appollo" )
                            .onChange(of: apollo) { oldValue, newValue in
                                myshowsmodel.updatedevice(myshowid: myshow.id, apollo: newValue, kodi: kodi)
                                print("apollo: \(apollo) kodi: \(kodi)")
                            }
                    }
                    .toggleStyle(.automatic)
                    
                    Toggle(isOn: $kodi) {
                        Text(kodi ? "On Kodi" : "NOT on Kodi")
                            .onChange(of: kodi) { oldValue, newValue in
                                myshowsmodel.updatedevice(myshowid: myshow.id, apollo: apollo, kodi: newValue)
                                print("apollo: \(apollo) Kodi: \(kodi)")
                            }
                    }
                    .toggleStyle(.automatic)
                }
                }
            }
            

            if let episodes = show.embedded?.episodes, !episodes.isEmpty {
                List(sortedEpisodes, id: \.id) { episode in
//                    VStack(alignment: .center) {
                        EpisodeDetailView(myshowid: myshow.id, episode: episode)
//                    }
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
                await loadShows(query: myshow.id)
            }
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
            self.error = error.localizedDescription
        }
    }
}

#Preview {
    ShowDetailView(myshow: MyShow())
        .environmentObject(MyShowsModel())
}
