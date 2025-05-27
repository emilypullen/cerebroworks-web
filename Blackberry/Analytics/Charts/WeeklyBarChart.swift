import SwiftUI
import Charts

struct WeeklyBarChart: View {
    let dailyData: [DaySummary]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Total Hours by Day")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("A snapshot of your weekly workload.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Bar Chart
            Chart {
                ForEach(dailyData, id: \.day) { item in
                    BarMark(
                        x: .value("Day", item.day),
                        y: .value("Hours", item.hours)
                    )
                    .foregroundStyle(color.gradient)
                    .cornerRadius(4)
                    .annotation(position: .top) {
                        Text(String(format: "%.1f", item.hours))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisValueLabel() {
                        if let doubleValue = value.as(Double.self) {
                            Text("\(Int(doubleValue))")
                        }
                    }
                }
            }
            .frame(height: 220)
            .padding(.horizontal, 12)

            // Axis legend row
            HStack {
                Text("Day of Week")
                Spacer()
                Text("Hours Worked")
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
}

