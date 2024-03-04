protocol LevelStore {
    var levels: [LoadedLevel] { get }

    mutating func writeLevel(_ level: Level) throws

    mutating func deleteLevel(withId levelId: Level.ID) throws

    mutating func initialize() async throws
}
