//
//  tvWatchedEmbeddedApp.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI

@main
struct tvWatchedEmbeddedApp: App {
    @StateObject var myshowsmodel: MyShowsModel = MyShowsModel()
    var body: some Scene {
        WindowGroup {
            TabView {
                ShowListView()
                    .tabItem {
                        Label("Shows", systemImage: "list.bullet")
                    }
                MyCalendarView()
                    .tabItem {
                        Label("Calendar", systemImage: "calendar")
                    }
            }
        }
        .environmentObject(myshowsmodel)
    }
}
