struct CannonBall: Component {
    static let id = ComponentId.cannonBall

    var slowMovingDurationMs: Double = 0
    var isStuck = false

    let assetNormal: DisplayableAsset
    let assetSpooky: DisplayableAsset
}
