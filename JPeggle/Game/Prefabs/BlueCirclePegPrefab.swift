struct BlueCirclePegPrefab: PlaceablePrefab {
    static let blueCirclePegComponents: [any Component] = [
        Sprite(asset: .pegBlue,
               visualSize: Vector(x: 64, y: 64)),
        Peg(assetNormal: .pegBlue, assetGlow: .pegBlueGlow, removeAfterTouch: true),
        PhysicsObject(
            mass: 10,
            velocity: Vector.zero,
            restitution: 1,
            collider: AnyCollider(CircleCollider(radius: 32)),
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
        Self.blueCirclePegComponents.forEach { peg.assign($0) }
        return peg
    }

}
