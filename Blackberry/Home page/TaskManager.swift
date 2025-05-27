import Foundation
import Combine

class TaskManager: ObservableObject {
    @Published var jobTasks: [String: [UserTask]] = [:] // jobName → [Tasks]

    /// Add a task to the list for the given job
    func addTask(_ task: UserTask) {
        jobTasks[task.job, default: []].append(task)
    }

    /// Get the list of tasks for a specific job
    func getLastTasks(for job: String) -> [UserTask] {
        jobTasks[job] ?? []
    }

    /// Remove a specific task (optional convenience)
    func removeTask(_ task: UserTask) {
        guard var tasks = jobTasks[task.job] else { return }
        tasks.removeAll { $0.id == task.id }
        jobTasks[task.job] = tasks
    }

    /// Clear all tasks (optional utility)
    func clearAll() {
        jobTasks.removeAll()
    }
}
