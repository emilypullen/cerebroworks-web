import SwiftUI
import Charts
import CoreData

// MARK: - TagSummary Model
struct TagSummary: Identifiable {
    let id = UUID()
    let tag: String
    let hours: Double
}

struct IdleTabView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        entity: NonWorkActivity.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \NonWorkActivity.nonWorkDate, ascending: false)],
        animation: .default
    ) private var idleEntries: FetchedResults<NonWorkActivity>

    @State private var showEditor = false

    var isProUser: Bool {
        return true // Replace with actual logic
    }

    var body: some View {
        NavigationView {
            if isProUser {
                proContent
                    .background(AppTheme.current.backgroundView.ignoresSafeArea())
                    .navigationTitle("Recharge")
                    .navigationBarTitleDisplayMode(.inline)
            } else {
                RechargeLockedView()
            }
        }
    }

    private var proContent: some View {
        let tagSummaries = tagSummaryData()

        return ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.section) {

                // MARK: - Header
                VStack(alignment: .leading, spacing: AppSpacing.element) {
                    Text("Recharge Tracker")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.secondary)

                    Text("Track, analyze, and reflect on how you recharge.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 8)
                .padding(.horizontal, AppSpacing.section)

                // MARK: - Streak
                if streakCount(from: Array(idleEntries)) > 1 {
                    RechargeStreakCardView(streakCount: streakCount(from: Array(idleEntries)))
                        .padding(.horizontal, AppSpacing.section)
                }

                // MARK: - Weekly Summary
                WeeklyRechargeProgressCardView(totalHours: weeklyRechargeTotal(from: Array(idleEntries)))
                    .padding(.horizontal, AppSpacing.section)

                // MARK: - Charts
                if tagSummaries.total > 0 {
                    VStack(spacing: AppSpacing.section) {
                        summaryChartCard(title: "Focus vs Recharge") {
                            IdleVsActiveDonutChart(data: idleSummaryData(from: Array(idleEntries)))
                                .frame(height: 200)
                        }

                        RechargeTagPieChart(tagSummaries: tagSummaries.summaries)
                    }
                }

                // MARK: - Insights
                if tagSummaries.total > 0 {
                    RechargeInsightsCardView(tagSummaries: tagSummaries.summaries, topDay: topRechargeDay())
                }

                // MARK: - Add Entry
                Button(action: {
                    showEditor = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("Log Recharge Time")
                            .font(.body)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.accent.opacity(0.15))
                    .cornerRadius(12)
                }
                .padding(.horizontal, AppSpacing.section)
                .sheet(isPresented: $showEditor) {
                    IdleTimeEditorView()
                        .environment(\.managedObjectContext, viewContext)
                }

                // MARK: - Recent Activities
                VStack(alignment: .leading, spacing: 16) {
                    Text("Recent Recharge Activities")
                        .font(AppFonts.sectionTitle)
                        .foregroundColor(AppColors.secondary)
                        .padding(.horizontal, AppSpacing.section)

                    if idleEntries.isEmpty {
                        Text("No entries yet.")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, AppSpacing.section)
                    } else {
                        ForEach(idleEntries.prefix(5)) { entry in
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(TagColors.color(for: entry.nonWorkTag ?? "other"))
                                            .frame(width: 8, height: 8)
                                        Text(entry.nonWorkLabel ?? "Unlabeled")
                                            .font(.subheadline)
                                    }
                                    if let date = entry.nonWorkDate {
                                        Text(date, style: .date)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }

                                Spacer()

                                Text("\(String(format: "%.1f", entry.nonWorkHours)) hrs")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(AppColors.cardBackground)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
                            .padding(.horizontal, AppSpacing.section)
                        }
                    }
                }

                Spacer(minLength: 60)
            }
        }
    }

    // MARK: - Reusable Chart Card
    private func summaryChartCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.element) {
            Text(title)
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            content()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.horizontal, AppSpacing.section)
    }

    // MARK: - Helpers

    private func idleSummaryData(from entries: [NonWorkActivity]) -> [TimeSplit] {
        let total = entries.reduce(0) { $0 + $1.nonWorkHours }
        let focus = max(1.0, 40.0 - total)
        return [
            TimeSplit(label: "Recharge", hours: total),
            TimeSplit(label: "Focus", hours: focus)
        ]
    }

    private func weeklyRechargeTotal(from entries: [NonWorkActivity]) -> Double {
        let startOfWeek = Calendar.current.startOfWeek(for: Date())
        return entries
            .filter { $0.nonWorkDate ?? .distantPast >= startOfWeek }
            .reduce(0) { $0 + $1.nonWorkHours }
    }

    private func streakCount(from entries: [NonWorkActivity]) -> Int {
        guard !entries.isEmpty else { return 0 }
        let sortedDates = entries.compactMap { $0.nonWorkDate.map { Calendar.current.startOfDay(for: $0) } }
            .sorted(by: >)
        var streak = 1
        for i in 1..<sortedDates.count {
            let diff = Calendar.current.dateComponents([.day], from: sortedDates[i], to: sortedDates[i - 1]).day ?? 0
            if diff == 1 {
                streak += 1
            } else if diff > 1 {
                break
            }
        }
        return streak
    }

    private func tagSummaryData() -> (summaries: [TagSummary], total: Double) {
        let filtered = filteredEntries()
        let grouped = Dictionary(grouping: filtered, by: { $0.nonWorkTag ?? "Other" })
        let summaries = grouped.map { (tag, entries) -> TagSummary in
            let total = entries.reduce(0) { $0 + $1.nonWorkHours }
            return TagSummary(tag: tag, hours: total)
        }.sorted(by: { $0.hours > $1.hours })
        let total = summaries.reduce(0) { $0 + $1.hours }
        return (summaries, total)
    }

    private func topRechargeDay() -> String? {
        let grouped = Dictionary(grouping: filteredEntries(), by: {
            Calendar.current.component(.weekday, from: $0.nonWorkDate ?? Date())
        })
        let dayTotals = grouped.mapValues { entries in
            entries.reduce(0) { $0 + $1.nonWorkHours }
        }
        if let (weekday, _) = dayTotals.max(by: { $0.value < $1.value }) {
            return Calendar.current.weekdaySymbols[weekday - 1]
        }
        return nil
    }

    private func filteredEntries() -> [NonWorkActivity] {
        let startOfWeek = Calendar.current.startOfWeek(for: Date())
        return idleEntries.filter {
            ($0.nonWorkDate ?? .distantPast) >= startOfWeek
        }
    }
}

// MARK: - Calendar Extension
extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
}

