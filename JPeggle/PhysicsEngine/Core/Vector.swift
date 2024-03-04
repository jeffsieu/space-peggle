struct Vector: Saveable, Hashable {
    let x: Double
    let y: Double

    static let zero = Vector(x: 0, y: 0)

    static func + (lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    static func += (lhs: inout Vector, rhs: Vector) {
        lhs = lhs + rhs
    }

    static func - (lhs: Vector, rhs: Vector) -> Vector {
        Vector(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func -= (lhs: inout Vector, rhs: Vector) {
        lhs = lhs - rhs
    }

    static func * (lhs: Vector, rhs: Double) -> Vector {
        Vector(x: lhs.x * rhs, y: lhs.y * rhs)
    }

    static func *= (lhs: inout Vector, rhs: Double) {
        lhs = lhs * rhs
    }

    static func * (lhs: Double, rhs: Vector) -> Vector {
        rhs * lhs
    }

    static func / (lhs: Vector, rhs: Double) -> Vector {
        guard rhs != 0 else { fatalError("Division by zero") }
        return Vector(x: lhs.x / rhs, y: lhs.y / rhs)
    }

    static prefix func - (vector: Vector) -> Vector {
        Vector(x: -vector.x, y: -vector.y)
    }

    func magnitude() -> Double {
        (x * x + y * y).squareRoot()
    }

    func normalized() -> Vector {
        if magnitude() == 0 {
            return Vector.zero
        }

        return self / magnitude()
    }

    func dot(_ other: Vector) -> Double {
        x * other.x + y * other.y
    }

    func projected(onto other: Vector) -> Vector {
        let otherNormalized = other.normalized()
        let scalar = dot(otherNormalized)
        return otherNormalized * scalar
    }
}
