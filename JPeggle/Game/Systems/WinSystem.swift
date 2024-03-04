import Foundation

struct WinSystem: System {
    func update(entities: inout Entities) {
        let winningPegArchetype = makeArchetype(WinningPeg.self)

        let winningPegResults = entities.ofArchetype(winningPegArchetype)

        if winningPegResults.isEmpty {
            entities.setSingle(GameStatus.win)
        }
    }
}
