struct StuckBallDetectionSystem: System {
    private static let cannonBallArchetype = makeArchetype(CannonBall.self, PhysicsObject.self)
    private static let deltaArchetype = makeArchetype(Delta.self)
    private static let slowThreshold = 100.0

    func update(entities: inout Entities) {
        let deltaMs = entities.firstOfArchetype(Self.deltaArchetype)?.components.deltaMs

        guard let deltaMs else {
            return
        }

        let queryResults = entities.ofArchetype(Self.cannonBallArchetype)

        for result in queryResults {
            var (cannonBall, physicsObject) = result.components

            let isSlow = physicsObject.velocity.magnitude() < Self.slowThreshold

            if isSlow {
                cannonBall.slowMovingDurationMs += deltaMs
            } else {
                cannonBall.slowMovingDurationMs = 0
            }

            cannonBall.isStuck = cannonBall.slowMovingDurationMs > 2_000

            result.entity.assign(cannonBall)
        }
    }
}
