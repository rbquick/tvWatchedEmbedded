//
//  ShowSearchView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-30.
//

import SwiftUI

struct ShowSearchView: View {
    @State private var searchText: String = ""
    @EnvironmentObject var myshowsmodel: MyShowsModel
    var completion: (String?) -> Void
    @State var show: ShowBase = ShowBase()
    @State private var error: String?
    var body: some View {
        NavigationView {
            VStack {
                
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
                    if show.name != nil {
                        VStack {
                            Text("Show found: \(show.name ?? "Not found")")
                            if myshowsmodel.showOnFile(myshowid: show.id ?? 1) {
                                Text("Already added to list")
                                    .foregroundColor(Color.red)
                            }
                        }
                    }
                }
                TextField("Enter show name", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    Button("Search") {
                        Task {
                            await getShows(query: searchText)
                        }
                    }
                    .padding()
                    if show.name != nil {
                        Button("Use") {
                            // Simulate search logic; return searchText if found, or nil if not found
                            let found = searchText.isEmpty ? nil : searchText
                            if !myshowsmodel.showOnFile(myshowid: show.id ?? 1) {
                                let episodes: [MyEpisode] = []
                                let newshow = MyShow(id: show.id ?? 1, name: show.name ?? "wrong", episodes: episodes)
                                myshowsmodel.addShow(newshow)
                                myshowsmodel.saveMy()
                            }
                            completion(found)
                        }
                        .padding()
                    }
                    
                    Button("Cancel") {
                        completion(nil)
                    }
                    .padding()
                }
            }
            .navigationTitle("Search Shows")
        }
    }
}

#Preview {
    ShowSearchView() { foundName in
        // For preview, just print or ignore the returned string
        print("Found name: \(String(describing: foundName))")
    }
//    .frame(width: 300, height: 200) // Optional: size for visual clarity in preview
}
extension (ShowSearchView) {
    func getShows(query: String) async  {
            guard let url = URL(string: "https://api.tvmaze.com/singlesearch/shows?q=\(query)&embed=episodes") else {
                error = "Invalid URL"
                return
            }
            do {
                let (data, _) = try  await URLSession.shared.data(from: url)
                let results = try JSONDecoder().decode(ShowBase.self, from: data)
                show = results
            } catch {
                self.error = error.localizedDescription
            }
        }
}
