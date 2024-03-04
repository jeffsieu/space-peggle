import Foundation

struct PowerUpActivationSystem: System {
    private static let powerUpPegArchetype = makeArchetype(PowerUpPeg.self, Peg.self, PhysicsObject.self)
    private static let cannonBallArchetype = makeArchetype(CannonBall.self, Transform.self)
    private static let powerUpAction: [PowerUp: (inout Entities) -> Void] = [
        .kaboom: { entities in
            entities.setSingle(ShouldKaboom())
        },
        .spookyBall: { entities in
            entities.setSingle(SpookyActive(timeLeftMs: 10_000))
        },
        .duplicate: { entities in
            let cannonBalls = entities.ofArchetype(Self.cannonBallArchetype)
            for cannonBall in cannonBalls {
                let clonedCannonBall = cannonBall.entity.clone(withId: UUID())
                let (_, transform) = cannonBall.components
                var newTransform = transform
                newTransform.origin += Vector(x: 30, y: 30)
                clonedCannonBall.assign(newTransform)
                entities.add(clonedCannonBall)
            }
        }
    ]

    func update(entities: inout Entities) {
        let powerUpPegResults = entities.ofArchetype(Self.powerUpPegArchetype)
        let powerUpChoice = entities.single(PowerUpChoice.self)
        guard let powerUpChoice else {
            return
        }

        let powerUp = powerUpChoice.powerUp

        for result in powerUpPegResults {
            let pegEntity = result.entity
            let (powerUpPeg, peg, physicsObject) = result.components

            guard peg.isTouched && powerUpPeg.active else {
                continue
            }

            var newPowerUpPeg = powerUpPeg
            newPowerUpPeg.deactivate()
            pegEntity.assign(newPowerUpPeg)

            Self.powerUpAction[powerUp]?(&entities)
        }
    }
}
