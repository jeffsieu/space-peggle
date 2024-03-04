import Foundation

class Entity: Saveable, Hashable, Identifiable {
    var id: UUID
    var components: [ComponentId: AnyComponent]

    init(id: UUID = UUID(), components: [ComponentId: AnyComponent] = [:]) {
        self.id = id
        self.components = components
    }

    static func == (lhs: Entity, rhs: Entity) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    func clone(withId id: Entity.ID) -> Entity {
        Entity(id: id, components: components)
    }
}
