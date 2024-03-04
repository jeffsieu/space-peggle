protocol SpriteDisplayer<Output> {
    associatedtype Output
    func display(_ object: Sprite) -> Output
}

struct Sprite: Component {
    static let id = ComponentId.sprite

    var asset: DisplayableAsset
    let visualSize: Vector
    func display<T>(using adapter: any SpriteDisplayer<T>) -> T {
        adapter.display(self)
    }
}
