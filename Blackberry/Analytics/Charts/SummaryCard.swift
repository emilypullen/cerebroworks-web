import SwiftUI

struct AnalyticsSummaryCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(AppFonts.sectionLabel)
                .foregroundColor(.secondary)

            Text(value)
                .font(.title2.bold())
                .foregroundColor(AppColors.text)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1))
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal)
    }
}

