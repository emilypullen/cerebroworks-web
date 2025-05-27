import SwiftUI
import Charts

struct RechargeTagPieChart: View {
    let tagSummaries: [TagSummary]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.element) {
            Text("Time Spent by Tag")
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            Chart(tagSummaries) { summary in
                SectorMark(
                    angle: .value("Hours", summary.hours),
                    innerRadius: .ratio(0.5),
                    angularInset: 1
                )
                .foregroundStyle(tagColor(for: summary.tag))
                .annotation(position: .overlay) {
                    Text(summary.tag)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
            .frame(height: 200) // Adjusted to match the height used across your app
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        .padding(.horizontal, AppSpacing.section)
    }

    private func tagColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "rest": return .blue
        case "social": return .green
        case "creative": return .purple
        case "outdoors": return .teal
        case "focus": return .orange
        case "other": return .gray
        default: return .gray
        }
    }
}
