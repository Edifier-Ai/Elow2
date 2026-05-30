import XCTest
@testable import WhiteBrew

final class PreviewDataTests: XCTestCase {
    func testShareCardTemplatesProvideCabinetPreviewData() {
        let templates = PreviewData.shareCardTemplates

        XCTAssertEqual(templates.map(\.name), ["Daily Cup", "Taste Notes", "Weekly Stack", "Gallery Render"])
        XCTAssertEqual(templates.map(\.isPremium), [false, false, true, true])
        XCTAssertTrue(templates.allSatisfy { !$0.id.isEmpty })
        XCTAssertTrue(templates.allSatisfy { !$0.description.isEmpty })
    }
}
