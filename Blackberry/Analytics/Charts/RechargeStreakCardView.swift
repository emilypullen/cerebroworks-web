import SwiftUI

struct RechargeStreakCardView: View {
    var streakCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("🧘‍♀️")
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 4) {
                    Text("You've logged recharge time")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(streakCount) days in a row!")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                }
            }

            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("Keep your streak alive!")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 4)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.03), radius: 1, x: 0, y: 1)
        .padding(.horizontal, 20)
    }
}
