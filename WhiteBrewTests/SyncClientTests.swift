import XCTest
@testable import WhiteBrew

final class SyncClientTests: XCTestCase {
    func testPushRequestEncodesChangedRecords() throws {
        let id = UUID(uuidString: "9D912711-063A-4DCD-8236-D74242D69691")!
        let recordedAt = Date(timeIntervalSince1970: 1_780_000_000)
        let updatedAt = Date(timeIntervalSince1970: 1_780_000_500)
        let record = DrinkRecord(
            id: id,
            remoteID: "server-record-1",
            category: .coffee,
            name: "Flat White",
            style: "Flat White",
            recordedAt: recordedAt,
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
            stickerID: "foam-01",
            updatedAt: updatedAt
        )
        let request = SyncPushRequest(deviceId: "test-device", records: [.init(record: record)])

        let data = try JSONEncoder.whiteBrew.encode(request)
        let object = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [String: Any])
        let records = try XCTUnwrap(object["records"] as? [[String: Any]])
        let payload = try XCTUnwrap(records.first)

        XCTAssertEqual(object["deviceId"] as? String, "test-device")
        XCTAssertNil(object["deviceID"])
        XCTAssertEqual(payload["clientId"] as? String, id.uuidString)
        XCTAssertEqual(payload["id"] as? String, "server-record-1")
        XCTAssertNil(payload["remoteID"])
        XCTAssertNil(payload["caffeineMG"])
        XCTAssertNil(payload["sizeML"])
        XCTAssertNil(payload["stickerID"])
        XCTAssertEqual(payload["name"] as? String, "Flat White")
        XCTAssertEqual(payload["recordedAt"] as? String, ISO8601DateFormatter().string(from: recordedAt))
        XCTAssertEqual(payload["price"] as? NSNumber, 28)
        XCTAssertEqual(payload["caffeineMg"] as? NSNumber, 80)
        XCTAssertEqual(payload["sizeMl"] as? NSNumber, 250)
        XCTAssertEqual(payload["stickerId"] as? String, "foam-01")
        XCTAssertEqual(payload["tags"] as? [String], ["morning"])
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

        XCTAssertEqual(payload.clientId, id)
        XCTAssertEqual(payload.remoteId, "remote-1")
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

    func testPullResponseDecodesBackendShapedJSON() throws {
        let json = """
        {
          "cursor": "cursor-3",
          "records": [
            {
              "clientId": "9D912711-063A-4DCD-8236-D74242D69691",
              "id": "server-record-2",
              "category": "coffee",
              "name": "Americano",
              "style": "Long Black",
              "recordedAt": "2026-05-30T12:00:00Z",
              "price": 19.5,
              "rating": 4,
              "caffeineMg": 120,
              "sugarLevel": "none",
              "beanOrBase": "Blend",
              "temperature": "hot",
              "sizeMl": 300,
              "mood": "Steady",
              "tags": ["work", "morning"],
              "note": "Bright.",
              "stickerId": "spark-02",
              "updatedAt": "2026-05-30T12:10:00Z",
              "deletedAt": "2026-05-30T12:20:00Z"
            }
          ]
        }
        """

        let response = try JSONDecoder.whiteBrew.decode(SyncPullResponse.self, from: Data(json.utf8))
        let payload = try XCTUnwrap(response.records.first)

        XCTAssertEqual(response.cursor, "cursor-3")
        XCTAssertEqual(payload.clientId.uuidString, "9D912711-063A-4DCD-8236-D74242D69691")
        XCTAssertEqual(payload.remoteId, "server-record-2")
        XCTAssertEqual(payload.price, Decimal(string: "19.5"))
        XCTAssertEqual(payload.caffeineMG, 120)
        XCTAssertEqual(payload.sizeML, 300)
        XCTAssertEqual(payload.tags, ["work", "morning"])
        XCTAssertEqual(payload.stickerID, "spark-02")
        XCTAssertEqual(payload.deletedAt, ISO8601DateFormatter().date(from: "2026-05-30T12:20:00Z"))
    }
}
