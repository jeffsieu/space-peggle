struct CircleCollider: ColliderProtocol {
    static let colliderKind = ColliderKind.circle

    var radius: Double
    var center: Vector {
        Vector.zero
    }

    func withTransform(_ transform: Transform) -> any TransformedCollider {
        TransformedCircleCollider(collider: self, transform: transform)
    }
}

struct TransformedCircleCollider: TransformedCollider {
    var collider: CircleCollider
    var transform: Transform

    var radius: Double {
        assert(transform.scale.x == transform.scale.y)
        return collider.radius * transform.scale.x
    }

    var origin: Vector {
        transform.origin
    }

    func collide(with other: TransformedPolygonCollider) -> Collision? {
        CollisionResolver.getCollisionBetweenPolygonAndCircle(polygon: other, circle: self)
    }

    func collide(with other: TransformedCircleCollider) -> Collision? {
        CollisionResolver.getCollisionBetweenCircles(self, other)
    }

    func collide(with other: any TransformedCollider) -> Collision? {
        if let other = other as? TransformedCircleCollider {
            return collide(with: other)
        }

        if let other = other as? TransformedPolygonCollider {
            return collide(with: other)
        }

        return nil
    }
}
