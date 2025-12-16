//
//  tvWatchedEmbeddedApp.swift
//  tvWatchedEmbedded
//
//  Created by Brian Quick on 2025-10-29.
//

import SwiftUI
import Combine

struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<Int>? = nil
}

extension EnvironmentValues {
    var selectedTab: Binding<Int>? {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}

struct SelectedShowIDKey: EnvironmentKey {
    static let defaultValue: Binding<Int?>? = nil
}

extension EnvironmentValues {
    var selectedShowID: Binding<Int?>? {
        get { self[SelectedShowIDKey.self] }
        set { self[SelectedShowIDKey.self] = newValue }
    }
}

@main
struct tvWatchedEmbeddedApp: App {
    @StateObject var myshowsmodel: MyShowsModel = MyShowsModel()
    @State private var selectedTab: Int = 0
    @State private var selectedShowID: Int? = nil

    var body: some Scene {
        WindowGroup {
        if !myshowsmodel.allBaseShowsComplete {
            ProgressView("Loading shows…\(myshowsmodel.allBaseShows.count) of \(myshowsmodel.MyShows.count)")
        } else {
                TabView(selection: $selectedTab) {
                    ShowListView()
                        .tabItem {
                            Label("Shows", systemImage: "list.bullet")
                        }
                        .tag(0)
                    MyCalendarView()
                        .tabItem {
                            Label("Calendar", systemImage: "calendar")
                        }
                        .tag(1)
                    Scheduler()
                        .tabItem {
                            Label("Schedule", systemImage: "calendar.badge.plus")
                        }
                        .tag(2)
                    
                    Settings()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape")
                        }
                        .tag(3)
                }
                .environment(\.selectedTab, $selectedTab)
                .environment(\.selectedShowID, $selectedShowID)
                .environmentObject(myshowsmodel)
            }
        }
    }
}
