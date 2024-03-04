struct Transform: Component {
    static let id = ComponentId.transform

    var origin: Vector
    var rotation: Double
    var scale: Vector

    init(origin: Vector = Vector.zero, rotation: Double = 0.0, scale: Vector = Vector(x: 1, y: 1)) {
        self.origin = origin
        self.rotation = rotation
        self.scale = scale
    }
}
