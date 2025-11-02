//
//  ShowListView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

struct ShowListView: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    @State var  myshowname: [String] = [
        "A Man on the Inside",
        "Black Doves",
        "So Long!",
        "The Librarians: The Next Chapter"
    ]
    @State var myshownameSorted: [String] = []
    @State private var showingSearch = false
         
    var body: some View {
        NavigationView {
            List {
                ForEach(myshowsmodel.MyShows) { myshow in
                    NavigationLink(destination: ShowDetailView(myshow: myshow)) {
                        Text(myshow.name)
                    }
                }
                .onDelete(perform: myshowsmodel.delete)
            }
            .navigationTitle("Shows")
            .toolbar {
                Button("Search") {
                    showingSearch = true
                }
            }
//            .onAppear {
//                myshowsmodel.fetchMyShows()
//            }
            .sheet(isPresented: $showingSearch) {
                ShowSearchView() { foundName in
                    showingSearch = false
//                    if let foundName = foundName, !myshowname.contains(foundName) {
//                        myshowname.append(foundName)
//                        myshownameSorted = myshowname.sorted()
//                    }
                }
            }
        }
    }
}

#Preview {
    ShowListView()
}
