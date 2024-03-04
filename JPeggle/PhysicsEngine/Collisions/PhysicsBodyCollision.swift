struct PhysicsBodyCollision<Layer: CollisionLayer>: Hashable, Saveable {
    let depth: Double
    let normal: Vector
    weak var body: PhysicsBody<Layer>?
    weak var otherBody: PhysicsBody<Layer>?

    func reverse() -> PhysicsBodyCollision {
        PhysicsBodyCollision(depth: depth, normal: -normal, body: otherBody, otherBody: body)
    }
}
