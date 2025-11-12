//
//  ShowListView.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI


enum ShowSourceFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case apollo = "Apollo"
    case kodi = "Kodi"
    var id: String { self.rawValue }
}

struct ShowListView: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    @Environment(\.selectedShowID) var selectedShowID

    @State private var showingShowDetailView: Int? = nil
    @State private var showingSearch = false
    
    @State private var searchText: String = ""
    
    @State private var selectedSource: ShowSourceFilter = .all

    var filteredShows: [MyShow] {
        let sourceFiltered: [MyShow]
        switch selectedSource {
        case .all:
            sourceFiltered = myshowsmodel.MyShows
        case .apollo:
            sourceFiltered = myshowsmodel.MyShows.filter { $0.Apollo }
        case .kodi:
            sourceFiltered = myshowsmodel.MyShows.filter { $0.Kodi }
        }
        if searchText.isEmpty {
            return sourceFiltered
        } else {
            return sourceFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
         
    var body: some View {
        NavigationView {
            VStack {
                Picker("Source", selection: $selectedSource) {
                                    ForEach(ShowSourceFilter.allCases) { filter in
                                        Text(filter.rawValue).tag(filter)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .padding(.horizontal)
                
                ScrollViewReader { proxy in
                    List {
                        ForEach(filteredShows) { myshow in
                            NavigationLink(
                                destination: ShowDetailView(myshow: myshow),
                                tag: myshow.id,
                                selection: $showingShowDetailView
                            )
                                {
                                                               Text(myshow.name)
                                                           }
                                    .id(myshow.id)
                        }
                        .onDelete(perform: myshowsmodel.delete)
                        
                    }  // end of list

                    .onAppear {
                        if let selID = selectedShowID?.wrappedValue, filteredShows.contains(where: { $0.id == selID }) {
                            proxy.scrollTo(selID, anchor: .center)
                            showingShowDetailView = selID
                        }
                    }
                    .onChange(of: selectedShowID?.wrappedValue) { _, newID in
                        if let selID = newID, filteredShows.contains(where: { $0.id == selID }) {
                            proxy.scrollTo(selID, anchor: .center)
                            showingShowDetailView = selID
                        }
                    }
                }  // end of ScrollViewReader
                
            }
            .navigationTitle("Shows")
            .navigationBarTitleDisplayMode(.inline)
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
            .searchable(text: $searchText, prompt: "Filter shows") // Adds a native search bar
        }
    }


}

#Preview {
    ShowListView()
        .environmentObject(MyShowsModel())
}

