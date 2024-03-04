struct CollisionSoundSystem: System {
    func update(entities: inout Entities) {
        let pegArchetype = makeArchetype(Peg.self, PhysicsObject.self)
        var sounds = entities.single(Sounds.self) ?? Sounds()
        let queryResults = entities.ofArchetype(pegArchetype)

        let isPegHit: Bool = queryResults.contains { result in
            let (peg, physicsObject) = result.components
            return !physicsObject.collisions.isEmpty
        }

        if isPegHit {
            sounds.play(sound: .pegHit)
            entities.setSingle(sounds)
        }
    }
}
