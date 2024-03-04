struct StubbornPeg: Component {
    static let id = ComponentId.stubbornPeg

    var desiredPosition: Vector?
    let dampingFactor: Double
}
