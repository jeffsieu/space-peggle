struct StuckBallClearingSystem: System {
    private static let cannonBallArchetype = makeArchetype(CannonBall.self, PhysicsObject.self)
    private static let pegArchetype = makeArchetype(Peg.self)

    func update(entities: inout Entities) {
        let pegClearingArchetype = makeArchetype(Peg.self)
        let cannonBallArchetype = makeArchetype(CannonBall.self)

        let pegs = entities.ofArchetype(pegClearingArchetype)
        let cannonBalls = entities.ofArchetype(cannonBallArchetype)
        let areCannonballsStuck = cannonBalls.allSatisfy {
            let (cannonBall) = $0.components
            return cannonBall.isStuck
        }

        guard areCannonballsStuck else {
            return
        }

        let hasTouchedPeg = pegs.contains { peg in
            let (pegComponent) = peg.components
            return pegComponent.isTouched
        }

        guard !hasTouchedPeg else {
            return
        }

        for cannonBall in cannonBalls {
            cannonBall.entity.assign(ShouldRemove())

            if let health = cannonBall.entity.getComponent(ofType: Health.self) {
                if health.value <= 0 {
                    cannonBall.entity.assign(ShouldRemove())
                }
            } else {
                cannonBall.entity.assign(ShouldRemove())
            }
        }
    }
}
