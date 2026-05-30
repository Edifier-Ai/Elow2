import SwiftData
import XCTest
@testable import WhiteBrew

final class DrinkFormStateTests: XCTestCase {
    func testSaveNewRecordTrimsRequiredFieldsAndMarksPendingUpload() throws {
        let context = try makeContext()
        var form = DrinkFormState(now: fixedDate)
        form.category = .milkTea
        form.name = "  Oolong Cloud  "
        form.style = "  Milk Tea  "
        form.priceText = "26.5"
        form.rating = 5
        form.caffeineText = "54"
        form.sugarLevel = .half
        form.beanOrBase = "  Oolong  "
        form.temperature = .iced
        form.sizeText = "500"
        form.mood = "  Calm  "
        form.tagsText = "tea, iced, tea"
        form.note = "  Clean finish.  "
        form.stickerID = "latte-arch"

        let saved = try form.save(record: nil, in: context, now: savedDate)
        try context.save()

        XCTAssertEqual(saved.name, "Oolong Cloud")
        XCTAssertEqual(saved.style, "Milk Tea")
        XCTAssertEqual(saved.category, .milkTea)
        XCTAssertEqual(saved.price, Decimal(string: "26.5"))
        XCTAssertEqual(saved.rating, 5)
        XCTAssertEqual(saved.caffeineMG, 54)
        XCTAssertEqual(saved.sugarLevel, .half)
        XCTAssertEqual(saved.beanOrBase, "Oolong")
        XCTAssertEqual(saved.temperature, .iced)
        XCTAssertEqual(saved.sizeML, 500)
        XCTAssertEqual(saved.mood, "Calm")
        XCTAssertEqual(saved.tags, ["tea", "iced"])
        XCTAssertEqual(saved.note, "Clean finish.")
        XCTAssertEqual(saved.stickerID, "latte-arch")
        XCTAssertEqual(saved.recordedAt, fixedDate)
        XCTAssertEqual(saved.createdAt, savedDate)
        XCTAssertEqual(saved.updatedAt, savedDate)
        XCTAssertEqual(saved.syncState, .pendingUpload)
        XCTAssertNil(saved.deletedAt)
    }

    func testSaveExistingRecordMutatesRecordAndPreservesCreatedAt() throws {
        let context = try makeContext()
        let createdAt = Date(timeIntervalSinceReferenceDate: 10)
        let record = DrinkRecord(
            category: .coffee,
            name: "Latte",
            style: "Latte",
            recordedAt: fixedDate,
            price: 30,
            rating: 4,
            caffeineMG: 80,
            sugarLevel: .low,
            beanOrBase: "Blend",
            temperature: .hot,
            sizeML: 300,
            mood: "Focused",
            tags: ["milk"],
            note: "Original",
            stickerID: "foam-01",
            createdAt: createdAt,
            updatedAt: createdAt,
            syncState: .synced
        )
        context.insert(record)
        var form = DrinkFormState(record: record)
        form.name = "Flat White"
        form.style = "White Coffee"
        form.priceText = "34"
        form.tagsText = "milk, smooth"

        let saved = try form.save(record: record, in: context, now: savedDate)

        XCTAssertTrue(saved === record)
        XCTAssertEqual(record.name, "Flat White")
        XCTAssertEqual(record.style, "White Coffee")
        XCTAssertEqual(record.price, 34)
        XCTAssertEqual(record.tags, ["milk", "smooth"])
        XCTAssertEqual(record.createdAt, createdAt)
        XCTAssertEqual(record.updatedAt, savedDate)
        XCTAssertEqual(record.syncState, .pendingUpload)
    }

    func testSaveRequiresNameAndStyle() throws {
        let context = try makeContext()
        var missingName = DrinkFormState(now: fixedDate)
        missingName.name = " "
        missingName.style = "Latte"

        XCTAssertThrowsError(try missingName.save(record: nil, in: context, now: savedDate)) { error in
            XCTAssertEqual(error as? DrinkFormValidationError, .missingName)
        }

        var missingStyle = DrinkFormState(now: fixedDate)
        missingStyle.name = "Latte"
        missingStyle.style = " "

        XCTAssertThrowsError(try missingStyle.save(record: nil, in: context, now: savedDate)) { error in
            XCTAssertEqual(error as? DrinkFormValidationError, .missingStyle)
        }
    }

    private var fixedDate: Date {
        Date(timeIntervalSinceReferenceDate: 800_000_000)
    }

    private var savedDate: Date {
        Date(timeIntervalSinceReferenceDate: 800_000_100)
    }

    private func makeContext() throws -> ModelContext {
        let schema = Schema([DrinkRecord.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        return ModelContext(container)
    }
}
