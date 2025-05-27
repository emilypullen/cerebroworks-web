import SwiftUI                       // Import SwiftUI for UI components
import CoreData                       // Import CoreData for data persistence

struct TaskBoxView: View {
    @Binding var tasks: [UserTask]                     // Current list of tasks for this session
    @Binding var taskInput: String                     // Text field input for a new task
    @Binding var selectedJob: String                   // Currently selected job tag
    @Binding var showTagMenu: Bool                     // Whether to show the job-selection menu
    @Binding var editingTaskID: UUID?                  // ID of the task currently being edited
    @Binding var jobToTasks: [String:[UserTask]]       // Map of saved tasks by job
    @FocusState private var focusedTaskID: UUID?       // For managing keyboard focus
    var jobList: [String]                              // Available list of job tags

    var addTask: () -> Void                            // Callback to add a new task
    var deleteTask: (UserTask) -> Void                 // Callback to delete an existing task

    @Environment(\.managedObjectContext) private var viewContext // CoreData context
    private var taskManager: TaskManagerCoreData { TaskManagerCoreData(context: viewContext) }

    @State private var jobColorMap: [String: String] = [:] // Map job → color name

    var body: some View {
        VStack(spacing: 18) {                        // Vertical stack with consistent spacing
            taskInputBar                            // Input bar for adding tasks

            if !selectedJob.isEmpty {               // Show currently selected job tag
                selectedTagLabel
            }

            if showTagMenu {                        // Show horizontal scroll of job tags
                tagMenu
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }

            taskList                                // ScrollView of current tasks
        }
        .onAppear {
            jobColorMap = JobColors.shared.loadColorNames() // Load job color names once
        }
    }

    // MARK: — Input Bar

    private var taskInputBar: some View {
        HStack(spacing: 12) {
            TextField("Enter a new task...", text: $taskInput)
                .padding()
                .frame(height: 50)                 // Fixed height for consistency
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .frame(maxWidth: .infinity)
                .submitLabel(.done)
                .focused($focusedTaskID, equals: editingTaskID)
                .onSubmit {
                    withAnimation { handleAddTask() }
                }

            Button {
                withAnimation { showTagMenu.toggle() } // Toggle tag menu visibility
            } label: {
                Image(systemName: "tag.fill")
                    .frame(width: 44, height: 44)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .accessibilityLabel("Select Job Tag")
            }

            Button {
                withAnimation { handleAddTask() }    // Add the task when tapping plus
            } label: {
                Image(systemName: "plus")
                    .frame(width: 44, height: 44)
                    .background(AppColors.primary)
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .accessibilityLabel("Add Task")
            }
        }
    }

    // MARK: — Selected Tag Label

    private var selectedTagLabel: some View {
        HStack {
            Text("Tag: \(selectedJob)")
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(colorForJob(selectedJob).opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
            Spacer()
        }
        .padding(.leading)
    }

    // MARK: — Job Tag Menu

    private var tagMenu: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(jobList, id: \.self) { tag in
                    Button {
                        selectedJob = tag          // Select this tag
                        showTagMenu = false        // Hide the menu
                    } label: {
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(colorForJob(tag).opacity(0.2))
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorForJob(tag).opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.vertical, 6)
            .padding(.horizontal)
        }
    }

    // MARK: — Task List

    private var taskList: some View {
        ZStack {
            if tasks.isEmpty {
                Text("No tasks yet. Add one above.")
                    .foregroundColor(.secondary)
                    .padding(.top, 10)
            } else {
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(tasks) { task in
                            TaskRowView(
                                task: .constant(task),              // Bind for the row
                                isEditing: editingTaskID == task.id,
                                isFocused: focusedTaskID == task.id,
                                onEdit: { editingTaskID = task.id },
                                onSubmit: { editingTaskID = nil },
                                onDelete: {
                                    withAnimation {
                                        deleteTask(task)             // Delete the tapped task
                                        jobToTasks[selectedJob] = tasks.filter { $0.id != task.id }  // Sync map
                                    }
                                },
                                color: colorForJob(task.job)
                            )
                        }
                    }
                    .padding(.top, 6)
                }
            }
        }
        .frame(maxHeight: 260)   // Prevent TaskBoxView from growing beyond this
        .frame(maxWidth: .infinity)
    }

    // MARK: — Helpers

    private func handleAddTask() {
        let trimmed = taskInput.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        // 1) Append new task
        let newTask = UserTask(name: trimmed, job: selectedJob)
        tasks.append(newTask)
        addTask()

        // 2) Sync into the per-job map
        jobToTasks[selectedJob] = tasks

        // 3) Clear input
        taskInput = ""
    }

    private func colorForJob(_ job: String) -> Color {
        Color(jobColorMap[job] ?? "gray")
    }
}
