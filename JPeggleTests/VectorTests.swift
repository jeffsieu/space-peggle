import XCTest
@testable import JPeggle

class VectorTests: XCTestCase {

    func testAddition() {
        let v1 = Vector(x: 3, y: 5)
        let v2 = Vector(x: 2, y: 7)
        let expectedSum = Vector(x: 5, y: 12)
        XCTAssertEqual(v1 + v2, expectedSum)
    }

    func testSubtraction() {
        let v1 = Vector(x: 10, y: 4)
        let v2 = Vector(x: 3, y: 2)
        let expectedDifference = Vector(x: 7, y: 2)
        XCTAssertEqual(v1 - v2, expectedDifference)
    }

    func testMultiplicationByScalar() {
        let v = Vector(x: 2, y: 6)
        let scalar = 3.0
        let expectedProduct = Vector(x: 6, y: 18)
        XCTAssertEqual(v * scalar, expectedProduct)
    }

    func testDivisionByScalar() {
        let v = Vector(x: 12, y: 8)
        let divisor = 4.0
        let expectedQuotient = Vector(x: 3, y: 2)
        XCTAssertEqual(v / divisor, expectedQuotient)
    }

    func testNegation() {
        let v = Vector(x: 4, y: -2)
        let expectedNegated = Vector(x: -4, y: 2)
        XCTAssertEqual(-v, expectedNegated)
    }

    func testMagnitude() {
        let v = Vector(x: 5, y: 12)
        XCTAssertEqual(v.magnitude(), 13)
    }

    func testNormalization() {
        let v = Vector(x: 6, y: 8)
        let expectedNormalized = Vector(x: 0.6, y: 0.8)
        XCTAssertEqual(v.normalized(), expectedNormalized)
    }

    func testDotProduct() {
        let v1 = Vector(x: 4, y: 3)
        let v2 = Vector(x: 2, y: 5)
        XCTAssertEqual(v1.dot(v2), 23)
    }

    func testProjection() {
        let v1 = Vector(x: 1, y: 1)
        let v2 = Vector(x: 1, y: 0)
        let expectedProjection = Vector(x: 1, y: 0)
        XCTAssertEqual(v1.projected(onto: v2), expectedProjection)
    }
}
