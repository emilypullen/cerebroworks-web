import SwiftUI
import CoreData

struct EntryCardView: View {
    @ObservedObject var entry: EntryData
    @Environment(\.managedObjectContext) private var viewContext
    @AppStorage("billingEnabled") private var billingEnabled: Bool = false

    @FetchRequest(
        entity: JobData.entity(),
        sortDescriptors: []
    ) private var jobList: FetchedResults<JobData>

    @State private var newNotes: String = ""
    @State private var showDetail = false
    @State private var editingNewTask: String = ""
    @FocusState private var taskFieldFocused: Bool

    private let currencyFormatter: NumberFormatter = {
        let fmt = NumberFormatter()
        fmt.numberStyle = .currency
        fmt.minimumFractionDigits = 2
        fmt.maximumFractionDigits = 2
        return fmt
    }()

    private var jobColorMap: [String: String] {
        JobColors.shared.loadColorNames()
    }

    private var jobColor: Color {
        if let name = entry.job,
           let asset = jobColorMap[name] {
            return Color(asset)
        }
        return AppColors.primary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Rectangle()
                .fill(jobColor)
                .frame(height: 4)
                .cornerRadius(2)
                .padding(.horizontal, -20)

            headerSection
            Divider()
            tasksSection
            Divider()
            notesSection

            if billingEnabled, let start = entry.startTime, let end = entry.endTime {
                Divider()
                billingSection(start: start, end: end)
            }

            navigationButton
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 8)
        .onTapGesture { hideKeyboard() }
        .onAppear { newNotes = entry.notes ?? "" }
    }

    // MARK: - Header
    private var headerSection: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formattedDate(entry.date))
                    .font(.headline)
                    .foregroundColor(AppColors.secondary)
                if let start = entry.startTime, let end = entry.endTime {
                    Text("\(start.formatted(date: .omitted, time: .shortened)) – \(end.formatted(date: .omitted, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(AppColors.text.opacity(0.6))
                }
            }
            Spacer()
            if let jobName = entry.job {
                Text(jobName)
                    .font(.caption)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(jobColor.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Tasks
    private var tasksSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tasks")
                    .font(.subheadline.bold())
                    .foregroundColor(AppColors.secondary)
                Spacer()
                Button(action: clearAllTasks) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .help("Clear all tasks")
            }

            if entry.tasksArray.isEmpty && entry.completedTasksArray.isEmpty {
                Text("No tasks added yet.")
                    .foregroundColor(AppColors.text.opacity(0.5))
                    .italic()
            } else {
                ForEach(entry.tasksArray, id: \.self) { task in
                    HStack(spacing: 10) {
                        Button(action: { toggleCompletion(task) }) {
                            Image(systemName: "circle")
                                .foregroundColor(jobColor)
                        }
                        Text(task)
                            .font(.body)
                            .foregroundColor(AppColors.text)
                    }
                }

                ForEach(entry.completedTasksArray, id: \.self) { task in
                    HStack(spacing: 10) {
                        Button(action: { toggleCompletion(task) }) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                        Text(task)
                            .font(.body)
                            .strikethrough()
                            .foregroundColor(.gray)
                    }
                }
            }

            HStack {
                TextField("Add task...", text: $editingNewTask)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($taskFieldFocused)
                Button(action: addNewTask) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(jobColor)
                }
                .disabled(editingNewTask.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
    }

    // MARK: - Notes
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Notes")
                .font(.subheadline.bold())
                .foregroundColor(AppColors.secondary)

            ZStack(alignment: .topLeading) {
                if newNotes.isEmpty {
                    Text("Write your notes...")
                        .foregroundColor(AppColors.text.opacity(0.4))
                        .padding(8)
                }
                TextEditor(text: $newNotes)
                    .frame(minHeight: 100)
                    .padding(6)
                    .background(AppColors.background.opacity(0.15))
                    .cornerRadius(12)
                    .onChange(of: newNotes) { _ in saveNotes() }
            }

            HStack {
                Spacer()
                Text("\(newNotes.count)/500")
                    .font(.caption)
                    .foregroundColor(counterColor(for: newNotes.count))
            }
        }
    }

    // MARK: - Billing Section
    private func billingSection(start: Date, end: Date) -> some View {
        let hours = end.timeIntervalSince(start) / 3600
        let rate = jobList.first(where: { $0.nameJob == entry.job })?.rate1 ?? 0
        let total = hours * rate

        return VStack(alignment: .leading, spacing: 4) {
            Text("Billed Hours: \(String(format: "%.2f", hours))")
            Text("Rate: \(currencyFormatter.string(from: NSNumber(value: rate)) ?? "$")")
            Text("Total: \(currencyFormatter.string(from: NSNumber(value: total)) ?? "$")")
        }
        .font(.caption)
        .foregroundColor(AppColors.text)
    }

    // MARK: - Navigation
    private var navigationButton: some View {
        HStack {
            Spacer()
            Button(action: { showDetail = true }) {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.title2)
                    .foregroundColor(jobColor)
                    .padding(8)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .buttonStyle(PlainButtonStyle())
            .sheet(isPresented: $showDetail) {
                EntryDetailView(entry: entry)
            }
        }
    }

    // MARK: - Actions
    private func toggleCompletion(_ task: String) {
        if entry.tasksArray.contains(task) {
            markTaskAsCompleted(task)
        } else {
            markTaskAsIncomplete(task)
        }
    }

    private func addNewTask() {
        let trimmed = editingNewTask.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        entry.tasksArray.append(trimmed)
        saveContext()
        editingNewTask = ""
        taskFieldFocused = true
    }

    private func clearAllTasks() {
        entry.tasksArray = []
        entry.completedTasksArray = []
        saveContext()
    }

    private func markTaskAsCompleted(_ task: String) {
        entry.tasksArray.removeAll { $0 == task }
        entry.completedTasksArray.append(task)
        saveContext()
    }

    private func markTaskAsIncomplete(_ task: String) {
        entry.completedTasksArray.removeAll { $0 == task }
        entry.tasksArray.append(task)
        saveContext()
    }

    private func saveNotes() {
        entry.notes = String(newNotes.prefix(500)).trimmingCharacters(in: .whitespacesAndNewlines)
        saveContext()
    }

    private func saveContext() {
        try? viewContext.save()
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    private func formattedDate(_ date: Date?) -> String {
        date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown Date"
    }

    private func counterColor(for count: Int) -> Color {
        switch count {
        case 0..<450: return .gray
        case 450..<490: return .orange
        default: return .red
        }
    }
}

