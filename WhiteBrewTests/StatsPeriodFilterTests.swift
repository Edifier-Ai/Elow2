import XCTest
@testable import WhiteBrew

final class StatsPeriodFilterTests: XCTestCase {
    func testPeriodFilterIncludesStartThroughNowAndExcludesFutureRecords() {
        let calendar = Calendar(identifier: .gregorian)
        let now = calendar.date(from: DateComponents(year: 2026, month: 5, day: 31, hour: 12))!
        let start = calendar.date(byAdding: .day, value: -7, to: now)!
        let records = [
            makeRecord(name: "Before Start", recordedAt: calendar.date(byAdding: .second, value: -1, to: start)!),
            makeRecord(name: "At Start", recordedAt: start),
            makeRecord(name: "Past", recordedAt: calendar.date(byAdding: .day, value: -1, to: now)!),
            makeRecord(name: "Now", recordedAt: now),
            makeRecord(name: "Future", recordedAt: calendar.date(byAdding: .second, value: 1, to: now)!)
        ]

        let filtered = StatsPeriodFilter.records(in: .week, from: records, now: now, calendar: calendar)

        XCTAssertEqual(filtered.map(\.name), ["At Start", "Past", "Now"])
    }

    private func makeRecord(name: String, recordedAt: Date) -> DrinkRecord {
        DrinkRecord(
            category: .coffee,
            name: name,
            style: "Latte",
            recordedAt: recordedAt,
            price: 30,
            rating: 4,
            caffeineMG: 80,
            sugarLevel: .low,
            beanOrBase: nil,
            temperature: .hot,
            sizeML: 300,
            mood: nil,
            tags: [],
            note: "",
            stickerID: nil
        )
    }
}
