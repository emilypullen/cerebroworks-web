// MARK: - Recharge Insights Card
import SwiftUI

struct RechargeInsightsCardView: View {
    let tagSummaries: [TagSummary]
    let topDay: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tag Leaderboard")
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            ForEach(tagSummaries) { summary in
                HStack {
                    Text(summary.tag.capitalized)
                    Spacer()
                    Text("\(String(format: "%.1f", summary.hours)) hrs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            if let top = tagSummaries.first {
                Text("🧘 You spent the most time on **\(top.tag.capitalized)** this week — \(String(format: "%.1f", top.hours)) hrs.")
            }

            if let topDay = topDay {
                Text("📅 Your most restful day was **\(topDay)**.")
            }

            if tagSummaries.count > 1 {
                let least = tagSummaries.last!
                Text("💡 Consider making time for **\(least.tag.capitalized)** — only \(String(format: "%.1f", least.hours)) hrs logged.")
            }
        }
        .font(.subheadline)
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.horizontal, AppSpacing.section)
    }
}
