import Foundation

struct CannonPrefab {
    func create(at origin: Vector, towards aimPoint: Vector?) -> Entity {
        var aimAngle: Double {
            guard let aimPoint else {
                return 0
            }
            let x = aimPoint.x - origin.x
            let y = aimPoint.y - origin.y
            return atan2(y, x) - .pi / 2
        }

        let cannonComponents: [any Component] = [
            Sprite(asset: .cannonLoaded, visualSize: CannonBallPrefab.cannonBallSize * 2),
            Transform(origin: origin, rotation: aimAngle),
            Cannon(loadedAsset: .cannonLoaded, unloadedAsset: .cannonUnloaded)
        ]

        let entity = Entity()

        cannonComponents.forEach { entity.assign($0) }

        return entity
    }

}
