struct OutOfBoundsBallHandlingSystem: System {
    func update(entities: inout Entities) {
        let outOfBoundsBallArchetype = makeArchetype(OutOfBounds.self, CannonBall.self)
        let queryResults = entities.ofArchetype(outOfBoundsBallArchetype)
        let isSpookyActive = entities.containsSingle(SpookyActive.self)

        for result in queryResults {
            let entity = result.entity

            if !isSpookyActive {
                entity.assign(ShouldRemove())
            }

        }
    }
}
