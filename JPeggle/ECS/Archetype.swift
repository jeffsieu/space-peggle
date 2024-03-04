// swiftlint:disable large_tuple

protocol Archetype<ComponentTuple> {
    associatedtype ComponentTuple
    var componentTypes: [any Component.Type] { get }

    func query(entities: Entities) -> [QueryResult<ComponentTuple>]
    func query(entity: Entity) -> ComponentTuple?
}

struct Archetype1<C1: Component>: Archetype {
    let componentTypes: [any Component.Type]

    init(_ comp1: C1.Type) {
        componentTypes = [C1.self]
    }

    func query(entities: Entities) -> [QueryResult<C1>] {
        entities.all().compactMap { entity in
            guard let comp1 = entity.getComponent(ofType: C1.self) else {
                return nil
            }
            return QueryResult(entity: entity, components: comp1)
        }
    }

    func query(entity: Entity) -> (C1)? {
        guard let comp1 = entity.getComponent(ofType: C1.self) else {
            return nil
        }
        return comp1
    }
}

struct Archetype2<C1: Component, C2: Component>: Archetype {
    let componentTypes: [any Component.Type]

    init(_ comp1: C1.Type, _ comp2: C2.Type) {
        componentTypes = [C1.self, C2.self]
    }

    func query(entities: Entities) -> [QueryResult<(C1, C2)>] {
        entities.all().compactMap { entity in
            guard let comp1 = entity.getComponent(ofType: C1.self) else {
                return nil
            }

            guard let comp2 = entity.getComponent(ofType: C2.self) else {
                return nil
            }

            return QueryResult(entity: entity, components: (comp1, comp2))
        }
    }

    func query(entity: Entity) -> (C1, C2)? {
        guard let comp1 = entity.getComponent(ofType: C1.self) else {
            return nil
        }
        guard let comp2 = entity.getComponent(ofType: C2.self) else {
            return nil
        }
        return (comp1, comp2)
    }
}

struct Archetype3<C1: Component, C2: Component, C3: Component>: Archetype {
    let componentTypes: [any Component.Type]

    init(_ comp1: C1.Type, _ comp2: C2.Type, _ comp3: C3.Type) {
        componentTypes = [C1.self, C2.self, C3.self]
    }

    func query(entities: Entities) -> [QueryResult<(C1, C2, C3)>] {
        entities.all().compactMap { entity in
            guard let comp1 = entity.getComponent(ofType: C1.self) else {
                return nil
            }

            guard let comp2 = entity.getComponent(ofType: C2.self) else {
                return nil
            }

            guard let comp3 = entity.getComponent(ofType: C3.self) else {
                return nil
            }

            return QueryResult(entity: entity, components: (comp1, comp2, comp3))
        }
    }

    func query(entity: Entity) -> (C1, C2, C3)? {
        guard let comp1 = entity.getComponent(ofType: C1.self) else {
            return nil
        }
        guard let comp2 = entity.getComponent(ofType: C2.self) else {
            return nil
        }
        guard let comp3 = entity.getComponent(ofType: C3.self) else {
            return nil
        }
        return (comp1, comp2, comp3)
    }
}

struct Archetype4<C1: Component, C2: Component, C3: Component, C4: Component>: Archetype {
    let componentTypes: [any Component.Type]

    init(_ comp1: C1.Type, _ comp2: C2.Type, _ comp3: C3.Type, _ comp4: C4.Type) {
        componentTypes = [C1.self, C2.self, C3.self, C4.self]
    }

    func query(entities: Entities) -> [QueryResult<(C1, C2, C3, C4)>] {
        entities.all().compactMap { entity in
            guard let comp1 = entity.getComponent(ofType: C1.self) else {
                return nil
            }

            guard let comp2 = entity.getComponent(ofType: C2.self) else {
                return nil
            }

            guard let comp3 = entity.getComponent(ofType: C3.self) else {
                return nil
            }

            guard let comp4 = entity.getComponent(ofType: C4.self) else {
                return nil
            }

            return QueryResult(entity: entity, components: (comp1, comp2, comp3, comp4))
        }
    }

    func query(entity: Entity) -> (C1, C2, C3, C4)? {
        guard let comp1 = entity.getComponent(ofType: C1.self) else {
            return nil
        }
        guard let comp2 = entity.getComponent(ofType: C2.self) else {
            return nil
        }
        guard let comp3 = entity.getComponent(ofType: C3.self) else {
            return nil
        }
        guard let comp4 = entity.getComponent(ofType: C4.self) else {
            return nil
        }
        return (comp1, comp2, comp3, comp4)
    }
}

func makeArchetype<C1: Component>(_ comp1: C1.Type) -> Archetype1<C1> {
    Archetype1(comp1)
}

func makeArchetype<C1: Component, C2: Component>(_ comp1: C1.Type, _ comp2: C2.Type) -> Archetype2<C1, C2> {
    Archetype2(comp1, comp2)
}

func makeArchetype<C1: Component, C2: Component, C3: Component>(
    _ comp1: C1.Type, _ comp2: C2.Type, _ comp3: C3.Type) -> Archetype3<C1, C2, C3> {
    Archetype3(comp1, comp2, comp3)
}

func makeArchetype<C1: Component, C2: Component, C3: Component, C4: Component>(
    _ comp1: C1.Type, _ comp2: C2.Type, _ comp3: C3.Type, _ comp4: C4.Type) -> Archetype4<C1, C2, C3, C4> {
    Archetype4(comp1, comp2, comp3, comp4)
}

// swiftlint:enable large_tuple
