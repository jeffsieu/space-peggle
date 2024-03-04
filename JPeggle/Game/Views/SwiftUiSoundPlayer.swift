import AVKit
import SwiftUI

class SwiftUISoundPlayer: SoundPlayer {
    var players: [SoundAsset: AVAudioPlayer?] = [:]

    private static let soundNames: [SoundAsset: String] = [
        .pegHit: "peg-hit"
    ]

    private func getSoundUrl(_ sound: SoundAsset) -> URL? {
        guard let soundName = Self.soundNames[sound] else {
            return nil
        }

        return Bundle.main.url(forResource: soundName, withExtension: "wav")
    }

    private func generateSoundPlayer(_ sound: SoundAsset) -> AVAudioPlayer? {
        guard let soundUrl = getSoundUrl(sound) else {
            return nil
        }

        do {
            return try AVAudioPlayer(contentsOf: soundUrl)
        } catch {
            return nil
        }
    }

    func initialize() {
        for sound in SoundAsset.allCases {
            players[sound] = generateSoundPlayer(sound)
        }
    }

    func play(_ sound: SoundAsset) {
        DispatchQueue.global().async {
            guard let player = self.players[sound] else {
                return
            }

            if player?.isPlaying == true {
                player?.stop()
            }

            player?.play()
        }
    }
}
