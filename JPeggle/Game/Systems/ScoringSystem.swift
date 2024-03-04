struct ScoringSystem: System {
    func update(entities: inout Entities) {
        var score = entities.single(Score.self) ?? Score()

        let scoringPegArchetype = makeArchetype(ScoringPeg.self, ShouldRemove.self)
        let results = entities.ofArchetype(scoringPegArchetype)

        for peg in results {
            let (scoringPeg, _) = peg.components

            score.currentScore += scoringPeg.score
        }

        entities.setSingle(score)
    }
}
