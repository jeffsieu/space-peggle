struct BlockPrefab: PlaceablePrefab {
    static let blockComponents: [any Component] = [
        Sprite(asset: .block,
               visualSize: Vector(x: 64, y: 64)),
        PhysicsObject(
            mass: 10,
            velocity: Vector.zero,
            restitution: 1,
            collider: AnyCollider(PolygonCollider(points: [
                Vector(x: -32, y: -32),
                Vector(x: 32, y: -32),
                Vector(x: 32, y: 32),
                Vector(x: -32, y: 32)
            ])),
            collisionLayer: .block,
            isKinematic: true,
            resolveCollisions: false,
            passThrough: false
        ),
        Block(),
        FreelyResizable()
    ]

    func create(transform: Transform) -> Entity {
        let entity = Entity()
        entity.assign(transform)
        Self.blockComponents.forEach { entity.assign($0) }
        return entity
    }
}
