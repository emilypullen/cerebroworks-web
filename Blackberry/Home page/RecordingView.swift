import SwiftUI

// MARK: — Arch Shape (top-half circle)
struct Arch: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()                                                   // Create a new Path
        let center = CGPoint(x: rect.midX, y: rect.maxY)                 // Compute center at bottom middle
        let radius = rect.width / 2                                      // Radius is half the width
        p.addArc(                                                        // Add an arc from left to right
            center: center,
            radius: radius,
            startAngle: .degrees(180),
            endAngle: .degrees(0),
            clockwise: false
        )
        return p                                                        // Return the constructed path
    }
}

// MARK: — Blur View Helper
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style                                    // Blur effect style to use

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))       // Create the blur view
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        // No dynamic updates needed
    }
}

// MARK: — Session Summary Banner
struct RecordingSummaryBanner: View {
    var job: String                                                  // Job name to display
    var duration: TimeInterval                                       // Duration of session
    var date: Date                                                   // Timestamp of session end

    private var durationString: String {                             // Format duration as MM:SS
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var body: some View {
        HStack(spacing: 12) {                                        // Horizontal stack for text + spacer
            VStack(alignment: .leading, spacing: 4) {                // Text stack
                Text("Session Summary")                             // Title
                    .font(.headline)
                Text("Job: \(job)")                                 // Job line
                    .font(.subheadline)
                Text("Duration: \(durationString)")                 // Duration line
                    .font(.subheadline)
                Text(date, style: .time)                            // Time of session
                    .font(.caption)
            }
            Spacer()                                                 // Push content to leading edge
        }
        .padding()                                                   // Inner padding
        .background(BlurView(style: .systemMaterial))               // Blur background
        .cornerRadius(12)                                           // Rounded corners
        .shadow(radius: 5)                                          // Drop shadow
        .padding(.horizontal)                                       // Horizontal outer padding
    }
}

// MARK: — Recording View (Top-Arc Timer)
struct RecordingView: View {
    @Binding var isRecording: Bool                                  // Are we recording now?
    @Binding var isOnBreak: Bool                                     // Are we on break?
    @Binding var elapsedTime: TimeInterval                           // Elapsed work time
    var jobList: [String]                                            // List of available jobs
    @Binding var selectedJob: String                                 // Currently selected job
    var startAction: () -> Void                                      // Callback to start recording
    var pauseAction: () -> Void                                      // Callback to pause
    var resumeAction: () -> Void                                     // Callback to resume
    var stopAction: () -> Void                                       // Callback to stop & create entry

    @State private var showSummaryBanner = false                     // Flag to show summary

    private var timeString: String {                                 // Format elapsedTime
        let m = Int(elapsedTime) / 60
        let s = Int(elapsedTime) % 60
        return String(format: "%02d:%02d", m, s)
    }

    var body: some View {
        ZStack {                                                      // Overlay banner on top
            // MAIN CONTENT
            VStack(spacing: 16) {                                      // 16pt between items
                // Job pills
                HStack(spacing: 8) {
                    ForEach(jobList, id: \.self) { job in
                        Button {
                            // Deselect if tapping the currently selected job
                            selectedJob = (selectedJob == job ? "" : job)
                        } label: {
                            Text(job)                            // Job label
                                .font(.subheadline)             // Larger font
                                .padding(.vertical, 6)          // Vertical padding
                                .padding(.horizontal, 12)       // Horizontal padding
                                .background(selectedJob == job
                                    ? Color.blue
                                    : Color.gray.opacity(0.2)) // Background color
                                .foregroundColor(selectedJob == job ? .white : .primary)
                                .clipShape(Capsule())          // Capsule shape
                        }
                    }
                }

                // Arch + timer display
                ZStack {
                    Arch()                                        // Background arch
                        .stroke(Color.blue.opacity(0.3), lineWidth: 10)
                    Arch()                                        // Progress arc
                        .trim(from: 0, to: min(elapsedTime / 3600, 1))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .foregroundColor(.blue)
                    Text(timeString)                             // Timer text
                        .font(.system(size: 40, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .offset(y: 40)                          // Align base with arc
                }
                .frame(width: 200, height: 120)                   // Fixed size

                // Controls: Play/Pause + Stop
                HStack(spacing: 24) {                              // 24pt between buttons
                    // Play ↔ Pause toggle
                    Button(action: {
                        if isRecording {
                            pauseAction()                         // Pause if recording
                        } else {
                            startAction()                         // Start if not recording
                        }
                    }) {
                        Image(systemName: isRecording ? "pause.fill" : "play.fill")
                            .font(.title2)                       // Icon size
                            .frame(width: 50, height: 50)        // Tap area
                            .background(Color.blue)             // Button background
                            .foregroundColor(.white)            // Icon color
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Stop (always visible)
                    Button(action: {
                        stopAction()                              // Stop & trigger new entry
                        withAnimation { showSummaryBanner = true }
                    }) {
                        Image(systemName: "stop.fill")
                            .font(.title2)
                            .frame(width: 50, height: 50)
                            .background(Color.red)               // Red for stop
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                Spacer()                                            // Push banner up
            }
            .padding(.horizontal, 16)                               // Horizontal padding

            // OVERLAY: Summary Banner floats above when triggered
            if showSummaryBanner {
                RecordingSummaryBanner(
                    job: selectedJob,
                    duration: elapsedTime,
                    date: Date()
                )
                .transition(.move(edge: .top).combined(with: .opacity)) // Banner in/out animation
                .zIndex(1)                                           // Render above main content
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation { showSummaryBanner = false }  // Auto-hide after 3s
                    }
                }
            }
        }
    }
}
