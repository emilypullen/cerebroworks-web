import SwiftUI
import Charts

struct HourlyProductivityHeatmap: View {
    let data: [HourlyTaskData]
    private let displayedHours: [Int] = [0, 6, 12, 18, 24]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + Subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Hourly Productivity")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("See when you’re most active throughout the week.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Chart
            Chart {
                ForEach(data) { item in
                    RectangleMark(
                        x: .value("Hour", item.hour),
                        y: .value("Day", item.day),
                        width: .automatic,
                        height: .automatic
                    )
                    .cornerRadius(4)
                    .foregroundStyle(by: .value("Tasks", item.taskCount))
                }
            }
            .chartXAxis {
                AxisMarks(values: displayedHours) { value in
                    AxisValueLabel {
                        if let hour = value.as(Int.self) {
                            let label = hour == 0 ? "12 AM"
                                : hour < 12 ? "\(hour) AM"
                                : hour == 12 ? "12 PM"
                                : "\(hour - 12) PM"
                            Text(label)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading)
            }
            .chartLegend(.hidden)
            .chartPlotStyle { plotArea in
                plotArea
                    .background(Color("ChartGridBackground"))
                    .cornerRadius(12)
            }
            .frame(height: 300)
            .padding(.horizontal, 12)

            // Chart Summary
            Text(heatmapSummary())
                .font(.footnote)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.top, 4)
                .italic()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    // MARK: - Day Formatter
    private func weekdayAbbreviation(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, etc.
        return formatter.string(from: date)
    }

    // MARK: - Summary Generator
    private func heatmapSummary() -> String {
        let hourGroups = Dictionary(grouping: data) { $0.hour }
        let hourSums = hourGroups.mapValues { $0.reduce(0) { $0 + $1.taskCount } }

        guard let peakHour = hourSums.max(by: { $0.value < $1.value })?.key else {
            return "\"Let’s see when you start lighting things up!\""
        }

        switch peakHour {
        case 6...9:
            return "\"You’re an early bird — mornings are your power hours!\""
        case 10...13:
            return "\"Midday momentum is your thing — keep riding the wave!\""
        case 14...17:
            return "\"Afternoon hustle detected. You thrive after lunch!\""
        case 18...21:
            return "\"Evenings look strong — maybe you’re a quiet-hour worker?\""
        case 22...24, 0...5:
            return "\"You’ve got night owl energy — productivity after dark!\""
        default:
            return "\"You're getting things done at your own pace — love that for you!\""
        }
    }
}

