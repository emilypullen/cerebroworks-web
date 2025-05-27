import SwiftUI

/// A simplified, color‑coded block view showing job name and time range.
struct EntryBlockViewSimple: View {
    var block: TimeBlock
    var jobColorMap: [String: String]
    var onTap: (() -> Void)? = nil  // Optional tap callback

    private let calendar = Calendar.current

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Job title badge
            Text(block.job.isEmpty ? "Add Job" : block.job)
                .font(.caption.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 6)
                .padding(.vertical, 4)
                .background(color)
                .clipShape(Capsule())

            Spacer()

            // Time range label at bottom
            Text(timeRange)
                .font(.caption2)
                .foregroundColor(.white)
                .padding(.horizontal, 6)

            Spacer(minLength: 4)
        }
        .padding(4)
        .frame(width: 120, height: blockHeight)
        .background(color.opacity(0.6))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.2), radius: 3, x: 0, y: 2)
        .onTapGesture { onTap?() }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(block.job) from \(formatted(block.start)) to \(formatted(block.end))")
    }

    // MARK: - Computed Properties

    private var color: Color {
        Color(jobColorMap[block.job] ?? "color1")
    }

    private var blockHeight: CGFloat {
        let minutes = block.end.timeIntervalSince(block.start) / 60
        return max(CGFloat(minutes), 40)
    }

    private var timeRange: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return "\(fmt.string(from: block.start)) – \(fmt.string(from: block.end))"
    }

    private func formatted(_ date: Date) -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "h:mm a"
        return fmt.string(from: date)
    }
}
