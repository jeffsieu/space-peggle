private func projectPoints(points: [Vector], onto axis: Vector) -> (min: Double, max: Double) {
    let dotProducts = points.map { $0.dot(axis) }
    return (dotProducts.min()!, dotProducts.max()!)
}

class CollisionResolver {
    static func getCollisionBetweenPolygons(
        _ polygon1: TransformedPolygonCollider, _ polygon2: TransformedPolygonCollider) -> Collision? {
        let points = polygon1.points
        let collisions: [Collision?] = (0..<points.count).map { i in
            let pointA = points[i]
            let pointB = points[(i + 1) % points.count]
            let edge = pointB - pointA
            let normal = Vector(x: -edge.y, y: edge.x).normalized()

            // project vertices
            let (minA, maxA) = projectPoints(points: points, onto: normal)
            let (minB, maxB) = projectPoints(points: polygon2.points, onto: normal)

            // check for overlap
            if maxA < minB || maxB < minA {
                return nil
            }

            let depth = min(maxB - minA, maxA - minB)

            return Collision(depth: depth, normal: normal)
        }

        if collisions.contains(where: { $0 == nil }) {
            return nil
        }

        let minCollision = collisions.compactMap { $0 }.min { $0.depth < $1.depth }

        return minCollision
    }

    static func getCollisionBetweenPolygonAndCircle(
        polygon: TransformedPolygonCollider, circle: TransformedCircleCollider) -> Collision? {
        let points = polygon.points
        let collisions: [Collision?] = (0..<points.count).map { i in
            let pointA = points[i]
            let pointB = points[(i + 1) % points.count]
            let edge = pointB - pointA
            let normal = Vector(x: -edge.y, y: edge.x).normalized()

            // project vertices
            let (minA, maxA) = projectPoints(points: points, onto: normal)
            let (minB, maxB) = projectPoints(points: [
                circle.origin + normal * circle.radius,
                circle.origin - normal * circle.radius
            ], onto: normal)

            // check for overlap
            if maxA < minB || maxB < minA {
                return nil
            }

            let depth = min(maxB - minA, maxA - minB)

            return Collision(depth: depth, normal: normal)
        }

        if collisions.contains(where: { $0 == nil }) {
            return nil
        }

        let minCollision = collisions.compactMap { $0 }.min { $0.depth < $1.depth }

        return minCollision
    }

    static func getCollisionBetweenCircles(
        _ circle1: TransformedCircleCollider, _ circle2: TransformedCircleCollider) -> Collision? {
        let distance = (circle1.origin - circle2.origin).magnitude()

        let depth = circle1.radius + circle2.radius - distance

        guard depth > 0 else {
            return nil
        }

        return Collision(depth: depth, normal: (circle2.origin - circle1.origin).normalized())
    }
}
