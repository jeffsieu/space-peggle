struct PowerUpPeg: Component {
    static let id = ComponentId.powerUpPeg

    private (set) var active = true

    mutating func deactivate() {
        active = false
    }
}
