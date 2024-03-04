import XCTest

final class JPeggleLevelDesignerTests: XCTestCase {
    func testPlaceOrangePeg() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Level Designer"].exists)
        app.buttons["Level Designer"].tap()

        XCTAssert(app.buttons["peg-orange"].exists)
        XCTAssert(!app.images["peg-orange"].exists)

        app.buttons["peg-orange"].tap()

        let levelDesignerGameArea = app.otherElements["levelDesignerGameArea"]
        XCTAssert(levelDesignerGameArea.exists)

        levelDesignerGameArea.tap()

        XCTAssert(app.images["peg-orange"].exists)
    }
}
