import Foundation

struct BucketPrefab: PlaceablePrefab {
    private static let bucketSize = CannonBallPrefab.cannonBallSize * 2
    private static let colliderThickness = 10.0
    private static let colliderYOffset = 40.0
    private static let bucketComponents: [any Component] = [
        Bucket(direction: Vector(x: 1, y: 0)),
        Sprite(asset: .bucket, visualSize: bucketSize),
        ZIndex(value: 0),
        PhysicsObject(
            mass: 10,
            velocity: Vector(x: 200, y: 0),
            restitution: 1,
            collider: AnyCollider(PolygonCollider(points: [
                Vector(x: -bucketSize.x / 2, y: -bucketSize.y / 2 + colliderYOffset),
                Vector(x: -bucketSize.x / 2, y: -bucketSize.y / 2 + colliderYOffset + colliderThickness),
                Vector(x: bucketSize.x / 2, y: -bucketSize.y / 2 + colliderYOffset + colliderThickness),
                Vector(x: bucketSize.x / 2, y: -bucketSize.y / 2 + colliderYOffset)
            ])),
            collisionLayer: .bucket,
            isKinematic: true,
            resolveCollisions: true,
            passThrough: true
        )
    ]

    func create(transform: Transform) -> Entity {
        let entity = Entity()
        entity.assign(transform)

        Self.bucketComponents.forEach { entity.assign($0) }

        return entity
    }
}
