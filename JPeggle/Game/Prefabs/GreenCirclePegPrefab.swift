struct GreenCirclePegPrefab: PlaceablePrefab {
    static let greenCirclePegComponents: [any Component] = [
        Sprite(asset: .pegGreen,
               visualSize: Vector(x: 64, y: 64)),
        Peg(assetNormal: .pegGreen, assetGlow: .pegGreenGlow, removeAfterTouch: true),
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
        PowerUpPeg(),
        ScoringPeg(score: 500)
    ]

    func create(transform: Transform) -> Entity {
        let peg = Entity()
        peg.assign(transform)
        Self.greenCirclePegComponents.forEach { peg.assign($0) }
        return peg
    }
}
