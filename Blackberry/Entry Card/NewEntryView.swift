import SwiftUI
import CoreData

struct NewEntryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject private var jobManager = JobListManager.shared

    private let jobColorMap = JobColors.shared.loadColorNames()

    @State private var job: String = ""
    @Binding var selectedTab: Tab

    @State private var date: Date = Date()
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var tasks: String = ""
    @State private var notes: String = ""

    @State private var showValidationAlert = false
    @State private var isSaving = false
    @State private var cardColor: Color = .gray

    private var taskManager: TaskManagerCoreData {
        TaskManagerCoreData(context: viewContext)
    }

    init(initialTasks: [String] = [], selectedTab: Binding<Tab>) {
        _tasks = State(initialValue: initialTasks.joined(separator: "\n"))
        self._selectedTab = selectedTab
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    jobSection
                    tasksSection
                    notesSection

                    Button(action: saveEntry) {
                        Text("Save Entry")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppColors.primary)
                            .foregroundColor(.white)
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isSaving)
                    .padding(.top, 10)
                }
                .padding()
                .onAppear {
                    cardColor = .gray
                }
            }
            .background(AppTheme.current.backgroundView)
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(AppColors.secondary)
                }
            }
            .alert("Please select a job.", isPresented: $showValidationAlert) {
                Button("OK", role: .cancel) {}
            }
        }
        .simultaneousGesture(
            TapGesture().onEnded { hideKeyboard() }
        )
    }

    // MARK: - Sections

    private var jobSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Job")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.secondary)

            Picker("Select Job", selection: $job) {
                Text("Select Job").tag("")
                ForEach(jobManager.jobList, id: \.self) { jobOption in
                    Text(jobOption).tag(jobOption)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding(10)
            .background(.ultraThinMaterial)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(cardColor, lineWidth: 2)
            )
            .onChange(of: job) { newJob in
                if newJob.isEmpty {
                    tasks = ""
                    cardColor = .gray
                } else {
                    tasks = taskManager.fetchRecentTasks(for: newJob)
                        .compactMap { $0.taskName }
                        .joined(separator: "\n")
                    cardColor = Color(jobColorMap[newJob] ?? "CeramicMug")
                }
            }

            Text("Date & Time")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.secondary)

            DatePicker("Date", selection: $date, displayedComponents: .date)
            DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
            DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardColor, lineWidth: 2)
        )
    }

    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Tasks")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.secondary)

            TextEditor(text: $tasks)
                .frame(height: 120)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cardColor, lineWidth: 2)
                )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardColor, lineWidth: 2)
        )
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Notes")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.secondary)

            TextEditor(text: $notes)
                .frame(height: 120)
                .padding(8)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(cardColor, lineWidth: 2)
                )
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(cardColor, lineWidth: 2)
        )
    }

    // MARK: - Save Logic

    private func saveEntry() {
        guard !job.isEmpty else {
            showValidationAlert = true
            return
        }
        guard !isSaving else { return }
        isSaving = true

        let start = combineDateAndTime(date: date, time: startTime)
        let end = combineDateAndTime(date: date, time: endTime)
        let taskList = tasks.split(separator: "\n").map(String.init)

        EntryManager.shared.createEntry(
            job: job,
            start: start,
            end: end,
            tasks: taskList,
            notes: notes
        )

        selectedTab = .entries
        dismiss()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isSaving = false
        }
    }

    private func combineDateAndTime(date: Date, time: Date) -> Date {
        let cal = Calendar.current
        let d = cal.dateComponents([.year, .month, .day], from: date)
        let t = cal.dateComponents([.hour, .minute, .second], from: time)
        return cal.date(from: DateComponents(
            year: d.year, month: d.month, day: d.day,
            hour: t.hour, minute: t.minute, second: t.second
        )) ?? Date()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

