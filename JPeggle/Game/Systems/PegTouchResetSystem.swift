struct PegTouchResetSystem: System {
    func update(entities: inout Entities) {
        let pegLightingArchetype = makeArchetype(Peg.self)
        let pegResults = entities.ofArchetype(pegLightingArchetype)
        let cannonBallArchetype = makeArchetype(CannonBall.self)
        let hasCannonBalls = !entities.ofArchetype(cannonBallArchetype)
            .filter { !$0.entity.hasComponent(ofType: ShouldRemove.self) }
            .isEmpty

        guard !hasCannonBalls else {
            return
        }

        for peg in pegResults {
            let entity = peg.entity
            var (pegComponent) = peg.components
            pegComponent.isTouched = false

            entity.assign(pegComponent)
        }
    }
}
