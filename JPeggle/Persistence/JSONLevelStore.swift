import Foundation

private let levelListFileName = "level-list.json"

private func getLevelFileName(level: Level) -> String {
    "\(level.id).json"
}

private func getLevelFileName(levelId: Level.ID) -> String {
    "\(levelId).json"
}

private let premadeLevelFileNames: [String] = [
    "Level1",
    "Level2",
    "Level3"
]

func getPremadeLevelUrl(fileName: String) -> URL? {
    Bundle.main.url(forResource: fileName, withExtension: "json")
}

func getPremadeLevel(fileName: String) -> Level? {
    guard let url = getPremadeLevelUrl(fileName: fileName) else {
        return nil
    }

    let data = try? Data(contentsOf: url)
    guard let data else {
        return nil
    }

    return try? JSONDecoder().decode(Level.self, from: data)
}

struct LoadedLevel {
    let level: Level
    let isPreLoaded: Bool
}

struct JSONLevelStore: LevelStore {
    private let storage = JSONFilePersister()
    private var levelIds: [Level.ID] = []
    private var levelMap: [Level.ID: LoadedLevel] = [:]

    var levels: [LoadedLevel] {
        levelIds.compactMap { levelMap[$0] }
    }

    mutating func writeLevel(_ level: Level) throws {
        try writeLevelFile(level: level)
        if !levelIds.contains(level.id) {
            levelIds.append(level.id)
            try writeLevelIdList(levelIds)
        }
        levelMap[level.id] = LoadedLevel(level: level, isPreLoaded: false)
    }

    mutating func deleteLevel(withId levelId: Level.ID) throws {
        try deleteLevelFile(levelId: levelId)
        levelIds.removeAll(where: { $0 == levelId })
        try writeLevelIdList(levelIds)
    }

    mutating func initialize() async throws {
        levelIds = try await loadLevelIdList()
        levelMap = try await loadAllLevels()
    }

    private func readLevel(levelId: Level.ID) -> Level? {
        let fileName = getLevelFileName(levelId: levelId)
        return try? storage.readFromFile(withName: fileName)
    }

    private func readLevelIdList() -> [Level.ID] {
        let levelList: [Level.ID]? = try? storage.readFromFile(withName: levelListFileName)
        return levelList ?? []
    }

    private func writeLevelIdList(_ list: [Level.ID]) throws {
        try storage.writeToFile(withName: levelListFileName, data: list)
    }

    private func writeLevelFile(level: Level) throws {
        let fileName = getLevelFileName(levelId: level.id)
        try storage.writeToFile(withName: fileName, data: level)
    }

    private func deleteLevelFile(levelId: Level.ID) throws {
        let fileName = getLevelFileName(levelId: levelId)
        try storage.deleteFile(withName: fileName)
    }

    private func loadLevelIdList() async throws -> [Level.ID] {
        let task = Task<[Level.ID], Error> {
            readLevelIdList()
        }
        return try await task.value
    }

    private func loadAllLevels() async throws -> [Level.ID: LoadedLevel] {
        let task = Task {
            var levelMap: [Level.ID: LoadedLevel] = [:]

            for id in levelIds {
                if let level = readLevel(levelId: id) {
                    levelMap[id] = LoadedLevel(level: level, isPreLoaded: false)
                }
            }

            for fileName in premadeLevelFileNames {
                if let level = getPremadeLevel(fileName: fileName) {
                    levelMap[level.id] = LoadedLevel(level: level, isPreLoaded: true)
                }
            }

            return levelMap
        }
        return await task.value
    }
}
