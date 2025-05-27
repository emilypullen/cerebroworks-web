import SwiftUI
import Charts

struct IdleVsActiveDonutChart: View {
    let data: [TimeSplit] // expects Recharge and Focus labels

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recharge vs. Focus Time")
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            Chart(data) { slice in
                SectorMark(
                    angle: .value("Hours", slice.hours),
                    innerRadius: .ratio(0.5),
                    angularInset: 1
                )
                .foregroundStyle(by: .value("Category", slice.label))
            }
            .chartLegend(position: .bottom, spacing: 12)
            .frame(height: 240)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
