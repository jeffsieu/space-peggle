import Foundation

class PhysicsBody<Layer: CollisionLayer>: Hashable, Identifiable, Saveable {
    var id: UUID
    var mass: Double
    var velocity: Vector
    var restitution: Double
    var transform: Transform
    var collider: AnyCollider
    var collisionLayer: Layer
    var isKinematic: Bool
    var resolveCollisions: Bool
    var passThrough: Bool
    var impulses: [Vector]

    var centerOfMass: Vector {
        collider.collider.withTransform(transform).center
    }

    init(id: UUID,
         mass: Double,
         velocity: Vector,
         impulses: [Vector],
         restitution: Double,
         transform: Transform,
         collider: AnyCollider,
         collisionLayer: Layer,
         isKinematic: Bool,
         resolveCollisions: Bool,
         passThrough: Bool
    ) {
        self.id = id
        self.mass = mass
        self.restitution = restitution
        self.velocity = velocity
        self.impulses = impulses
        self.transform = transform
        self.collider = collider
        self.collisionLayer = collisionLayer
        self.isKinematic = isKinematic
        self.resolveCollisions = resolveCollisions
        self.passThrough = passThrough
    }

    func collide(with other: PhysicsBody<Layer>) -> PhysicsBodyCollision<Layer>? {
        let placedCollider = collider.collider.withTransform(transform)
        let otherPlacedCollider = other.collider.collider.withTransform(other.transform)
        guard let collision = placedCollider.collide(with: otherPlacedCollider) else {
            return nil
        }

        return PhysicsBodyCollision(
            depth: collision.depth,
            normal: collision.normal,
            body: self,
            otherBody: other
        )
    }

    static func == (lhs: PhysicsBody, rhs: PhysicsBody) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(mass)
        hasher.combine(restitution)
        hasher.combine(velocity)
        hasher.combine(impulses)
        hasher.combine(transform)
        hasher.combine(collider)
        hasher.combine(collisionLayer)
        hasher.combine(isKinematic)
        hasher.combine(resolveCollisions)
        hasher.combine(passThrough)
    }

    func clone() -> PhysicsBody<Layer> {
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
