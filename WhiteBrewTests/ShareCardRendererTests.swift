import XCTest
@testable import WhiteBrew

final class ShareCardRendererTests: XCTestCase {
    func testShareCardContentUsesRecordDetailsAndCaffeineFallback() {
        let record = DrinkRecord(
            category: .coffee,
            name: "Flat White",
            style: "Espresso Milk",
            recordedAt: Date(timeIntervalSince1970: 0),
            price: 28,
            rating: 4,
            caffeineMG: nil,
            sugarLevel: .low,
            beanOrBase: "Blend",
            temperature: .hot,
            sizeML: 220,
            mood: "Focused",
            tags: ["milk"],
            note: "Silky and clean.",
            stickerID: nil
        )

        let content = ShareCardContent(record: record)

        XCTAssertEqual(content.name, "Flat White")
        XCTAssertEqual(content.style, "Espresso Milk")
        XCTAssertEqual(content.ratingText, "4/5")
        XCTAssertEqual(content.caffeineText, "0 mg")
        XCTAssertEqual(content.sugarText, "Low")
        XCTAssertEqual(content.note, "Silky and clean.")
        XCTAssertEqual(content.brand, "White Brew")
    }

    @MainActor
    func testShareCardRendererCreatesFixedSizeImage() {
        let record = DrinkRecord(
            category: .milkTea,
            name: "Oolong Milk Tea",
            style: "Milk Tea",
            recordedAt: Date(timeIntervalSince1970: 0),
            price: 26,
            rating: 5,
            caffeineMG: 54,
            sugarLevel: .half,
            beanOrBase: "Oolong",
            temperature: .iced,
            sizeML: 500,
            mood: "Calm",
            tags: ["tea"],
            note: "Clean finish.",
            stickerID: nil
        )

        let image = ShareCardRenderer.image(for: record)

        XCTAssertNotNil(image)
        XCTAssertEqual(image?.size.width, 900)
        XCTAssertEqual(image?.size.height, 1_200)
        XCTAssertEqual(image?.scale, 2)
    }
}
