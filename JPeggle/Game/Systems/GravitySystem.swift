struct GravitySystem: System {
    func update(entities: inout Entities) {
        guard let delta = entities.single(Delta.self) else {
            return
        }

        let gravityReceivingArchetype = makeArchetype(PhysicsObject.self, GravityImpulse.self)
        let gravityReceivingResults = entities.ofArchetype(gravityReceivingArchetype)

        for result in gravityReceivingResults {
            let (physicsObject, gravityImpulse) = result.components

            var newPhysicsObject = physicsObject
            newPhysicsObject.addImpulse(gravityImpulse.g * delta.deltaMs * physicsObject.mass)
            result.entity.assign(newPhysicsObject)
        }
    }
}
