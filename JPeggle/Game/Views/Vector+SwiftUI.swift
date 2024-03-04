import SwiftUI

extension Vector {
    func toCGPoint() -> CGPoint {
        CGPoint(x: x, y: y)
    }

    func toCGSize() -> CGSize {
        CGSize(width: x, height: y)
    }

    func toCGVector() -> CGVector {
        CGVector(dx: x, dy: y)
    }
}

extension CGSize {
    func toVector() -> Vector {
        Vector(x: width, y: height)
    }
}

extension CGPoint {
    func toVector() -> Vector {
        Vector(x: x, y: y)
    }
}

extension CGVector {
    func toVector() -> Vector {
        Vector(x: dx, y: dy)
    }
}
