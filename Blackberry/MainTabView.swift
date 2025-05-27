import SwiftUI

enum Tab: Hashable {
    case home, logistics, entries, calendar, idle
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @AppStorage("isProUser") private var isProUser: Bool = false

    // App-wide states
    @State private var tasks: [UserTask] = []
    @State private var isRecording: Bool = false
    @State private var isOnBreak: Bool = false
    @State private var breakStartTime: Date? = nil
    @State private var breakDuration: TimeInterval = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            
            HomeTabView(
                tasks: $tasks,
                isRecording: $isRecording,
                isOnBreak: $isOnBreak,
                breakStartTime: $breakStartTime,
                breakDuration: $breakDuration,
                selectedTab: $selectedTab
            )
            .tag(Tab.home)
            .tabItem {
                Label("Home", systemImage: "house")
            }

            CalendarTabView(selectedTab: $selectedTab)
                .tag(Tab.calendar)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            EntriesTabView(selectedTab: $selectedTab)
                .tag(Tab.entries)
                .tabItem {
                    Label("Entries", systemImage: "list.bullet.rectangle")
                }

            AnalyticsContainerView()
                .tag(Tab.logistics)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar")
                }

            if isProUser {
                IdleTabView()
                    .tag(Tab.idle)
                    .tabItem {
                        Label("Recharge", systemImage: "leaf.circle.fill")
                    }
            }
        }
        .tint(AppColors.primary)
    }
}

