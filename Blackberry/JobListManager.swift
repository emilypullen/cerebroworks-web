import SwiftUI
import CoreData

class JobListManager: ObservableObject {
    static let shared = JobListManager()

    @Published var jobList: [String] = []

    private var viewContext: NSManagedObjectContext {
        PersistenceController.shared.container.viewContext
    }

    private init() {
        loadJobs()
    }

    func loadJobs() {
        let request: NSFetchRequest<JobData> = JobData.fetchRequest()

        do {
            let jobs = try viewContext.fetch(request)
            self.jobList = jobs.compactMap { $0.nameJob }
            print("✅ JobListManager refreshed: \(self.jobList)")
        } catch {
            print("❌ Failed to fetch jobs: \(error.localizedDescription)")
            self.jobList = []
        }
    }

    func refresh() {
        loadJobs()
    }
}
