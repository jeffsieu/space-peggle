import Foundation

struct PhysicsWorld<Layer: CollisionLayer>: Hashable, Saveable {
    private struct CollisionPair: Hashable {
        let first: UUID
        let second: UUID
    }

    var collisionMatrix: CollisionMatrix<Layer>
    private(set) var bodies: [PhysicsBody<Layer>]
    private(set) var collisions: [PhysicsBodyCollision<Layer>]

    init(collisionMatrix: CollisionMatrix<Layer>, bodies: [PhysicsBody<Layer>] = []) {
        self.bodies = bodies
        self.collisions = []
        self.collisionMatrix = collisionMatrix

        update(deltaMs: 0)
    }

    mutating func addBody(_ body: PhysicsBody<Layer>) {
        bodies.append(body)
    }

    mutating func removeBodies(where shouldBeRemoved: (PhysicsBody<Layer>) -> Bool) {
        bodies.removeAll(where: shouldBeRemoved)
    }

    func getBody(id: UUID) -> PhysicsBody<Layer>? {
        bodies.first { $0.id == id }
    }

    mutating func update(deltaMs: Double) {
        let delta = deltaMs / 1_000
        collisions = []

        var collisionPairs: Set<CollisionPair> = []

        for body in bodies {
            let netImpulse = body.impulses.reduce(Vector.zero) { $0 + $1 }
            let effectiveInverseMass = body.isKinematic ? 0 : (1 / body.mass)
            let acceleration = netImpulse * effectiveInverseMass
            let originChange = body.velocity * delta + 0.5 * acceleration * delta * delta
            let velocityChange = acceleration * delta

            body.transform.origin += originChange
            body.velocity += velocityChange
        }

        for body in bodies {
            for otherBody in bodies {
                if body.id == otherBody.id {
                    continue
                }

                if !body.isKinematic && otherBody.isKinematic {
                    continue
                }

                if collisionPairs.contains(CollisionPair(first: body.id, second: otherBody.id)) {
                    continue
                }

                collisionPairs.insert(CollisionPair(first: body.id, second: otherBody.id))
                collisionPairs.insert(CollisionPair(first: otherBody.id, second: body.id))

                guard canBodiesCollide(body, otherBody) else {
                    continue
                }

                if let collision = body.collide(with: otherBody) {
                    collisions.append(collision)

                    if body.passThrough || otherBody.passThrough {
                        continue
                    }

                    updateVelocitiesAfterCollision(collision)
                }
            }
        }
    }

    func canBodiesCollide(_ bodyA: PhysicsBody<Layer>, _ bodyB: PhysicsBody<Layer>) -> Bool {
        collisionMatrix.canCollide(bodyA.collisionLayer, bodyB.collisionLayer)
    }

    mutating func updateVelocitiesAfterCollision(_ collision: PhysicsBodyCollision<Layer>) {
        guard let body = collision.body, let otherBody = collision.otherBody else {
            return
        }

        let centerBody = body.centerOfMass
        let centerOtherBody = otherBody.centerOfMass

        let directionToSelf = centerBody - centerOtherBody
        let undirectedNormal = collision.normal
        let isNormalPointingToSelf = directionToSelf.dot(undirectedNormal) > 0

        // Make normal point to self
        let normal = (isNormalPointingToSelf ? undirectedNormal : -undirectedNormal).normalized()

        let decollisionOffset = normal * collision.depth.magnitude

        let relativeVelocity = otherBody.velocity - body.velocity
        let velocityAlongNormal = relativeVelocity.dot(normal)

        let e = min(body.restitution, otherBody.restitution)
        var j = -(1 + e) * velocityAlongNormal
        let bodyInverseMass = body.isKinematic ? 0 : (1 / body.mass)
        let otherBodyInverseMass = otherBody.isKinematic ? 0 : (1 / otherBody.mass)
        j /= (bodyInverseMass + otherBodyInverseMass)

        let impulse = normal * j

        body.velocity -= impulse * bodyInverseMass
        otherBody.velocity += impulse * otherBodyInverseMass

        if !body.resolveCollisions && !otherBody.resolveCollisions {
            return
        }

        if !otherBody.resolveCollisions {
            body.transform.origin += decollisionOffset
        } else if !body.resolveCollisions {
            otherBody.transform.origin -= decollisionOffset
        } else {
            body.transform.origin += decollisionOffset / 2
            otherBody.transform.origin -= decollisionOffset / 2
        }
    }

    func getCollisions(body: PhysicsBody<Layer>) -> [PhysicsBodyCollision<Layer>] {
        let ownCollisions = collisions.filter { $0.body == body }
        let otherCollisions = collisions.filter { $0.otherBody == body }
        return ownCollisions + otherCollisions.map { $0.reverse() }
    }

    func getCollisions(bodyId: PhysicsBody<Layer>.ID) -> [PhysicsBodyCollision<Layer>] {
        guard let body = getBody(id: bodyId) else {
            return []
        }
        return getCollisions(body: body)
    }

    func clone() -> PhysicsWorld<Layer> {
        let clonedBodies = bodies.map { $0.clone() }
        let clonedWorld = PhysicsWorld(collisionMatrix: collisionMatrix, bodies: clonedBodies)

        return clonedWorld
    }
}
