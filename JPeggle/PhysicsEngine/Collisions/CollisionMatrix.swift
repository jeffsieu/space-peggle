struct CollisionMatrix<Layer: CollisionLayer>: Hashable, Saveable {
    private var matrix: [Layer: [Layer: Bool]] = [:]

    func canCollide(_ layerA: Layer, _ layerB: Layer) -> Bool {
        matrix[layerA]?[layerB] ?? false
    }

    mutating func _enableCollisions(between layerA: Layer, and layerB: Layer) {
        if matrix[layerA] == nil {
            matrix[layerA] = [:]
        }
        matrix[layerA]?[layerB] = true
    }

    mutating func enableCollisions(between layerA: Layer, and layerB: Layer) {
        _enableCollisions(between: layerA, and: layerB)
        _enableCollisions(between: layerB, and: layerA)
    }

    mutating func _disableCollisions(between layerA: Layer, and layerB: Layer) {
        if matrix[layerA] == nil {
            matrix[layerA] = [:]
        }
        matrix[layerA]?[layerB] = false
    }

    mutating func disableCollisions(between layerA: Layer, and layerB: Layer) {
        _disableCollisions(between: layerA, and: layerB)
        _disableCollisions(between: layerB, and: layerA)
    }
}
