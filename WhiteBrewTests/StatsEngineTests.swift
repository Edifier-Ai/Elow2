import XCTest
import SwiftData
@testable import WhiteBrew

final class StatsEngineTests: XCTestCase {
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
