struct Peg: Component {
    static let id = ComponentId.peg

    let assetNormal: DisplayableAsset
    let assetGlow: DisplayableAsset

    var removeAfterTouch: Bool
    var isTouched = false

    mutating func touch() {
        self.isTouched = true
    }
}
