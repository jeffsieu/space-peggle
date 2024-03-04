struct StubbornPegInitializingSystem: System {
    func update(entities: inout Entities) {
        guard let delta = entities.single(Delta.self) else {
            return
        }

        let stubbornPegArchetype = makeArchetype(Transform.self, StubbornPeg.self)
        let stubbornPegs = entities.ofArchetype(stubbornPegArchetype)

        for stubbornPeg in stubbornPegs {
            let (transform, stubbornPegComponent) = stubbornPeg.components

            if stubbornPegComponent.desiredPosition == nil {
                var newStubbornPeg = stubbornPegComponent
                newStubbornPeg.desiredPosition = transform.origin
                stubbornPeg.entity.assign(newStubbornPeg)
            }
        }
    }
}
