import SwiftUI
import Charts

struct MonthlyBarChart: View {
    let dailyData: [DaySummary]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title & subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Hours by Day")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("Track your total hours across the month.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Bar Chart
            Chart(dailyData) { item in
                BarMark(
                    x: .value("Day", item.day),
                    y: .value("Hours", item.hours)
                )
                .foregroundStyle(AppColors.primary.gradient)
                .cornerRadius(4)
                .annotation(position: .top) {
                    Text(String(format: "%.1f", item.hours))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel {
                        if let val = value.as(Double.self) {
                            Text(String(format: "%.0f", val))
                        }
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 12)

            // Axis captions
            HStack {
                Text("Day of Month")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Hours Worked")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

