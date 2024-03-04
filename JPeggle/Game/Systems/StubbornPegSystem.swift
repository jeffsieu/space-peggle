struct StubbornPegSystem: System {
    func update(entities: inout Entities) {
        guard let delta = entities.single(Delta.self) else {
            return
        }

        let stubbornPegArchetype = makeArchetype(Transform.self, PhysicsObject.self, StubbornPeg.self)
        let stubbornPegs = entities.ofArchetype(stubbornPegArchetype)

        for stubbornPeg in stubbornPegs {
            let (transform, physicsObject, stubbornPegComponent) = stubbornPeg.components

            guard let desiredPosition = stubbornPegComponent.desiredPosition else {
                continue
            }

            let currentPosition = transform.origin
            let displacement = desiredPosition - currentPosition
            let impulseMagnitude = physicsObject.mass / 10 * displacement.magnitude() * displacement.magnitude() * delta.deltaMs

            let impulseTowardsDesiredPosition = displacement.normalized() * impulseMagnitude

            var newPhysicsObject = physicsObject
            newPhysicsObject.velocity *= stubbornPegComponent.dampingFactor
            newPhysicsObject.addImpulse(impulseTowardsDesiredPosition)
            stubbornPeg.entity.assign(newPhysicsObject)
        }
    }
}
