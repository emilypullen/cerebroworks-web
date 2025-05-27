import SwiftUI
import CoreData

class EntryManager: ObservableObject {
    static let shared = EntryManager()
    
    @Published var timeBlocks: [TimeBlock] = []
    
    private let context = PersistenceController.shared.container.viewContext

    private init() {
        loadTimeBlocksFromCoreData()
    }

    func createEntry(job: String, start: Date, end: Date, tasks: [String] = [], notes: String = "") {
        let newBlock = TimeBlock(start: start, end: end, job: job)
        timeBlocks.append(newBlock)

        let newEntry = EntryData(context: context)
        newEntry.job = job
        newEntry.date = start
        newEntry.startTime = start
        newEntry.endTime = end
        newEntry.tasksArray = tasks
        newEntry.completedTasksArray = []
        newEntry.notes = notes

        do {
            try context.save()
            print("✅ Entry saved.")
            NotificationCenter.default.post(name: .newEntryCreated, object: nil)
        } catch {
            print("❌ Failed to save entry: \(error.localizedDescription)")
        }
    }

    func loadTimeBlocksFromCoreData() {
        let fetchRequest: NSFetchRequest<EntryData> = EntryData.fetchRequest()

        do {
            let entries = try context.fetch(fetchRequest)
            timeBlocks = entries.map { entry in
                TimeBlock(
                    start: entry.startTime ?? Date(),
                    end: entry.endTime ?? Date(),
                    job: entry.job ?? ""
                )
            }
            print("✅ Loaded \(timeBlocks.count) timeBlocks from CoreData.")
        } catch {
            print("❌ Failed to load timeBlocks from CoreData: \(error.localizedDescription)")
        }
    }
}

// 🚀 Important: this must be OUTSIDE the class
extension Notification.Name {
    static let newEntryCreated = Notification.Name("newEntryCreated")
}

