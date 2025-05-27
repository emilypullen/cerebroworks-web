// AnalyticsModels.swift

import Foundation

// MARK: - Global Structs (Reusable Analytics Models)

struct TimeSplit: Identifiable {
    let id = UUID()
    let label: String
    let hours: Double
}

struct HourlyTaskData: Identifiable {
    let id = UUID()
    let day: String
    let hour: Int
    let taskCount: Int
}

struct JobSegment: Identifiable {
    let id = UUID()
    let jobName: String
    let start: Date
    let end: Date
    let day: String
}

struct DailyValue: Identifiable {
    let id = UUID()
    let day: String
    let value: Int
}
