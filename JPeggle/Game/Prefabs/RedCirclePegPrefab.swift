struct RedCirclePegPrefab: PlaceablePrefab {
    static let redCirclePegComponents: [any Component] = [
        Sprite(asset: .pegRed,
               visualSize: Vector(x: 64, y: 64)),
        Peg(assetNormal: .pegRed, assetGlow: .pegRedGlow, removeAfterTouch: false),
        PhysicsObject(
            mass: 10,
            velocity: Vector.zero,
            restitution: 1,
            collider: AnyCollider(CircleCollider(radius: 32)),
            collisionLayer: .peg,
            isKinematic: false,
            resolveCollisions: true,
            passThrough: false
        ),
        StubbornPeg(dampingFactor: 0.9),
        ScoringPeg(score: 1_000)
    ]

    func create(transform: Transform) -> Entity {
        let peg = Entity()
        peg.assign(transform)
        Self.redCirclePegComponents.forEach { peg.assign($0) }
        return peg
    }

}
