import Foundation
import SwiftUI
import UniformTypeIdentifiers

struct ExportManager {
    static func csv(from entries: [EntryData]) -> URL? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        let filename = "EntriesExport_\(dateString).csv"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        var csvText = "Job,Date,Incomplete Tasks,Completed Tasks,Notes\n"

        for entry in entries {
            let job = entry.job ?? "Untitled"
            let date = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"
            let tasks = entry.tasks?.replacingOccurrences(of: "\n", with: "; ") ?? ""
            let completed = entry.completedTasks?.replacingOccurrences(of: "\n", with: "; ") ?? ""
            let notes = entry.notes?.replacingOccurrences(of: "\n", with: " ") ?? ""

            let line = [
                job,
                date,
                tasks,
                completed,
                notes
            ]
            .map { "\"\($0)\"" }
            .joined(separator: ",") + "\n"

            csvText.append(line)
        }

        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("❌ Failed to write CSV: \(error.localizedDescription)")
            return nil
        }
    }
}

