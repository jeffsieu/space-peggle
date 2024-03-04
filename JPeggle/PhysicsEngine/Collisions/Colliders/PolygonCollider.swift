import Foundation

struct PolygonCollider: ColliderProtocol {

    static let colliderKind = ColliderKind.polygon

    var points: [Vector]

    init(points: [Vector]) {
        self.points = points
        assert(checkRepresentation())
    }

    var center: Vector {
        points.reduce(Vector.zero, +) / Double(points.count)
    }

    func withTransform(_ transform: Transform) -> any TransformedCollider {
        TransformedPolygonCollider(collider: self, transform: transform)
    }

    func checkRepresentation() -> Bool {
        points.count >= 3
    }
}

struct TransformedPolygonCollider: TransformedCollider {
    var collider: PolygonCollider
    var transform: Transform

    var points: [Vector] {
        collider.points.map { point in
            let scaledPoint = Vector(
                x: point.x * transform.scale.x,
                y: point.y * transform.scale.y
            )

            let originalAngle = atan2(scaledPoint.y, scaledPoint.x)
            let originalMagnitude = scaledPoint.magnitude()
            let rotatedAngle = originalAngle + transform.rotation
            let rotatedVector = Vector(x: cos(rotatedAngle), y: sin(rotatedAngle)) * originalMagnitude
            return rotatedVector + transform.origin
        }
    }

    func collide(with other: TransformedPolygonCollider) -> Collision? {
        CollisionResolver.getCollisionBetweenPolygons(self, other)
    }

    func collide(with other: TransformedCircleCollider) -> Collision? {
        CollisionResolver.getCollisionBetweenPolygonAndCircle(polygon: self, circle: other)
    }

    func collide(with other: any TransformedCollider) -> Collision? {
        if let other = other as? TransformedCircleCollider {
            return collide(with: other)
        }

        if let other = other as? TransformedPolygonCollider {
            return collide(with: other)
        }

        return nil
    }
}
