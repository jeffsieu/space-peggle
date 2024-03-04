import Foundation

struct LoseSystem: System {
    func update(entities: inout Entities) {
        let scoringPegArchetype = makeArchetype(ScoringPeg.self)
        let scoringPegResults = entities.ofArchetype(scoringPegArchetype)
        let hasScoringPegs = !scoringPegResults.isEmpty
        let hasNoBall = entities.ofArchetype(makeArchetype(CannonBall.self)).isEmpty
        let ballsLeft = entities.ofArchetype(makeArchetype(BallsLeft.self)).count

        if hasScoringPegs && hasNoBall && ballsLeft == 0 {
            entities.setSingle(GameStatus.lose)
        }
    }
}
