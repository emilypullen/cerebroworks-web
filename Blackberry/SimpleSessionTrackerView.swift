import SwiftUI

struct SimpleSessionTrackerView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @State private var isTracking = false
    @State private var isPaused = false
    @State private var startTime: Date?
    @State private var pauseTime: Date?
    @State private var totalPausedTime: TimeInterval = 0
    @State private var sessionSummary: String?
    @State private var showSaveAlert = false

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        return hour < 10 ? "Good Morning!" : "Welcome Back!"
    }

    var body: some View {
        VStack(spacing: 24) {
            // 🌿 Greeting
            Text(greeting)
                .font(.largeTitle.bold())
                .foregroundColor(.brown)

            Text("Track your time and review your week")
                .font(.subheadline)
                .foregroundColor(.gray)

            Spacer()

            // 🕒 Session Status
            if let start = startTime, isTracking {
                Text("Started at: \(formattedDate(start))")
                    .font(.subheadline)
            }

            if let summary = sessionSummary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundColor(.green)
                    .padding(.top)
            }

            // 🎛 Control Buttons
            HStack(spacing: 20) {
                Button("Start") {
                    startSession()
                }
                .disabled(isTracking)
                .padding()
                .background(Color.green.opacity(0.7))
                .foregroundColor(.white)
                .cornerRadius(12)

                Button(isPaused ? "Resume" : "Pause") {
                    togglePause()
                }
                .disabled(!isTracking)
                .padding()
                .background(Color.orange.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)

                Button("End") {
                    showSaveAlert = true
                }
                .disabled(!isTracking)
                .padding()
                .background(Color.red.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(12)
            }

            Spacer()
        }
        .padding()
        .alert("Save this session?", isPresented: $showSaveAlert) {
            Button("Yes", action: saveSessionToCoreData)
            Button("No", role: .cancel, action: resetSession)
        } message: {
            Text("Would you like to save this session to your entries?")
        }
    }

    // MARK: - Session Actions

    private func startSession() {
        startTime = Date()
        isTracking = true
        isPaused = false
        pauseTime = nil
        totalPausedTime = 0
        sessionSummary = nil
    }

    private func togglePause() {
        if isPaused {
            if let pausedAt = pauseTime {
                totalPausedTime += Date().timeIntervalSince(pausedAt)
            }
            isPaused = false
        } else {
            pauseTime = Date()
            isPaused = true
        }
    }

    // MARK: - Save Session

    private func saveSessionToCoreData() {
        guard let start = startTime else { return }

        let end = Date()
        let newEntry = EntryData(context: viewContext)
        newEntry.date = Date()
        newEntry.startTime = start
        newEntry.endTime = end
        newEntry.breakTime = Int16(totalPausedTime / 60)
        newEntry.manualDuration = 0
        newEntry.job = "Other"

        do {
            try viewContext.save()
            sessionSummary = "Session: \(formatDuration(end.timeIntervalSince(start) - totalPausedTime))"
        } catch {
            print("⚠️ Error saving entry: \(error.localizedDescription)")
        }

        resetSession()
    }

    // MARK: - Reset Session

    private func resetSession() {
        isTracking = false
        isPaused = false
        startTime = nil
        pauseTime = nil
        totalPausedTime = 0
    }

    // MARK: - Formatters

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return "\(minutes)m \(seconds)s"
    }
}

