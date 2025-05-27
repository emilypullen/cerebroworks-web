import SwiftUI
import Charts
import Foundation

struct WeekendWorkChart: View {
    let weekendCount: Int

    var body: some View {
        VStack(alignment: .center, spacing: 12) {
            // Sun icon
            Image(systemName: "sun.max.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(.orange)
                .padding(.top, 4)

            // Title + subtitle
            VStack(spacing: 4) {
                Text("Weekend Work")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("How often you worked on Saturdays and Sundays.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            // Summary message
            Text(workSummary)
                .font(.body)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .padding(.top, 4)
                .padding(.horizontal, 12)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    private var workSummary: String {
        switch weekendCount {
        case 0:
            return "You kept your weekends free — love the balance! ☀️"
        case 1:
            return "You worked on 1 weekend day — a light touch!"
        case 2...4:
            return "You worked on \(weekendCount) weekend days — nice consistency!"
        default:
            return "Whoa! \(weekendCount) weekend workdays — you’ve been on a roll!"
        }
    }
}

