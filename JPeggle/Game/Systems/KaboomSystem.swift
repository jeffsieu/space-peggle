struct KaboomSystem: System {
    private static let maxExplosionDistance = 200.0

    func update(entities: inout Entities) {
        let shouldKaboomArchetype = makeArchetype(Transform.self, ShouldKaboom.self, Peg.self)
        let physicsObjectArchetype = makeArchetype(PhysicsObject.self, Transform.self)
        let physicsObjectResults = entities.ofArchetype(physicsObjectArchetype)
        let toKaboomResults = entities.ofArchetype(shouldKaboomArchetype)

        for result in toKaboomResults {
            let kaboomEntity = result.entity
            let (kaboomTransform, _, peg) = result.components
            let explosionOrigin = kaboomTransform.origin

            kaboomEntity.unassign(ofType: ShouldKaboom.self)

            for affected in physicsObjectResults {
                let affectedEntity = affected.entity

                if affectedEntity.id == kaboomEntity.id {
                    continue
                }

                let (physicsObject, transform) = affected.components
                let distance = (transform.origin - explosionOrigin).magnitude()

                guard distance <= Self.maxExplosionDistance else {
                    continue
                }

                let affectedPeg = affectedEntity.getComponent(ofType: Peg.self)

                if var affectedPeg {
                    affectedPeg.touch()
                    affectedEntity.assign(affectedPeg)
                }

                let direction = (transform.origin - explosionOrigin).normalized()
                let impulse = direction * 1_000_000.0 * 1_000 / (distance * distance)
                var newPhysicsObject = physicsObject

                newPhysicsObject.addImpulse(impulse)

                affectedEntity.assign(newPhysicsObject)
            }
        }
    }
}
