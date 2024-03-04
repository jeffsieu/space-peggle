protocol ColliderProtocol: Saveable, Hashable {
    static var colliderKind: ColliderKind { get }

    func withTransform(_ transform: Transform) -> any TransformedCollider
    var center: Vector { get }
}

protocol TransformedCollider {
    associatedtype Collider: ColliderProtocol
    var collider: Collider { get }
    var transform: Transform { get }
    func collide(with other: any TransformedCollider) -> Collision?
}

extension TransformedCollider {
    var center: Vector {
        collider.center + transform.origin
    }
}
