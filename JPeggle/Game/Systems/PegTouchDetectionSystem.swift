struct PegTouchDetectionSystem: System {
    func update(entities: inout Entities) {
        let pegLightingArchetype = makeArchetype(Peg.self, PhysicsObject.self)
        let pegResults = entities.ofArchetype(pegLightingArchetype)
        pegResults.forEach { peg in
            let entity = peg.entity
            let (peg, physicsObject) = peg.components
            let hasCollision = !physicsObject.collisions.isEmpty

            if hasCollision {
                var newPeg = peg
                newPeg.touch()
                entity.assign(newPeg)

                if let health = entity.getComponent(ofType: Health.self) {
                    var newHealth = health
                    newHealth.value -= 10
                    entity.assign(newHealth)
                }
            }
        }
    }
}
