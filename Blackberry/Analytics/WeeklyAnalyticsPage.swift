import SwiftUI
import Charts
import CoreData
import Foundation

struct WeeklyAnalyticsPage: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest private var weekEntries: FetchedResults<EntryData>

    @StateObject private var viewModel = AnalyticsViewModel()
    @State private var jobColorMap: [String: String] = [:]

    init() {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date()))!
        let endOfWeek = calendar.date(byAdding: .day, value: 7, to: startOfWeek)!

        _weekEntries = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \EntryData.date, ascending: true)],
            predicate: NSPredicate(format: "date >= %@ AND date < %@", startOfWeek as NSDate, endOfWeek as NSDate),
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
                            Text("Weekly Analytics")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.secondary)

                            Text("Your work trends this week")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -4)

                    if weekEntries.isEmpty {
                        Spacer()
                        Text("No data available for this week.")
                            .foregroundColor(.secondary)
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        Spacer()
                    } else {
                        // MARK: - Summary Cards
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                summaryCard(
                                    title: "Time You’ve Logged",
                                    value: String(format: "%.1f hrs", viewModel.totalHours(from: Array(weekEntries))),
                                    color: Color("CamelCoat")
                                )

                                summaryCard(
                                    title: "Avg. Daily Hours",
                                    value: String(format: "%.1f hrs", viewModel.totalHours(from: Array(weekEntries)) / 7.0),
                                    color: Color("CeramicMug")
                                )
                            }

                            summaryCard(
                                title: "Tasks You Knocked Out",
                                value: "\(viewModel.completedTasks(from: Array(weekEntries)))",
                                color: Color("Cranberry")
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // MARK: - Charts
                        VStack(spacing: 32) {
                            WeeklyBarChart(
                                dailyData: viewModel.hoursPerDay(from: Array(weekEntries), format: "EEE"),
                                color: AppColors.accent
                            )

                            JobProportionPieChart(
                                jobSummaries: viewModel.jobSummaries,
                                colorForJob: colorForJob
                            )

                            HourlyProductivityHeatmap(
                                data: viewModel.hourlyProductivityHeatmap(from: Array(weekEntries))
                            )

                            JobSwitchesBarChart(
                                data: viewModel.jobSwitchesPerDay(from: Array(weekEntries))
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 16)
                    }

                    Spacer(minLength: 60)
                }
            }
            .background(AppTheme.current.backgroundView)
            .navigationTitle("Analytics")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.jobSummaries = viewModel.generateJobSummaries(from: Array(weekEntries))
                jobColorMap = JobColors.shared.loadColorNames()
            }
            .onChange(of: weekEntries.map { $0.objectID }) { _, _ in
                viewModel.jobSummaries = viewModel.generateJobSummaries(from: Array(weekEntries))
            }
        }
    }

    // MARK: - Summary Card
    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .accessibilityLabel(Text(title))

            Text(value)
                .font(.title.bold().monospacedDigit())
                .foregroundColor(.white)
                .accessibilityLabel(Text("Value: \(value)"))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
    }

    // MARK: - Color Mapping
    private func colorForJob(_ job: String) -> Color {
        Color(jobColorMap[job] ?? "color1")
    }
}

