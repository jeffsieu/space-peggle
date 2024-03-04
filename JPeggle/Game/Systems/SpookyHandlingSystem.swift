private let maximumYSpeed: Double = 3_000

struct SpookyHandlingSystem: System {
    func update(entities: inout Entities) {
        let isSpookyActive = entities.containsSingle(SpookyActive.self)

        updateTopWall(entities: &entities, isSpookyActive: isSpookyActive)
        updateBall(entities: &entities, isSpookyActive: isSpookyActive)
        updateSpookyTimeLeft(entities: &entities)
    }

    private func updateSpookyTimeLeft(entities: inout Entities) {
        let spookyActive = entities.single(SpookyActive.self)
        let delta = entities.single(Delta.self)

        guard let spookyActive, let delta else {
            return
        }

        let hasCannonBall = !entities.ofArchetype(makeArchetype(CannonBall.self)).isEmpty

        guard hasCannonBall else {
            entities.removeSingle(SpookyActive.self)
            return
        }

        var newSpookyActive = spookyActive
        newSpookyActive.timeLeftMs -= delta.deltaMs
        entities.setSingle(newSpookyActive)

        if newSpookyActive.timeLeftMs <= 0 {
            entities.removeSingle(SpookyActive.self)
        }
    }

    private func updateBall(entities: inout Entities, isSpookyActive: Bool) {
        // Update ball sprite
        let ballArchetype = makeArchetype(CannonBall.self, Sprite.self, PhysicsObject.self)

        let ballResults = entities.ofArchetype(ballArchetype)

        for result in ballResults {
            let (cannonBall, sprite, _) = result.components

            var newSprite = sprite
            newSprite.asset = isSpookyActive ? cannonBall.assetSpooky : cannonBall.assetNormal
            result.entity.assign(newSprite)
        }

        for result in ballResults {
            let (cannonBall, _, physicsObject) = result.components

            let yVelocity = physicsObject.velocity.y

            if yVelocity > maximumYSpeed {
                result.entity.assign(ShouldRemove())
            }
        }

        // Update ball transform
        guard isSpookyActive else {
            return
        }

        let outOfBoundsBallArchetype = makeArchetype(Transform.self, OutOfBounds.self, CannonBall.self)
        let topWallArchetype = makeArchetype(PhysicsObject.self, TopWall.self)

        let queryResults = entities.ofArchetype(outOfBoundsBallArchetype)

        let topWall = entities.firstOfArchetype(topWallArchetype)

        guard let topWall else {
            return
        }

        var (topWallPhysicsObject, _) = topWall.components
        topWallPhysicsObject.collisionLayer = .none

        for result in queryResults {
            let entity = result.entity
            let components = result.components
            let (transform, _, __) = components

            var newTransform = transform
            newTransform.origin = Vector(x: transform.origin.x, y: 0)
            entity.assign(newTransform)
            entity.unassign(ofType: OutOfBounds.self)
        }
    }

    private func updateTopWall(entities: inout Entities, isSpookyActive: Bool) {
        let topWallArchetype = makeArchetype(PhysicsObject.self, TopWall.self)
        let topWall = entities.firstOfArchetype(topWallArchetype)
        let bottomWallArchetype = makeArchetype(PhysicsObject.self, BottomWall.self)
        let bottomWall = entities.firstOfArchetype(bottomWallArchetype)

        guard let topWall, let bottomWall else {
            return
        }
        var (topWallPhysicsObject, _) = topWall.components
        var (bottomWallPhysicsObject, _) = bottomWall.components
        topWallPhysicsObject.passThrough = isSpookyActive
        bottomWallPhysicsObject.passThrough = isSpookyActive

        topWall.entity.assign(topWallPhysicsObject)
        bottomWall.entity.assign(bottomWallPhysicsObject)
    }
}
