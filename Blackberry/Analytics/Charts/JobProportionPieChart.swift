import SwiftUI
import Charts

struct JobProportionPieChart: View {
    let jobSummaries: [JobSummary]
    let colorForJob: (String) -> Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title + subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Job Time Proportions")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("A breakdown of your time across jobs.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Donut Chart
            ZStack {
                Chart {
                    ForEach(jobSummaries, id: \.job) { item in
                        SectorMark(
                            angle: .value("Time", item.totalHours),
                            innerRadius: .ratio(0.55),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Job", item.job))
                        .cornerRadius(3)
                    }
                }
                .frame(height: 240)
                .padding(.horizontal, 12)
                .chartForegroundStyleScale(
                    domain: jobSummaries.map { $0.job },
                    range: jobSummaries.map { colorForJob($0.job) }
                )
                .chartLegend(.hidden)

                // Center label (most time spent job)
                if let topJob = jobSummaries.max(by: { $0.totalHours < $1.totalHours }) {
                    VStack(spacing: 4) {
                        Text(topJob.job)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .multilineTextAlignment(.center)
                            .lineLimit(1)
                        Text(String(format: "%.1f hrs", topJob.totalHours))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // Custom Legend
            VStack(alignment: .leading, spacing: 6) {
                ForEach(jobSummaries, id: \.job) { item in
                    HStack {
                        Circle()
                            .fill(colorForJob(item.job))
                            .frame(width: 10, height: 10)
                        Text(item.job)
                            .font(.caption)
                            .lineLimit(1)
                            .truncationMode(.tail)
                        Spacer()
                        Text(String(format: "%.1f hrs", item.totalHours))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
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

