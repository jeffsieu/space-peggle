import XCTest

final class JPeggleGameTests: XCTestCase {
    func testCannotStartGameWithoutOrangePeg() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Level Designer"].exists)
        app.buttons["Level Designer"].tap()

        XCTAssert(app.buttons["Start"].exists)
        XCTAssert(!app.otherElements["gameArea"].exists)

        app.buttons["Start"].tap()

        XCTAssert(app.alerts["Invalid level"].exists)
    }

    func testPlacePegAndStartGameContainingPeg() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Level Designer"].exists)
        app.buttons["Level Designer"].tap()
        app.buttons["peg-orange"].tap()
        let levelDesignerGameArea = app.otherElements["levelDesignerGameArea"]
        levelDesignerGameArea.tap()

        XCTAssert(app.buttons["Start"].exists)
        XCTAssert(!app.otherElements["gameArea"].exists)

        app.buttons["Start"].tap()

        XCTAssert(app.images["peg-orange"].exists)
    }

    func testFireButtonIsDisabledWithoutAiming() throws {
        let app = XCUIApplication()
        app.launch()

        XCTAssert(app.buttons["Level Designer"].exists)
        app.buttons["Level Designer"].tap()
        app.buttons["peg-orange"].tap()

        let levelDesignerGameArea = app.otherElements["levelDesignerGameArea"]
        levelDesignerGameArea.tap()

        app.buttons["Start"].tap()

        XCTAssertFalse(app.buttons["Fire"].isEnabled)
    }
}
