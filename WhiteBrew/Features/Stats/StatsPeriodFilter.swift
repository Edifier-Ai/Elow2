import Foundation

enum StatsPeriod: String, CaseIterable, Identifiable {
    case week
    case month
    case year

    var id: String { rawValue }

    var title: String {
        switch self {
        case .week:
            "Week"
        case .month:
            "Month"
        case .year:
            "Year"
        }
    }

    func startDate(from date: Date, calendar: Calendar) -> Date {
        switch self {
        case .week:
            calendar.date(byAdding: .day, value: -7, to: date) ?? date
        case .month:
            calendar.date(byAdding: .month, value: -1, to: date) ?? date
        case .year:
            calendar.date(byAdding: .year, value: -1, to: date) ?? date
        }
    }
}

enum StatsPeriodFilter {
    static func records(
        in period: StatsPeriod,
        from records: [DrinkRecord],
        now: Date,
        calendar: Calendar = .current
    ) -> [DrinkRecord] {
        let start = period.startDate(from: now, calendar: calendar)
        return records.filter { record in
            record.deletedAt == nil
                && record.recordedAt >= start
                && record.recordedAt <= now
        }
    }
}
