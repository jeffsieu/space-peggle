struct OrangeCirclePegPrefab: PlaceablePrefab {
    static let orangeCirclePegComponents: [any Component] = [
        Sprite(asset: .pegOrange,
               visualSize: Vector(x: 64, y: 64)),
        Peg(assetNormal: .pegOrange, assetGlow: .pegOrangeGlow, removeAfterTouch: true),
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
        WinningPeg()
    ]

    func create(transform: Transform) -> Entity {
        let peg = Entity()
        peg.assign(transform)
        Self.orangeCirclePegComponents.forEach { peg.assign($0) }
        return peg
    }

}
