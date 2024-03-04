struct PegClearingSystem: System {
    func update(entities: inout Entities) {
        let pegClearingArchetype = makeArchetype(Peg.self)
        let cannonBallArchetype = makeArchetype(CannonBall.self)

        let queryResults = entities.ofArchetype(pegClearingArchetype)
        let cannonBalls = entities.ofArchetype(cannonBallArchetype)
        let haveCannonBalls = !cannonBalls.isEmpty
        let areCannonballsStuck = cannonBalls.allSatisfy {
            let (cannonBall) = $0.components
            return cannonBall.isStuck
        }

        guard !haveCannonBalls || areCannonballsStuck else {
            return
        }

        for result in queryResults {
            let (peg) = result.components

            guard peg.isTouched else {
                continue
            }

            guard peg.removeAfterTouch else {
                continue
            }

            result.entity.assign(ShouldRemove())
        }
    }
}
