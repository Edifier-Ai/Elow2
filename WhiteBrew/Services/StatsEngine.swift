import Foundation

struct StatsSummary: Equatable {
    let totalCups: Int
    let activeDays: Int
    let totalSpend: Decimal
    let averagePrice: Decimal
    let totalCaffeineMG: Int
    let preferredStyle: String
    let mostCommonTimeWindow: String
    let coffeeCount: Int
    let milkTeaCount: Int
}

enum StatsEngine {
    static func summary(for records: [DrinkRecord], calendar: Calendar = .current) -> StatsSummary {
        let visibleRecords = records.filter { $0.deletedAt == nil }
        let totalCups = visibleRecords.count
        let activeDays = Set(visibleRecords.map { calendar.startOfDay(for: $0.recordedAt) }).count
        let totalSpend = visibleRecords.reduce(Decimal.zero) { $0 + $1.price }
        let averagePrice = totalCups == 0 ? 0 : totalSpend / Decimal(totalCups)
        let totalCaffeine = visibleRecords.compactMap(\.caffeineMG).reduce(0, +)
        let preferredStyle = mostFrequent(visibleRecords.map(\.style)) ?? "None"
        let mostCommonTimeWindow = mostFrequent(visibleRecords.map { timeWindow(for: $0.recordedAt, calendar: calendar) }) ?? "None"
        let coffeeCount = visibleRecords.filter { $0.category == .coffee }.count
        let milkTeaCount = visibleRecords.filter { $0.category == .milkTea }.count

        return StatsSummary(
            totalCups: totalCups,
            activeDays: activeDays,
            totalSpend: totalSpend,
            averagePrice: averagePrice,
            totalCaffeineMG: totalCaffeine,
            preferredStyle: preferredStyle,
            mostCommonTimeWindow: mostCommonTimeWindow,
            coffeeCount: coffeeCount,
            milkTeaCount: milkTeaCount
        )
    }

    private static func mostFrequent(_ values: [String]) -> String? {
        values.reduce(into: [String: Int]()) { counts, value in
            counts[value, default: 0] += 1
        }
        .sorted { lhs, rhs in
            if lhs.value == rhs.value { return lhs.key < rhs.key }
            return lhs.value > rhs.value
        }
        .first?.key
    }

    private static func timeWindow(for date: Date, calendar: Calendar) -> String {
        let hour = calendar.component(.hour, from: date)
        switch hour {
        case 5..<12: return "Morning"
        case 12..<18: return "Afternoon"
        default: return "Evening"
        }
    }
}
