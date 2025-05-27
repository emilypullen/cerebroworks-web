import SwiftUI

enum CalendarViewType: String, CaseIterable {
    case month = "Month"
    case day = "Day"
}

struct CalendarContainerView: View {
    // Bind to the app's TabView selection so DayCalendarView can switch tabs
    @Binding var selectedTab: Tab

    // Toggle between Month and Day calendar layouts
    @State private var selectedView: CalendarViewType = .month
    @State private var currentDate: Date = Date()

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // MARK: - View Selector
                Picker("View Type", selection: $selectedView) {
                    ForEach(CalendarViewType.allCases, id: \.self) { viewType in
                        Text(viewType.rawValue).tag(viewType)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                // MARK: - Calendar Content
                Group {
                    switch selectedView {
                    case .month:
                        MonthCalendarView(
                            currentDate: $currentDate,
                            selectedView: $selectedView
                        )
                    case .day:
                        DayCalendarView(
                            currentDate: $currentDate,
                            selectedTab: $selectedTab
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()  // allow content to push up
            }
            .background(
                AppTheme.current.backgroundView
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
