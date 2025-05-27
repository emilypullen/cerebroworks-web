import SwiftUI
import Charts
import CoreData

struct LogisticsMainPage: View {
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var jobColorMap: [String: String] = [:]

    @FetchRequest private var todayEntries: FetchedResults<EntryData>

    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        _todayEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \EntryData.date, ascending: true)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate),
            animation: .default
        )
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    // MARK: - Title Section
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Analytics")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.secondary)

                            Text("Your work trends and stats")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -4) // pulls the cards closer visually


                    // MARK: - Summary Cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            summaryCard(
                                title: "Time You’ve Logged",
                                value: String(format: "%.1f hrs", viewModel.totalHours(from: Array(todayEntries))),
                                color: Color("CamelCoat")
                            )
                            summaryCard(
                                title: "Time You Took a Breather",
                                value: "\(viewModel.breakMinutes(from: Array(todayEntries))) min",
                                color: Color("CeramicMug")
                            )
                        }

                        summaryCard(
                            title: "Tasks You Knocked Out",
                            value: "\(viewModel.completedTasks(from: Array(todayEntries)))",
                            color: Color("Cranberry")
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // MARK: - Charts Section
                    VStack(spacing: 32) {
                        TimeSpentBarChart(
                            jobSummaries: viewModel.jobSummaries,
                            colorForJob: { jobName in
                                Color(jobColorMap[jobName] ?? "color1")
                            }
                        )

                        JobProportionPieChart(
                            jobSummaries: viewModel.jobSummaries,
                            colorForJob: { jobName in
                                Color(jobColorMap[jobName] ?? "color1")
                            }
                        )

                        WeekendWorkChart(weekendCount: computeWeekendWorkdays())
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer(minLength: 60)
                }
            }
            .background(AppTheme.current.backgroundView)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.computeHoursByJob(from: Array(todayEntries))
                jobColorMap = JobColors.shared.loadColorNames()
            }
        }
    }

    // MARK: - Summary Card
    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                    .accessibilityLabel(Text(title))
            }

            Text(value)
                .font(.title.bold().monospacedDigit())
                .foregroundColor(.white)
                .accessibilityLabel(Text("Value: \(value)"))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4) // updated here
    }

    // MARK: - Helpers
    private func computeWeekendWorkdays() -> Int {
        let allEntries = Array(todayEntries)
        let calendar = Calendar.current

        return allEntries.filter { entry in
            guard let date = entry.date,
                  let start = entry.startTime,
                  let end = entry.endTime else { return false }

            let weekday = calendar.component(.weekday, from: date)
            let duration = end.timeIntervalSince(start)
            return (weekday == 1 || weekday == 7) && duration > 0
        }.count
    }
}
