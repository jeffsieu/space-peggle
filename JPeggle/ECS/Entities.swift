import Foundation

struct Entities: Saveable, Hashable {
    private var entities: [Entity.ID: Entity]

    init() {
        self.entities = [:]
    }

    mutating func create() -> Entity {
        let entity = Entity(id: UUID(), components: [:])
        entities[entity.id] = entity

        return entity
    }

    mutating func add(_ entity: Entity) {
        entities[entity.id] = entity
    }

    mutating func setSingle<C: Component>(_ component: C) {
        let singleArcheType = makeArchetype(C.self)

        let existing = ofArchetype(singleArcheType)
        existing.forEach { remove($0.entity) }

        let newEntity = create()
        newEntity.assign(component)
        add(newEntity)
    }

    mutating func removeSingle<C: Component>(_ type: C.Type) {
        let singleArcheType = makeArchetype(C.self)
        let existing = ofArchetype(singleArcheType)
        existing.forEach { remove($0.entity) }
    }

    func containsSingle<C: Component>(_ type: C.Type) -> Bool {
        let singleArcheType = makeArchetype(C.self)
        let existing = ofArchetype(singleArcheType)
        return !existing.isEmpty
    }

    mutating func remove(_ entity: Entity) {
        entities.removeValue(forKey: entity.id)
    }

    mutating func remove(withId: Entity.ID) {
        entities.removeValue(forKey: withId)
    }

    func contains(withId id: Entity.ID) -> Bool {
        entities.keys.contains(id)
    }

    func ofArchetype<A: Archetype>(_ archetype: A) -> [QueryResult<A.ComponentTuple>] {
        archetype.query(entities: self)
    }

    func firstOfArchetype<A: Archetype>(_ archetype: A) -> QueryResult<A.ComponentTuple>? {
        archetype.query(entities: self).first
    }

    func single<C: Component>(_ type: C.Type) -> C? {
        let singleArcheType = makeArchetype(type)
        let existing = ofArchetype(singleArcheType)
        return existing.first?.components
    }

    func all() -> [Entity] {
        Array(entities.values)
    }

    func get(withId id: Entity.ID) -> Entity? {
        entities[id]
    }

    var isEmpty: Bool {
        entities.isEmpty
    }

    mutating func removeAll() {
        entities.removeAll()
    }
}
