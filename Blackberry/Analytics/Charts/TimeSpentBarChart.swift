import SwiftUI
import Charts

struct TimeSpentBarChart: View {
    let jobSummaries: [JobSummary]
    let colorForJob: (String) -> Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Time Spent by Job")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("Compare how much time you spent on each job.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Chart
            Chart(jobSummaries, id: \.job) { item in
                BarMark(
                    x: .value("Job", item.job),
                    y: .value("Hours", item.totalHours)
                )
                .cornerRadius(4)
                .foregroundStyle(colorForJob(item.job))
                .annotation(position: .top) {
                    Text(String(format: "%.1f", item.totalHours))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .chartXAxis {
                AxisMarks(position: .bottom) {
                    AxisValueLabel()
                }
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

            // Axis label hint
            HStack {
                Text("Jobs")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                Spacer()
                Text("Hours Worked")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}

