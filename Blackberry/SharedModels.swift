import Foundation
import SwiftUI

// MARK: - Job Summary Model

struct JobSummary: Identifiable, Hashable {
    var id = UUID()
    var job: String
    var totalHours: Double
    var dailyBreakdown: [DailyRecord]
}

// MARK: - Daily Record Model

struct DailyRecord: Hashable {
    var jobName: String
    var date: Date
    var hours: Double
}

// MARK: - User Task Model

struct UserTask: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var job: String
    var isCompleted: Bool = false   // Default: false
}

// MARK: - Day Summary Model

struct DaySummary: Identifiable, Hashable {
    var id: String { day }
    let day: String
    let hours: Double
}

