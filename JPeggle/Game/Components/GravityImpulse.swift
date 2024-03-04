struct GravityImpulse: Component {
    static let id = ComponentId.gravityImpulse

    var g = Vector(x: 0, y: 9.81) * 10 / 3
}
