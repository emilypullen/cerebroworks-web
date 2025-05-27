import SwiftUI
import CoreData

struct HomeTabView: View {
    // MARK: — External bindings & state

    @Binding var tasks: [UserTask]
    @Binding var isRecording: Bool
    @Binding var isOnBreak: Bool
    @Binding var breakStartTime: Date?
    @Binding var breakDuration: TimeInterval
    @Binding var selectedTab: Tab

    // MARK: — Local UI state

    @State private var taskInput = ""
    @State private var selectedJob = ""
    @State private var showSettings = false
    @State private var showTagMenu = false

    @State private var elapsedTime: TimeInterval = 0
    @State private var recordingStartTime: Date?

    // NEW: job → saved tasks map
    @State private var jobToTasks: [String:[UserTask]] = [:]

    private let timer =
        Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @ObservedObject private var jobManager = JobListManager.shared
    @Environment(\.managedObjectContext) private var viewContext

    var body: some View {
        NavigationView {
            GeometryReader { geo in
                let safeBottom = geo.safeAreaInsets.bottom

                ZStack {
                    AppTheme.current.backgroundView
                        .ignoresSafeArea()

                    VStack(spacing: 24) {
                        // HEADER
                        headerView
                            .padding(.top, 8)

                        // TASKS BOX
                        if !jobManager.jobList.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Today's Tasks")
                                    .font(AppFonts.heading)
                                    .foregroundColor(.white)

                                // Corrected TaskBoxView call with jobToTasks
                                TaskBoxView(
                                    tasks: $tasks,
                                    taskInput: $taskInput,
                                    selectedJob: $selectedJob,
                                    showTagMenu: $showTagMenu,
                                    editingTaskID: .constant(nil),
                                    jobToTasks: $jobToTasks,            // ← pass here
                                    jobList: jobManager.jobList,        // ← then jobList
                                    addTask: {
                                        guard !taskInput.isEmpty else { return }
                                        let new = UserTask(name: taskInput, job: selectedJob)
                                        tasks.append(new)
                                        jobToTasks[selectedJob] = tasks
                                        taskInput = ""
                                    },
                                    deleteTask: { task in
                                        tasks.removeAll { $0.id == task.id }
                                        jobToTasks[selectedJob] = tasks
                                    }
                                )
                                .frame(height: 260)
                                .padding(.top, 16)
                                .padding(.bottom, 16)
                            }
                        } else {
                            emptyStateView
                        }

                        Spacer(minLength: 8)

                        // LIVE TRACKING
                        RecordingView(
                            isRecording: $isRecording,
                            isOnBreak: $isOnBreak,
                            elapsedTime: $elapsedTime,
                            jobList: jobManager.jobList,
                            selectedJob: $selectedJob,
                            startAction: startRecording,
                            pauseAction: pauseRecording,
                            resumeAction: resumeRecording,
                            stopAction: stopRecording
                        )
                        .frame(minHeight: 180)

                        Spacer(minLength: safeBottom + 16)
                    }
                    .padding(.horizontal, 24)

                    // SETTINGS BUTTON
                    .overlay(alignment: .bottomTrailing) {
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 56, height: 56)
                                .background(Circle().fill(.ultraThinMaterial))
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, safeBottom + 16)
                    }
                }
            }
            .onReceive(timer) { _ in
                guard isRecording, let start = recordingStartTime else { return }
                elapsedTime = Date().timeIntervalSince(start) - breakDuration
            }
            .sheet(isPresented: $showSettings) {
                NavigationView { SettingsView() }
            }
            .onAppear { jobManager.loadJobs() }
            .onReceive(
                NotificationCenter.default.publisher(
                    for: .NSManagedObjectContextDidSave,
                    object: viewContext
                )
            ) { _ in jobManager.loadJobs() }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: — Actions

    private func startRecording() {
        recordingStartTime = Date()
        breakDuration = 0
        breakStartTime = nil
        elapsedTime = 0
        isRecording = true
        isOnBreak = false
    }

    private func pauseRecording() {
        isOnBreak = true
        isRecording = false
        breakStartTime = Date()
    }

    private func resumeRecording() {
        if let startBreak = breakStartTime {
            breakDuration += Date().timeIntervalSince(startBreak)
        }
        isOnBreak = false
        isRecording = true
    }

    private func stopRecording() {
        guard !selectedJob.isEmpty,
              let start = recordingStartTime else {
            isRecording = false
            isOnBreak = false
            return
        }

        let totalDuration = Date().timeIntervalSince(start) - breakDuration
        let savedSubtasks = jobToTasks[selectedJob] ?? []

        // Append a new simple UserTask
        tasks.append(UserTask(name: selectedJob, job: selectedJob))

        isRecording = false
        isOnBreak = false
        breakDuration = 0
        recordingStartTime = nil
        elapsedTime = 0
        selectedJob = ""
    }

    // MARK: — Header view

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Home")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Text("Manage your tasks and track your work")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.title2)
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: — Empty State view

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("No jobs yet!")
                .font(AppFonts.heading)
                .foregroundColor(.white)
            Text("Tap '+' to add your first job.")
                .font(.body)
                .foregroundColor(.white.opacity(0.8))
            Image(systemName: "arrow.down.circle.fill")
                .font(.largeTitle)
                .foregroundColor(.white.opacity(0.8))
                .onAppear { withAnimation(.easeInOut(duration: 1).repeatForever()) {} }
            Spacer()
        }
    }
}
