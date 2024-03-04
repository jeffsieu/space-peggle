struct PegLightingSystem: System {
    func update(entities: inout Entities) {
        let pegLightingArchetype = makeArchetype(Peg.self, Sprite.self, PhysicsObject.self)
        let queryResults = entities.ofArchetype(pegLightingArchetype)

        queryResults.forEach { result in
            let entity = result.entity
            let (peg, sprite, _) = result.components

            let asset = peg.isTouched ? peg.assetGlow : peg.assetNormal
            var newSprite = sprite
            newSprite.asset = asset

            entity.assign(newSprite)
        }
    }
}
