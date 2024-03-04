struct HealthPegUpdatingSystem: System {
    func update(entities: inout Entities) {
        let healthPegArchetype = makeArchetype(Health.self, Peg.self)
        let healthPegs = entities.ofArchetype(healthPegArchetype)

        for healthPeg in healthPegs {
            let (health, peg) = healthPeg.components

            let removeAfterTouch = health.value <= 0

            if removeAfterTouch != peg.removeAfterTouch {
                var newPeg = peg
                newPeg.removeAfterTouch = removeAfterTouch
                healthPeg.entity.assign(newPeg)
            }
        }
    }
}
