import SwiftUI
import CoreData

struct MonthCalendarView: View {
    @Binding var currentDate: Date
    @Binding var selectedView: CalendarViewType

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EntryData.date, ascending: true)],
        animation: .default
    ) private var allEntries: FetchedResults<EntryData>

    @State private var monthEntries: [Date: [EntryData]] = [:]
    @State private var jobColorMap: [String: String] = [:]

    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    private let calendar = Calendar.current

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    monthHeader
                    weekdayHeaders
                    datesGrid
                    monthSummary
                    monthFooter
                }
                .padding()
                .background(AppColors.background.opacity(0.3)) // ✅ themed but container-safe
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)

                if calendar.isDate(currentDate, equalTo: Date(), toGranularity: .month) {
                    MonthlyExtrasView()
                        .padding(.top, 16)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .background(AppTheme.current.backgroundView) // ✅ full background view
        .ignoresSafeArea(.container, edges: .bottom)
        .onAppear { loadData() }
        .onChange(of: currentDate) { _ in loadData() }
        .onChange(of: allEntries.map { $0.objectID }) { _ in loadData() }
    }

    // MARK: - Header
    private var monthHeader: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(AppTheme.current.primary)
            }
            Spacer()
            Text(monthTitle)
                .font(.title3.weight(.semibold))
                .foregroundColor(AppTheme.current.primary)
            Spacer()
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(AppTheme.current.primary)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal)
        .background(AppColors.background.opacity(0.2)) // ✅ match with rest of container themes
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Weekday Labels
    private var weekdayHeaders: some View {
        let symbols = calendar.shortWeekdaySymbols
        let start = calendar.firstWeekday - 1
        let ordered = Array(symbols[start..<symbols.count] + symbols[0..<start])

        return LazyVGrid(columns: columns, spacing: 8) {
            ForEach(ordered, id: \.self) { day in
                Text(day)
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: - Dates Grid
    private var datesGrid: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(generateDates(), id: \.self) { date in
                dateCell(for: date)
            }
        }
    }

    private func dateCell(for date: Date) -> some View {
        let startOfDay = calendar.startOfDay(for: date)
        let entries = monthEntries[startOfDay] ?? []
        let isCurrentMonth = calendar.isDate(date, equalTo: currentDate, toGranularity: .month)
        let isSelected = calendar.isDate(date, equalTo: currentDate, toGranularity: .day)
        let isToday = calendar.isDateInToday(date)

        return Button(action: {
            withAnimation(.spring()) {
                currentDate = date
                selectedView = .day
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if isSelected {
                        Circle()
                            .fill(AppTheme.current.primary)
                            .frame(width: 36, height: 36)
                    } else if isToday {
                        Circle()
                            .stroke(AppTheme.current.primary, lineWidth: 1.5)
                            .frame(width: 36, height: 36)
                    }
                    Text("\(calendar.component(.day, from: date))")
                        .font(.body)
                        .foregroundColor(isSelected ? .white : (isCurrentMonth ? AppColors.secondary : .gray))
                }
                entryIndicators(entries)
            }
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel(Text("\(calendar.component(.day, from: date)) entries: \(entries.count)"))
    }

    private func entryIndicators(_ entries: [EntryData]) -> some View {
        HStack(spacing: 3) {
            ForEach(entries.prefix(3), id: \.self) { entry in
                Circle()
                    .fill(Color(jobColorMap[entry.job ?? ""] ?? "SteelBlue"))
                    .frame(width: 6, height: 6)
            }
            if entries.count > 3 {
                Text("+\(entries.count - 3)")
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }

    // MARK: - Month Summary
    private var monthSummary: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Activity Breakdown")
                .font(.caption.bold())
                .foregroundColor(AppColors.secondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(jobCounts, id: \.job) { item in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(jobColorMap[item.job] ?? "SteelBlue"))
                                .frame(width: 8, height: 8)
                            Text("\(item.job): \(item.count)")
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(AppColors.background.opacity(0.4)) // ✅ consistent container style
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal)
    }

    private var jobCounts: [(job: String, count: Int)] {
        let all = monthEntries.values.flatMap { $0 }
        let dict = Dictionary(grouping: all, by: { $0.job ?? "Unknown" })
            .mapValues { $0.count }
        return dict.sorted { $0.value > $1.value }
            .map { (job: $0.key, count: $0.value) }
    }

    // MARK: - Footer
    private var monthFooter: some View {
        HStack {
            Text("Total Entries: \(monthEntries.values.flatMap { $0 }.count)")
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
        }
    }

    // MARK: - Helpers
    private var monthTitle: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "LLLL yyyy"
        return fmt.string(from: currentDate)
    }

    private func generateDates() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentDate),
              let firstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        var dates: [Date] = []
        var current = firstWeek.start
        while current <= calendar.date(byAdding: .day, value: 41, to: firstWeek.start)! {
            dates.append(current)
            current = calendar.date(byAdding: .day, value: 1, to: current)!
        }
        return dates
    }

    private func previousMonth() {
        currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
    }

    private func nextMonth() {
        currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
    }

    private func loadData() {
        var grouped: [Date: [EntryData]] = [:]
        for entry in allEntries {
            if let date = entry.date {
                let day = calendar.startOfDay(for: date)
                grouped[day, default: []].append(entry)
            }
        }
        monthEntries = grouped
        jobColorMap = JobColors.shared.loadColorNames()
    }
}

