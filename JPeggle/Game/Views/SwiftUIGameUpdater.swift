import SwiftUI

class SwiftUIGameUpdater: ObservableObject {
    @Published var gameState: GameState

    var displayLink: CADisplayLink?

    init(gameState: GameState) {
        self.gameState = gameState
    }

    func createDisplayLink() {
        displayLink = CADisplayLink(target: self,
                                    selector: #selector(update))
        displayLink?.add(to: .current, forMode: .default)
    }

    func removeDisplayLink() {
        displayLink?.invalidate()
    }

    @objc func update(displayLink: CADisplayLink) {
        let elapsedDurationSeconds = displayLink.targetTimestamp - displayLink.timestamp
        let deltaMs = elapsedDurationSeconds * 1_000
        gameState.update(deltaMs: deltaMs)
    }
}
