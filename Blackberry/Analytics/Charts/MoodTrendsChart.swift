import SwiftUI
import Charts
import CoreData

struct MoodTrendsChart: View {
    let reflections: [MonthlyReflection]
    @AppStorage("isProUser") private var isProUser: Bool = false

    private let moodScores: [String: Int] = [
        "😴": 1,
        "🙂": 2,
        "😃": 3,
        "🚀": 4
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title & subtitle
            VStack(alignment: .leading, spacing: 4) {
                Text("Mood Trends")
                    .font(AppFonts.sectionTitle)
                    .foregroundColor(AppColors.secondary)

                Text("See how your mood has shifted over the month.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)

            // Chart or fallback
            if moodData.isEmpty {
                Text("No mood data available for this month.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
            } else {
                Chart(moodData) { item in
                    LineMark(
                        x: .value("Date", item.date),
                        y: .value("Mood", item.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(AppColors.accent)
                    .symbol(Circle())
                }
                .chartYAxis {
                    AxisMarks(values: Array(1...4)) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let score = value.as(Int.self) {
                                Text(emojiForScore(score))
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(position: .bottom) {
                        AxisValueLabel(format: .dateTime.day())
                    }
                }
                .frame(height: 220)
                .padding(.horizontal, 12)

                // Summary comment
                Text(moodSummary())
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 12)
                    .italic()
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppSpacing.cardCornerRadius)
        .shadow(color: Color.black.opacity(0.06), radius: AppSpacing.shadowRadius, x: 0, y: 4)
        .padding(.horizontal, 20)
    }

    // Mood data mapping
    private var moodData: [MoodEntry] {
        reflections.compactMap { reflection in
            guard let date = reflection.refDate,
                  let emoji = reflection.refMood,
                  let score = moodScores[emoji] else { return nil }
            return MoodEntry(date: date, score: score)
        }
        .sorted { $0.date < $1.date }
    }

    // Score-to-emoji
    private func emojiForScore(_ score: Int) -> String {
        moodScores.first { $0.value == score }?.key ?? ""
    }

    // Summary generator
    private func moodSummary() -> String {
        guard moodData.count >= 3 else { return "\"You're just getting started—keep tracking your mood!\"" }

        let avg = moodData.map(\.score).reduce(0, +) / moodData.count
        switch avg {
        case 1: return "\"This month felt low-key. Hope you got some rest. 😴\""
        case 2: return "\"Mostly calm and content — a nice balance. 🙂\""
        case 3: return "\"You’ve had a pretty cheerful stretch! 😃\""
        case 4: return "\"You’re flying high — what a month! 🚀\""
        default: return "\"Steady vibes all around.\""
        }
    }

    struct MoodEntry: Identifiable {
        var id: Date { date }
        let date: Date
        let score: Int
    }
}

