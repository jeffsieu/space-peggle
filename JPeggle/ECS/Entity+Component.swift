extension Entity {
    func getComponent<C: Component>(ofType componentType: C.Type) -> C? {
        components[componentType.id]?.component as? C
    }

    func assign<C: Component>(_ component: C) {
        components[component.id] = AnyComponent(component)
    }

    func hasComponent<C: Component>(ofType componentType: C.Type) -> Bool {
        getComponent(ofType: componentType) != nil
    }

    func unassign<C: Component>(ofType componentType: C.Type) {
        components[componentType.id] = nil
    }
}
