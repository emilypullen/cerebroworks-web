import SwiftUI

class JobColors {
    static let shared = JobColors()

    private let storageKey = "jobColorNames"

    // MARK: - Save Color Names

    func saveColorNames(_ colors: [String: String]) {
        do {
            let data = try JSONEncoder().encode(colors)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("❌ Failed to save job colors: \(error.localizedDescription)")
        }
    }

    // MARK: - Load Color Names

    func loadColorNames() -> [String: String] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return [:]
        }

        do {
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            print("❌ Failed to load job colors: \(error.localizedDescription)")
            return [:]
        }
    }

    // MARK: - Color Lookup

    static func color(for job: String) -> Color {
        let colorName = shared.loadColorNames()[job] ?? "color1"
        return Color(colorName)
    }
}

