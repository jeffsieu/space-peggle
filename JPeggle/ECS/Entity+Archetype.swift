extension Entity {
    func fits(archetype: any Archetype) -> Bool {
        archetype.componentTypes.allSatisfy { componentType in
            hasComponent(ofType: componentType)
        }
    }

    func getComponentsOf<A: Archetype>(archetype: A) -> A.ComponentTuple? {
        archetype.query(entity: self)
    }
}
