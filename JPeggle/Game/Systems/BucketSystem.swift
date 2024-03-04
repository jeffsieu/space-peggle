import Foundation

struct BucketSystem: System {
    func update(entities: inout Entities) {
        let bucketArchetype = makeArchetype(PhysicsObject.self, Bucket.self)
        let cannonBallArchetype = makeArchetype(CannonBall.self)

        let bucketResults = entities.ofArchetype(bucketArchetype)
        let cannonBallResults = entities.ofArchetype(cannonBallArchetype)
        let cannonBallIds = cannonBallResults.map { $0.entity.id }

        let sideWallResults = entities.ofArchetype(makeArchetype(SideWall.self))
        let sideWallIds = sideWallResults.map { $0.entity.id }

        var ballCount = entities.single(BallsLeft.self)?.count ?? 0

        bucketResults.forEach { result in
            let (physicsObject, bucket) = result.components

            var newBucket = bucket

            let collidedBodies = physicsObject.collisions.compactMap { $0.otherBody }
            let collidedWithVerticalWall = collidedBodies.contains(where: { sideWallIds.contains($0.id) })

            if collidedWithVerticalWall {
                newBucket.direction *= -1
                result.entity.assign(newBucket)
            }

            let collidedCannonBallIds = collidedBodies.filter { collidedBody in
                cannonBallIds.contains(collidedBody.id)
            }.map { $0.id }

            for cannonBallId in collidedCannonBallIds {
                let cannonBall = entities.get(withId: cannonBallId)
                cannonBall?.assign(ShouldRemove())
                ballCount += 1
            }

            var newPhysicsObject = physicsObject
            newPhysicsObject.velocity = newBucket.direction * 200

            result.entity.assign(newPhysicsObject)
        }

        entities.setSingle(BallsLeft(count: ballCount))
    }
}
