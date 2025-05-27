import SwiftUI

struct WeeklyRechargeProgressCardView: View {
    var totalHours: Double
    var goalHours: Double = 10

    var progressFraction: Double {
        min(totalHours / goalHours, 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("🌿")
                    .font(.system(size: 28))

                VStack(alignment: .leading, spacing: 4) {
                    Text(String(format: "%.1f / %.0f hours recharged this week", totalHours, goalHours))
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)

                    ProgressView(value: progressFraction)
                        .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
                }
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
        .padding(.horizontal, 20)
    }
}
