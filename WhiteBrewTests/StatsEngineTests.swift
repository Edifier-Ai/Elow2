import XCTest
import SwiftData
@testable import WhiteBrew

final class StatsEngineTests: XCTestCase {
    func testSummaryCountsActiveDaysSpendAndCaffeine() {
        let calendar = Calendar(identifier: .gregorian)
        let first = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: 9))!
        let second = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 15))!
        let records = [
            DrinkRecord(category: .coffee, name: "Latte", style: "Latte", recordedAt: first, price: 30, rating: 5, caffeineMG: 90, sugarLevel: .low, beanOrBase: nil, temperature: .hot, sizeML: 300, mood: nil, tags: ["milk"], note: "", stickerID: nil),
            DrinkRecord(category: .milkTea, name: "Milk Tea", style: "Oolong", recordedAt: second, price: 20, rating: 4, caffeineMG: 40, sugarLevel: .half, beanOrBase: nil, temperature: .iced, sizeML: 500, mood: nil, tags: ["tea"], note: "", stickerID: nil)
        ]

        let summary = StatsEngine.summary(for: records, calendar: calendar)

        XCTAssertEqual(summary.totalCups, 2)
        XCTAssertEqual(summary.activeDays, 2)
        XCTAssertEqual(summary.totalSpend, 50)
        XCTAssertEqual(summary.averagePrice, 25)
        XCTAssertEqual(summary.totalCaffeineMG, 130)
        XCTAssertEqual(summary.preferredStyle, "Latte")
        XCTAssertEqual(summary.mostCommonTimeWindow, "Afternoon")
        XCTAssertEqual(summary.coffeeCount, 1)
        XCTAssertEqual(summary.milkTeaCount, 1)
    }

    func testSummaryIgnoresDeletedRecords() {
        let calendar = Calendar(identifier: .gregorian)
        let visibleDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: 9))!
        let deletedDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 2, hour: 15))!
        let deletedAt = calendar.date(from: DateComponents(year: 2026, month: 5, day: 3, hour: 8))!
        let records = [
            DrinkRecord(category: .coffee, name: "Latte", style: "Latte", recordedAt: visibleDate, price: 30, rating: 5, caffeineMG: 90, sugarLevel: .low, beanOrBase: nil, temperature: .hot, sizeML: 300, mood: nil, tags: ["milk"], note: "", stickerID: nil),
            DrinkRecord(category: .milkTea, name: "Deleted Tea", style: "Oolong", recordedAt: deletedDate, price: 20, rating: 4, caffeineMG: 40, sugarLevel: .half, beanOrBase: nil, temperature: .iced, sizeML: 500, mood: nil, tags: ["tea"], note: "", stickerID: nil, deletedAt: deletedAt),
            DrinkRecord(category: .coffee, name: "Deleted Espresso", style: "Espresso", recordedAt: deletedDate, price: 18, rating: 3, caffeineMG: 120, sugarLevel: .none, beanOrBase: nil, temperature: .hot, sizeML: 60, mood: nil, tags: [], note: "", stickerID: nil, deletedAt: deletedAt)
        ]

        let summary = StatsEngine.summary(for: records, calendar: calendar)

        XCTAssertEqual(summary.totalCups, 1)
        XCTAssertEqual(summary.activeDays, 1)
        XCTAssertEqual(summary.totalSpend, 30)
        XCTAssertEqual(summary.averagePrice, 30)
        XCTAssertEqual(summary.totalCaffeineMG, 90)
        XCTAssertEqual(summary.preferredStyle, "Latte")
        XCTAssertEqual(summary.mostCommonTimeWindow, "Morning")
        XCTAssertEqual(summary.coffeeCount, 1)
        XCTAssertEqual(summary.milkTeaCount, 0)
    }

    func testSummaryForEmptyInputReturnsZeroesAndNone() {
        let summary = StatsEngine.summary(for: [], calendar: Calendar(identifier: .gregorian))

        XCTAssertEqual(summary.totalCups, 0)
        XCTAssertEqual(summary.activeDays, 0)
        XCTAssertEqual(summary.totalSpend, 0)
        XCTAssertEqual(summary.averagePrice, 0)
        XCTAssertEqual(summary.totalCaffeineMG, 0)
        XCTAssertEqual(summary.preferredStyle, "None")
        XCTAssertEqual(summary.mostCommonTimeWindow, "None")
        XCTAssertEqual(summary.coffeeCount, 0)
        XCTAssertEqual(summary.milkTeaCount, 0)
    }

    func testSummaryTiesResolveDeterministically() {
        let calendar = Calendar(identifier: .gregorian)
        let morning = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: 9))!
        let afternoon = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1, hour: 15))!
        let records = [
            DrinkRecord(category: .coffee, name: "Morning Coffee", style: "Mocha", recordedAt: morning, price: 28, rating: 4, caffeineMG: 80, sugarLevel: .low, beanOrBase: nil, temperature: .hot, sizeML: 250, mood: nil, tags: [], note: "", stickerID: nil),
            DrinkRecord(category: .milkTea, name: "Afternoon Tea", style: "Americano", recordedAt: afternoon, price: 28, rating: 4, caffeineMG: 80, sugarLevel: .half, beanOrBase: nil, temperature: .iced, sizeML: 500, mood: nil, tags: [], note: "", stickerID: nil)
        ]

        let summary = StatsEngine.summary(for: records, calendar: calendar)

        XCTAssertEqual(summary.preferredStyle, "Americano")
        XCTAssertEqual(summary.mostCommonTimeWindow, "Afternoon")
    }

    func testPreviewDrinkRecordsPersistAndRoundTripDomainAccessors() throws {
        let schema = Schema([DrinkRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        let context = ModelContext(container)
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let records = PreviewData.records(now: now)
        let secondRecords = PreviewData.records(now: now)

        XCTAssertFalse(records[0] === secondRecords[0])

        records.forEach(context.insert)
        let clampedRecord = DrinkRecord(
            category: .milkTea,
            name: "Clamp Check",
            style: "Tea",
            recordedAt: now,
            price: 18,
            rating: 9,
            caffeineMG: nil,
            sugarLevel: .none,
            beanOrBase: nil,
            temperature: .room,
            sizeML: nil,
            mood: nil,
            tags: [],
            note: "",
            stickerID: nil,
            syncState: .pendingUpload
        )
        context.insert(clampedRecord)
        try context.save()

        let fetchedRecords = try context.fetch(FetchDescriptor<DrinkRecord>())
        let morningLatte = try XCTUnwrap(fetchedRecords.first { $0.name == "Morning Latte" })
        let oolongMilkTea = try XCTUnwrap(fetchedRecords.first { $0.name == "Oolong Milk Tea" })
        let fetchedClampedRecord = try XCTUnwrap(fetchedRecords.first { $0.name == "Clamp Check" })

        XCTAssertEqual(fetchedRecords.count, 3)
        XCTAssertEqual(fetchedClampedRecord.rating, 5)
        fetchedClampedRecord.rating = 99
        XCTAssertEqual(fetchedClampedRecord.rating, 5)
        XCTAssertEqual(morningLatte.category, .coffee)
        XCTAssertEqual(morningLatte.sugarLevel, .low)
        XCTAssertEqual(morningLatte.temperature, .hot)
        XCTAssertEqual(morningLatte.syncState, .localOnly)
        XCTAssertEqual(oolongMilkTea.category, .milkTea)
        XCTAssertEqual(oolongMilkTea.sugarLevel, .half)
        XCTAssertEqual(oolongMilkTea.temperature, .iced)

        fetchedClampedRecord.category = .coffee
        fetchedClampedRecord.sugarLevel = .regular
        fetchedClampedRecord.temperature = .hot
        fetchedClampedRecord.syncState = .synced

        XCTAssertEqual(fetchedClampedRecord.categoryRaw, DrinkCategory.coffee.rawValue)
        XCTAssertEqual(fetchedClampedRecord.sugarLevelRaw, SugarLevel.regular.rawValue)
        XCTAssertEqual(fetchedClampedRecord.temperatureRaw, DrinkTemperature.hot.rawValue)
        XCTAssertEqual(fetchedClampedRecord.syncStateRaw, SyncState.synced.rawValue)
    }

    func testMembershipStateRespectsAnnualExpiration() {
        let now = Date(timeIntervalSinceReferenceDate: 800_000_000)

        XCTAssertFalse(MembershipState.free.isMember(asOf: now))
        XCTAssertTrue(MembershipState.lifetime.isMember(asOf: now))
        XCTAssertTrue(MembershipState.annual(expiresAt: now.addingTimeInterval(3600)).isMember(asOf: now))
        XCTAssertFalse(MembershipState.annual(expiresAt: now.addingTimeInterval(-3600)).isMember(asOf: now))
    }
}
