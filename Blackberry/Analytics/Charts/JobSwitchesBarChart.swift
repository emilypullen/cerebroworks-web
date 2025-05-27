import SwiftUI
import Charts

struct JobSwitchesBarChart: View {
    let data: [DailyValue]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Job Switching Frequency")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("How often you switched between jobs this week.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Chart
            Chart {
                ForEach(data) { item in
                    BarMark(
                        x: .value("Day", item.day), // Use Date here
                        y: .value("Switches", item.value)
                    )
                    .foregroundStyle(AppColors.warning.gradient)
                    .cornerRadius(4)
                    .annotation(position: .top) {
                        Text("\(item.value)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) { value in
                    AxisValueLabel {
                        if let date = value.as(Date.self) {
                            Text(weekdayAbbreviation(from: date))
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel()
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 12)

            // Axis legend row
            HStack {
                Text("Day of Week")
                Spacer()
                Text("Job Switches")
            }
            .font(.caption2)
            .foregroundColor(.secondary)
            .padding(.horizontal, 12)
            .padding(.bottom, 4)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    // MARK: - Weekday Label Helper
    private func weekdayAbbreviation(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // "Mon", "Tue", etc.
        return formatter.string(from: date)
    }
}
