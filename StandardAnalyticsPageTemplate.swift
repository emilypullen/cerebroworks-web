import SwiftUI
import Charts
import CoreData

struct StandardAnalyticsPageTemplate: View {
    var title: String = "Section Title"
    var subtitle: String = "Optional descriptive text here."

    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 32) {
                    
                    // MARK: - Title Section
                    HStack {
                        VStack(alignment: .leading, spacing: 1) {
                            Text(title)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(AppColors.secondary)

                            Text(subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    .padding(.horizontal, 20)
                    .padding(.bottom, -4)

                    // MARK: - Summary Cards
                    VStack(spacing: 16) {
                        HStack(spacing: 16) {
                            summaryCard(
                                title: "Example Metric A",
                                value: "10.5 hrs",
                                color: Color("CamelCoat")
                            )
                            summaryCard(
                                title: "Example Metric B",
                                value: "25 min",
                                color: Color("CeramicMug")
                            )
                        }

                        summaryCard(
                            title: "Single Metric Card",
                            value: "12 tasks",
                            color: Color("Cranberry")
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)

                    // MARK: - Example Charts
                    VStack(spacing: 32) {
                        sampleChart(title: "Time Allocation Example")

                        sampleChart(title: "Daily Breakdown")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                    Spacer(minLength: 60)
                }
            }
            .background(AppTheme.current.backgroundView)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Reusable Card
    private func summaryCard(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)

            Text(value)
                .font(.title.bold().monospacedDigit())
                .foregroundColor(.white)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(color)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 6, x: 0, y: 4)
    }

    // MARK: - Reusable Placeholder Chart
    private func sampleChart(title: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(AppFonts.sectionTitle)
                .foregroundColor(AppColors.secondary)

            Chart {
                BarMark(x: .value("Label", "Example"), y: .value("Value", 10))
                BarMark(x: .value("Label", "Placeholder"), y: .value("Value", 5))
            }
            .frame(height: 200)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}
