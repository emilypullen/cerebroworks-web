//
//  TaskManagerCoreData.swift
//  Blackberry
//
//  Created by Emily Pullen on 2025-04-23.
//

import Foundation
import CoreData

@MainActor
final class TaskManagerCoreData {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    /// Adds a task with deduplication (same day, same job, same task name)
    func addTask(name: String, job: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        let (startOfDay, endOfDay) = todayBounds()

        let fetchRequest = NSFetchRequest<TaskData>(entityName: "TaskData")
        fetchRequest.predicate = NSPredicate(
            format: "taskJob == %@ AND taskName == %@ AND timestamp >= %@ AND timestamp < %@",
            job, trimmedName, startOfDay as NSDate, endOfDay as NSDate
        )
        fetchRequest.fetchLimit = 1

        do {
            let duplicates = try viewContext.fetch(fetchRequest)
            if !duplicates.isEmpty { return } // Avoid duplicate
        } catch {
            print("⚠️ Error checking for duplicates: \(error.localizedDescription)")
        }

        let task = TaskData(context: viewContext)
        task.taskId = UUID()
        task.taskName = trimmedName
        task.taskJob = job
        task.isCompleted = false
        task.timestamp = Date()

        do {
            try viewContext.save()
            print("✅ Task '\(trimmedName)' added for job '\(job)'")
        } catch {
            print("❌ Error saving task: \(error.localizedDescription)")
        }
    }

    /// Fetches the most recent tasks for a job
    func fetchRecentTasks(for job: String, limit: Int = 5) -> [TaskData] {
        let fetchRequest = NSFetchRequest<TaskData>(entityName: "TaskData")
        fetchRequest.predicate = NSPredicate(format: "taskJob == %@", job)
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskData.timestamp, ascending: false)]
        fetchRequest.fetchLimit = limit

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("⚠️ Error fetching recent tasks: \(error.localizedDescription)")
            return []
        }
    }

    /// Fetches today’s tasks for a job
    func fetchTodayTasks(for job: String) -> [TaskData] {
        let (startOfDay, endOfDay) = todayBounds()

        let fetchRequest = NSFetchRequest<TaskData>(entityName: "TaskData")
        fetchRequest.predicate = NSPredicate(
            format: "taskJob == %@ AND timestamp >= %@ AND timestamp < %@",
            job, startOfDay as NSDate, endOfDay as NSDate
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \TaskData.timestamp, ascending: false)]

        do {
            return try viewContext.fetch(fetchRequest)
        } catch {
            print("⚠️ Error fetching today’s tasks: \(error.localizedDescription)")
            return []
        }
    }

    /// Removes a specific task (optional utility)
    func deleteTask(_ task: TaskData) {
        viewContext.delete(task)
        do {
            try viewContext.save()
        } catch {
            print("❌ Failed to delete task: \(error.localizedDescription)")
        }
    }

    // MARK: - Utility

    private func todayBounds() -> (Date, Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let end = calendar.date(byAdding: .day, value: 1, to: start)!
        return (start, end)
    }
}
