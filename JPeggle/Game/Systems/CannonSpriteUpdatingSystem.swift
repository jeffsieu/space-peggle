import Foundation

struct CannonSpriteUpdatingSystem: System {
    func update(entities: inout Entities) {
        let cannonArchetype = makeArchetype(Cannon.self, Sprite.self, Transform.self)
        let aimPointArchetype = makeArchetype(AimPoint.self)

        let queryResults = entities.ofArchetype(cannonArchetype)
        let aimPoint = entities.firstOfArchetype(aimPointArchetype)

        queryResults.forEach { result in
            let (cannon, sprite, transform) = result.components

            guard let target = aimPoint?.components.origin else {
                return
            }

            guard let canShoot = aimPoint?.components.canShoot else {
                return
            }

            let x = target.x - transform.origin.x
            let y = target.y - transform.origin.y

            let aimAngle = atan2(y, x) - Double.pi / 2
            var newTransform = transform
            newTransform.rotation = aimAngle
            result.entity.assign(newTransform)

            if canShoot {
                result.entity.assign(Sprite(asset: cannon.loadedAsset, visualSize: sprite.visualSize))
            } else {
                result.entity.assign(Sprite(asset: cannon.unloadedAsset, visualSize: sprite.visualSize))
            }
        }
    }
}
