struct OutOfBoundsDetectionSystem: System {
    func update(entities: inout Entities) {
        let cannonBallArcheType = makeArchetype(CannonBall.self, PhysicsObject.self)
        let bottomWallArcheType = makeArchetype(BottomWall.self, PhysicsObject.self)
        let cannonBallResults = entities.ofArchetype(cannonBallArcheType)
        let bottomWallResults = entities.ofArchetype(bottomWallArcheType)

        let boundIds = bottomWallResults.map { $0.entity.id }

        let outOfBoundBalls = cannonBallResults.filter {
            let (_, physicsObject) = $0.components
            return physicsObject.collisions.contains(where: {
                guard let otherBody = $0.otherBody else {
                    return false
                }
                return boundIds.contains(otherBody.id)
            })
        }

        for ball in outOfBoundBalls {
            ball.entity.assign(OutOfBounds())
        }
    }
}
