import Foundation

extension PhysicsObject {
    func createPhysicsBody(withId id: UUID, transform: Transform) -> PhysicsBody<Layer> {
        PhysicsBody(
            id: id,
            mass: mass,
            velocity: velocity,
            impulses: impulses,
            restitution: restitution,
            transform: transform,
            collider: collider,
            collisionLayer: collisionLayer,
            isKinematic: isKinematic,
            resolveCollisions: resolveCollisions,
            passThrough: passThrough
        )
    }
}

extension PhysicsBody where Layer == GameCollisionLayer {
    func toPhysicsObject(withCollisions collisions: [PhysicsBodyCollision<Layer>]) -> PhysicsObject {
        PhysicsObject(
            mass: mass,
            velocity: velocity,
            restitution: restitution,
            collider: collider,
            collisionLayer: collisionLayer,
            isKinematic: isKinematic,
            resolveCollisions: resolveCollisions,
            passThrough: passThrough,
            collisions: collisions
        )
    }
}
