import Foundation

struct BlueTrianglePegPrefab: PlaceablePrefab {
    static let triangleLength = 64.0
    static let triangleHeight = triangleLength * sqrt(3) / 2

    static let blueTrianglePegComponents: [any Component] = [
        Sprite(asset: .pegBlueTriangle,
               visualSize: Vector(x: triangleLength, y: triangleHeight)),
        Peg(assetNormal: .pegBlueTriangle, assetGlow: .pegBlueTriangleGlow, removeAfterTouch: true),
        PhysicsObject(
            mass: 10,
            velocity: Vector.zero,
            restitution: 1,
            collider: AnyCollider(PolygonCollider(points: [
                // Equilateral triangle
                Vector(x: -triangleLength / 2, y: triangleHeight / 2),
                Vector(x: 0, y: -triangleHeight / 2),
                Vector(x: triangleLength / 2, y: triangleHeight / 2)
            ])),
            collisionLayer: .peg,
            isKinematic: true,
            resolveCollisions: false,
            passThrough: false
        ),
        ScoringPeg(score: 100)
    ]

    func create(transform: Transform) -> Entity {
        let peg = Entity()
        peg.assign(transform)
        Self.blueTrianglePegComponents.forEach { peg.assign($0) }
        return peg
    }
}
