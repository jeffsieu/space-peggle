protocol Component: Saveable, Hashable {
    static var id: ComponentId { get }
    var id: ComponentId { get }
}
