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
    case watching = "Watching"
    var id: String { self.rawValue }
}

struct ListShowLine: View {
    let myshow: MyShow
    var body: some View {
        VStack(alignment:. leading) {
            Text(myshow.name)
            HStack {
                Spacer()
                
                Text("\(myshow.Apollo ? "Apollo" : "Kodi")")
            }
        }
    }
}

struct ShowListView: View {
    @EnvironmentObject var myshowsmodel: MyShowsModel
    @Environment(\.selectedShowID) var selectedShowID
    
    @State private var selectedShow: Int? = nil
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
            case .watching:
                sourceFiltered = myshowsmodel.MyShows.filter { $0.Watching }
        }
        if searchText.isEmpty {
            return sourceFiltered
        } else {
            return sourceFiltered.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationSplitView {
            VStack {
                Picker("Source", selection: $selectedSource) {
                    ForEach(ShowSourceFilter.allCases) { filter in
                        Text(filter.rawValue).tag(filter)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                ScrollViewReader { proxy in
                    
                    
                    List(selection: $selectedShow) {
                        ForEach(filteredShows) { myshow in
                            ListShowLine(myshow: myshow)
                                .tag(myshow.id)
                        }
                        .onDelete(perform: myshowsmodel.delete)
                    }
                    .navigationTitle("Shows")
                    .searchable(text: $searchText, prompt: "Filter shows")

                    .toolbar {
                        Button("New Shows") {
                            showingSearch = true
                        }
                    }
                    .onAppear {
                        if let selID = selectedShowID?.wrappedValue, filteredShows.contains(where: { $0.id == selID }) {
                            proxy.scrollTo(selID, anchor: .center)
                            selectedShow = selID
                        }
                    }
                    .onChange(of: selectedShowID?.wrappedValue) { _, newID in
                        if let selID = newID, filteredShows.contains(where: { $0.id == selID }) {
                            proxy.scrollTo(selID, anchor: .center)
                            selectedShow = selID
                        }
                    }

                }
            }
        } detail: {
            if let selectedShow {
                ShowDetailView(myshow: myshowsmodel.getmyshow(myshowid: selectedShow))
            } else {
                Text("Select a show")
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $showingSearch) {
            ShowSearchView() { foundName in
                showingSearch = false
            }
        }
//        .searchable(text: $searchText, prompt: "Filter shows")
    }
}

#Preview {
    ShowListView()
        .environmentObject(MyShowsModel())
}

