protocol SoundPlayer {
    func play(_ sound: SoundAsset)
}

struct Sounds: Component {
    static let id = ComponentId.sounds

    private (set) var soundsToPlay: [SoundAsset] = []

    mutating func play(sound: SoundAsset) {
        soundsToPlay.append(sound)
    }
}
