import Foundation

struct CannonBallPrefab {
    private static let cannonBallComponents: [any Component] = [
        Sprite(asset: .cannonBall,
               visualSize: Vector(x: 64, y: 64)),
        ZIndex(value: 3),
        GravityImpulse(),
        CannonBall(assetNormal: .cannonBall, assetSpooky: .cannonBallSpooky)
    ]

    static var cannonBallSize: Vector {
        let sprite = Self.cannonBallComponents.compactMap { $0 as? Sprite }.first
        return sprite?.visualSize ?? Vector.zero
    }

    func create(transform: Transform, initialVelocity: Vector) -> Entity {
        let entity = Entity()
        entity.assign(transform)

        Self.cannonBallComponents.forEach { entity.assign($0) }

        entity.assign(PhysicsObject(
            mass: 10,
            velocity: initialVelocity,
            restitution: 0.5,
            collider: AnyCollider(CircleCollider(radius: 32)),
            collisionLayer: .cannonBall,
            isKinematic: false,
            resolveCollisions: true,
            passThrough: false
        ))

        return entity
    }
}
