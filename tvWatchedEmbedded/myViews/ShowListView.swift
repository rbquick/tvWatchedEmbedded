//
//  ShowListView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct ShowListView: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel

    @State private var showingSearch = false
    
    @State private var searchText: String = ""

    var filteredShows: [MyShow] {
        if searchText.isEmpty {
            return myshowsmodel.MyShows
        } else {
            return myshowsmodel.MyShows.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
         
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredShows) { myshow in
                    NavigationLink(destination: ShowDetailView(myshow: myshow)) {
                        Text(myshow.name)
                    }
                }
                .onDelete(perform: myshowsmodel.delete)
            }
            .navigationTitle("Shows")
            .toolbar {
                Button("New Shows") {
                    showingSearch = true
                }
            }
            .sheet(isPresented: $showingSearch) {
                ShowSearchView() { foundName in
                    showingSearch = false
                    // don't have to do anything here sing the ShowSearchView adds the show if found and used
                }
            }
            .searchable(text: $searchText, prompt: "Filte shows") // Adds a native search bar
        }
    }
}

#Preview {
    ShowListView()
        .environmentObject(MyShowsModel())
}
