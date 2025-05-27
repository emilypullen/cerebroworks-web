import Foundation

extension EntryData {
    var tasksArray: [String] {
        get {
            (tasks ?? "")
                .components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
        set {
            tasks = newValue.joined(separator: "\n")
        }
    }

    var completedTasksArray: [String] {
        get {
            (completedTasks ?? "")
                .components(separatedBy: "\n")
                .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        }
        set {
            completedTasks = newValue.joined(separator: "\n")
        }
    }
}
