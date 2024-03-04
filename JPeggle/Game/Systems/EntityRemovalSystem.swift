class EntityRemovalSystem: System {
    func update(entities: inout Entities) {
        let removableEntityArchetype = makeArchetype(ShouldRemove.self)
        let queryResults = entities.ofArchetype(removableEntityArchetype)
        queryResults.forEach { result in
            entities.remove(result.entity)
        }
    }
}
