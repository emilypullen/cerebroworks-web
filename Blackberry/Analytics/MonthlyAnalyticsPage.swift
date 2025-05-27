import SwiftUI
import CoreData

struct MonthlyAnalyticsPage: View {
    @AppStorage("isProUser") private var isProUser: Bool = false
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \EntryData.date, ascending: true)],
        predicate: MonthlyAnalyticsPage.monthPredicate(),
        animation: .default
    ) private var monthEntries: FetchedResults<EntryData>

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \MonthlyReflection.refDate, ascending: true)],
        animation: .default
    ) private var reflections: FetchedResults<MonthlyReflection>

    @StateObject private var viewModel = AnalyticsViewModel()

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {

                    // MARK: - Title Section
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Monthly Analytics")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.secondary)

                            Text("Your monthly insights")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -4)

                    if monthEntries.isEmpty {
                        Spacer()
                        Text("No data available for this month.")
                            .foregroundColor(.secondary)
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 100)
                        Spacer()
                    } else {
                        // MARK: - Reflection Card
                        ReflectionAnalyticsCard()
                            .padding(.horizontal, 20)
                            .padding(.top, 12)

                        // MARK: - Mood Trends
                        VStack {
                            if isProUser {
                                MoodTrendsChart(reflections: Array(reflections))
                            } else {
                                ZStack {
                                    MoodTrendsChart(reflections: Array(reflections))
                                        .blur(radius: 6)
                                        .overlay(Color.white.opacity(0.3))

                                    VStack(spacing: 8) {
                                        Image(systemName: "lock.fill")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                        Text("Upgrade to Pro to see mood trends")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)

                        // MARK: - Hourly Productivity
                        VStack {
                            if isProUser {
                                HourlyProductivityHeatmap(
                                    data: viewModel.hourlyProductivityHeatmap(from: Array(monthEntries), format: "MMM d")
                                )
                            } else {
                                ZStack {
                                    HourlyProductivityHeatmap(
                                        data: viewModel.hourlyProductivityHeatmap(from: Array(monthEntries), format: "MMM d")
                                    )
                                    .blur(radius: 6)
                                    .overlay(Color.white.opacity(0.3))

                                    VStack(spacing: 8) {
                                        Image(systemName: "lock.fill")
                                            .font(.title)
                                            .foregroundColor(.gray)
                                        Text("Upgrade to Pro to unlock hourly insights")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                }
                            }
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
        }
    }

    static func monthPredicate() -> NSPredicate {
        let calendar = Calendar.current
        let start = calendar.startOfMonth(for: Date())
        let end = calendar.date(byAdding: .month, value: 1, to: start)!
        return NSPredicate(format: "date >= %@ AND date < %@", start as NSDate, end as NSDate)
    }
}
