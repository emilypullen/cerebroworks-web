import Foundation
import CoreData
import SwiftUI

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var jobSummaries: [JobSummary] = []

    func computeHoursByJob(from entries: [EntryData]) {
        var dict: [String: Double] = [:]
        for entry in entries {
            guard let start = entry.startTime, let end = entry.endTime else { continue }
            let duration = end.timeIntervalSince(start) / 3600
            let job = entry.job ?? "Other"
            dict[job, default: 0] += duration
        }
        self.jobSummaries = dict.map {
            JobSummary(job: $0.key, totalHours: $0.value, dailyBreakdown: [])
        }
    }

    func totalHours(from entries: [EntryData]) -> Double {
        entries.reduce(0) {
            guard let start = $1.startTime, let end = $1.endTime else { return $0 }
            return $0 + end.timeIntervalSince(start) / 3600
        }
    }

    func completedTasks(from entries: [EntryData]) -> Int {
        entries.reduce(0) { $0 + $1.completedTasksArray.count }
    }

    func breakMinutes(from entries: [EntryData]) -> Int {
        entries.reduce(0) { $0 + Int($1.breakDuration) } / 60
    }

    func hoursPerDay(from entries: [EntryData], format: String = "EEE") -> [DaySummary] {
        var result: [String: Double] = [:]
        let formatter = DateFormatter()
        formatter.dateFormat = format

        for entry in entries {
            guard let date = entry.date,
                  let start = entry.startTime,
                  let end = entry.endTime else { continue }
            let key = formatter.string(from: date)
            result[key, default: 0] += end.timeIntervalSince(start) / 3600
        }

        return result.map { DaySummary(day: $0.key, hours: $0.value) }
            .sorted { $0.day < $1.day }
    }

    func generateJobSummaries(from entries: [EntryData]) -> [JobSummary] {
        var summaries: [String: JobSummary] = [:]

        for entry in entries {
            guard let job = entry.job else { continue }
            let date = entry.date ?? Date()
            let hours = entry.duration

            var daily = summaries[job]?.dailyBreakdown ?? []
            daily.append(DailyRecord(jobName: job, date: date, hours: hours))

            summaries[job] = JobSummary(
                job: job,
                totalHours: (summaries[job]?.totalHours ?? 0) + hours,
                dailyBreakdown: daily
            )
        }

        return Array(summaries.values)
    }

    func hourlyProductivityHeatmap(from entries: [EntryData], format: String = "EEE") -> [HourlyTaskData] {
        let calendar = Calendar.current
        var counts: [String: [Int: Int]] = [:]

        let formatter = DateFormatter()
        formatter.dateFormat = format

        for entry in entries {
            guard let date = entry.date else { continue }
            guard let hour = calendar.dateComponents([.hour], from: date).hour else { continue }

            let dayKey = formatter.string(from: date)
            let taskCount = entry.completedTasksArray.count
            counts[dayKey, default: [:]][hour, default: 0] += taskCount
        }

        return counts.flatMap { day, hourMap in
            hourMap.map { hour, count in
                HourlyTaskData(day: day, hour: hour, taskCount: count)
            }
        }
    }

    func jobSwitchesPerDay(from entries: [EntryData], format: String = "EEE") -> [DailyValue] {
        let sorted = entries.sorted(by: { ($0.date ?? Date()) < ($1.date ?? Date()) })
        var result: [String: Int] = [:]
        var lastJob: String? = nil
        var lastDay: String? = nil

        let formatter = DateFormatter()
        formatter.dateFormat = format

        for entry in sorted {
            guard let date = entry.date else { continue }
            let currentJob = entry.job ?? "Unknown"
            let currentDay = formatter.string(from: date)

            if currentDay != lastDay {
                lastDay = currentDay
                lastJob = currentJob
                continue
            }

            if currentJob != lastJob {
                result[currentDay, default: 0] += 1
                lastJob = currentJob
            }
        }

        return result.map { DailyValue(day: $0.key, value: $0.value) }
    }

    func idleVsActiveTime(from entries: [EntryData], and activities: [NonWorkActivity]) -> [TimeSplit] {
        let totalTracked = totalHours(from: entries)
        let nonWork = activities.reduce(0.0) { $0 + $1.nonWorkHours }
        let totalAvailable = Double(16 * 7)
        let idle = max(0, totalAvailable - totalTracked - nonWork)

        return [
            TimeSplit(label: "Active", hours: totalTracked),
            TimeSplit(label: "Wellness", hours: nonWork),
            TimeSplit(label: "Idle", hours: idle)
        ]
    }

    func jobSegmentsByDay(from entries: [EntryData]) -> [JobSegment] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"

        return entries.compactMap { entry in
            guard let start = entry.startTime,
                  let end = entry.endTime,
                  let job = entry.job else { return nil }

            let day = formatter.string(from: start)

            return JobSegment(jobName: job, start: start, end: end, day: day)
        }
    }
}

// MARK: - EntryData Extension

extension EntryData {
    var duration: Double {
        guard let start = self.startTime, let end = self.endTime else { return 0 }
        return end.timeIntervalSince(start) / 3600
    }
}
