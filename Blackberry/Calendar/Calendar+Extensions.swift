import Foundation

extension Calendar {
    func startOfWeek(for date: Date) -> Date {
        let components = dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        return self.date(from: components) ?? date
    }

    func startOfMonth(for date: Date) -> Date {
        return self.date(from: dateComponents([.year, .month], from: date))!
    }

    func startOfNextMonth(for date: Date) -> Date {
        return self.date(byAdding: .month, value: 1, to: startOfMonth(for: date))!
    }
}
