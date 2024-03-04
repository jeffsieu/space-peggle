import Foundation

struct RedTrianglePegPrefab: PlaceablePrefab {
    static let triangleLength = 64.0
    static let triangleHeight = triangleLength * sqrt(3) / 2

    static let redTrianglePegComponents: [any Component] = [
        Sprite(asset: .pegRedTriangle,
               visualSize: Vector(x: triangleLength, y: triangleHeight)),
        Peg(assetNormal: .pegRedTriangle, assetGlow: .pegRedTriangleGlow, removeAfterTouch: true),
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
        StubbornPeg(dampingFactor: 0.9),
        ScoringPeg(score: 1_000)
    ]

    func create(transform: Transform) -> Entity {
        let peg = Entity()
        peg.assign(transform)
        Self.redTrianglePegComponents.forEach { peg.assign($0) }
        return peg
    }
}
