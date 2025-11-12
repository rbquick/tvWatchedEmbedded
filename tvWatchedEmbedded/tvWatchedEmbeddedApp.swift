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
            }
            .environment(\.selectedTab, $selectedTab)
            .environment(\.selectedShowID, $selectedShowID)
        }
        .environmentObject(myshowsmodel)
    }
}
