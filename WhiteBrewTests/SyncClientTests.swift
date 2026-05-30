import XCTest
@testable import WhiteBrew

final class SyncClientTests: XCTestCase {
    func testPushRequestEncodesChangedRecords() throws {
        let record = DrinkRecord(
            category: .coffee,
            name: "Flat White",
            style: "Flat White",
            recordedAt: Date(timeIntervalSince1970: 1_780_000_000),
            price: 28,
            rating: 5,
            caffeineMG: 80,
            sugarLevel: .none,
            beanOrBase: "Blend",
            temperature: .hot,
            sizeML: 250,
            mood: "Clear",
            tags: ["morning"],
            note: "Clean milk.",
            stickerID: "foam-01"
        )
        let request = SyncPushRequest(deviceID: "test-device", records: [.init(record: record)])

        let data = try JSONEncoder.whiteBrew.encode(request)
        let json = String(decoding: data, as: UTF8.self)

        XCTAssertTrue(json.contains("Flat White"))
        XCTAssertTrue(json.contains("test-device"))
    }

    func testRecordPayloadMapsSyncFieldsAndTombstone() {
        let id = UUID(uuidString: "9D912711-063A-4DCD-8236-D74242D69691")!
        let recordedAt = Date(timeIntervalSince1970: 1_780_000_000)
        let updatedAt = Date(timeIntervalSince1970: 1_780_000_500)
        let deletedAt = Date(timeIntervalSince1970: 1_780_001_000)
        let record = DrinkRecord(
            id: id,
            remoteID: "remote-1",
            category: .milkTea,
            name: "Oolong Milk Tea",
            style: "Oolong",
            recordedAt: recordedAt,
            price: Decimal(string: "22.50")!,
            rating: 4,
            caffeineMG: nil,
            sugarLevel: .half,
            beanOrBase: "Oolong",
            temperature: .iced,
            sizeML: 500,
            mood: nil,
            tags: ["tea", "afternoon"],
            note: "Light roast.",
            stickerID: nil,
            updatedAt: updatedAt,
            deletedAt: deletedAt
        )

        let payload = SyncRecordPayload(record: record)

        XCTAssertEqual(payload.id, id)
        XCTAssertEqual(payload.remoteID, "remote-1")
        XCTAssertEqual(payload.category, "milkTea")
        XCTAssertEqual(payload.recordedAt, recordedAt)
        XCTAssertEqual(payload.price, Decimal(string: "22.50"))
        XCTAssertEqual(payload.sugarLevel, "half")
        XCTAssertEqual(payload.temperature, "iced")
        XCTAssertEqual(payload.updatedAt, updatedAt)
        XCTAssertEqual(payload.deletedAt, deletedAt)
    }

    func testWhiteBrewCoderRoundTripsISO8601Dates() throws {
        let record = DrinkRecord(
            category: .coffee,
            name: "Espresso",
            style: "Espresso",
            recordedAt: Date(timeIntervalSince1970: 1_780_000_000),
            price: Decimal(string: "18.75")!,
            rating: 5,
            caffeineMG: 90,
            sugarLevel: .none,
            beanOrBase: "Single Origin",
            temperature: .hot,
            sizeML: 40,
            mood: "Focused",
            tags: [],
            note: "",
            stickerID: nil,
            updatedAt: Date(timeIntervalSince1970: 1_780_000_600)
        )
        let response = SyncPullResponse(cursor: "cursor-2", records: [.init(record: record)])

        let data = try JSONEncoder.whiteBrew.encode(response)
        let decoded = try JSONDecoder.whiteBrew.decode(SyncPullResponse.self, from: data)

        XCTAssertEqual(decoded, response)
    }
}
