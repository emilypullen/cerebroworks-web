import Foundation

struct TimeBlock: Identifiable, Hashable {
    let id: UUID
    var start: Date
    var end: Date
    var job: String

    init(start: Date, end: Date, job: String = "") {
        self.id = UUID()
        self.start = start
        self.end = end
        self.job = job
    }
}
