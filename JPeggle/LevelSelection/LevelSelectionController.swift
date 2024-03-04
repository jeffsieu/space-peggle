import SwiftUI

class LevelSelectionController: ObservableObject {
    @Published private var levelStore = JSONLevelStore()

    var levels: [LoadedLevel] {
        levelStore.levels
    }

    func initialize() async {
        var loadedLevelStore = levelStore
        try? await loadedLevelStore.initialize()
        levelStore = loadedLevelStore
    }
}
