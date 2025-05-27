import SwiftUI

struct CalendarTabView: View {
    @Binding var selectedTab: Tab
    
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

                Spacer()
            }
            .background(
                AppTheme.current.backgroundView
            )
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

