import SwiftUI

enum PaletteOption {
    case pegBlue
    case pegBlueTriangle
    case pegOrange
    case pegOrangeTriangle
    case pegGreen
    case pegGreenTriangle
    case pegRed
    case pegRedTriangle
    case block

    private static let _pegPrefabs: [PaletteOption: PlaceablePrefab] = [
        .pegBlue: BlueCirclePegPrefab(),
        .pegBlueTriangle: BlueTrianglePegPrefab(),
        .pegOrange: OrangeCirclePegPrefab(),
        .pegOrangeTriangle: OrangeTrianglePegPrefab(),
        .pegGreen: GreenCirclePegPrefab(),
        .pegGreenTriangle: GreenTrianglePegPrefab(),
        .pegRed: RedCirclePegPrefab(),
        .pegRedTriangle: RedTrianglePegPrefab(),
        .block: BlockPrefab()
    ]

    func toPegPrefab() -> (any PlaceablePrefab)? {
        assert(Self._pegPrefabs[self] != nil, "No prefab for \(self)")
        return Self._pegPrefabs[self]
    }
}

enum LevelDesignerMode: Equatable {
    case select
    case add(option: PaletteOption)
    case delete
}

@MainActor
class LevelDesignerController: ObservableObject {
    // The underlying game state being created by the level designer
    @Published private (set) var level = Level(board: Board(width: 100, height: 100))
    @Published private (set) var savedLevel: Level?
    @Published private (set) var isLevelCustom = true
    @Published private (set) var mode: LevelDesignerMode = .add(option: .pegBlue)
    @Published var hoverPosition: CGPoint?
    @Published var isLevelCorrupted = false
    @Published var selectedPegId: Entity.ID?

    @Published private var levelStore = JSONLevelStore()
    private var _levelWidth: Double = 100
    private var _levelHeight: Double = 100

    var levelWidth: Double {
        get {
            _levelWidth
        }
        set {
            _levelWidth = newValue
            let board = Board(width: _levelWidth, height: _levelHeight, pegs: level.board.placedEntities)
            level.board = board
        }
    }

    var levelHeight: Double {
        get {
            _levelHeight
        }
        set {
            _levelHeight = newValue
            let board = Board(width: _levelWidth, height: _levelHeight, pegs: level.board.placedEntities)
            level.board = board
        }
    }

    var hasChanges: Bool {
        guard let savedLevel else {
            return !level.board.allEntities.isEmpty
        }

        return level.name != savedLevel.name || level.board != savedLevel.board
    }

    var isDirty: Bool {
        if savedLevel == nil {
            return true
        }

        return level.board != savedLevel?.board
    }

    var isLevelValid: Bool {
        level.board.isValid
    }

    var levels: [LoadedLevel] {
        levelStore.levels
    }

    var entities: [LevelDesignerEntity] {
        level.board.displayableEntities
    }

    func enterDeleteMode() {
        mode = .delete
    }

    func toggleAddMode(option: PaletteOption) {
        if case .add(option: option) = mode {
            mode = .select
            return
        }

        mode = .add(option: option)
    }

    func tapPeg(withId id: Entity.ID) {
        if case .delete = mode {
            level.board.deleteEntity(with: id)
            return
        }

        selectPeg(withId: id)
    }

    private func selectPeg(withId id: Entity.ID) {
        selectedPegId = id
    }

    func dragPeg(withId id: Entity.ID) {
        if case .delete = mode {
            return
        }

        selectPeg(withId: id)
    }

    func attachHpToEntity(withId id: Entity.ID, health: Health) {
        guard let entity = level.board.getEntity(withId: id) else {
            return
        }
        entity.assign(health)
        level.board.deleteEntity(with: id)
        level.board.tryAddEntity(entity)
        assert(level.board.entities.contains(withId: id))
    }

    func removeHpFromEntity(withId id: Entity.ID) {
        guard let entity = level.board.getEntity(withId: id) else {
            return
        }
        entity.unassign(ofType: Health.self)
        level.board.deleteEntity(with: id)
        level.board.tryAddEntity(entity)
        assert(level.board.entities.contains(withId: id))
    }

    var selectedEntityHealth: Health? {
        guard let id = selectedPegId else {
            return nil
        }
        return level.board.getEntity(withId: id)?.getComponent(ofType: Health.self)
    }

    func canMovePeg(withId id: Entity.ID, offset: Vector) -> Bool {
        let peg = level.board.getEntity(withId: id)
        guard let entity = peg else {
            return false
        }
        guard let transform = entity.getComponent(ofType: Transform.self) else {
            return false
        }
        var newTransform = transform
        newTransform.origin += offset
        return level.board.canPlaceEntity(entity, transform: newTransform)
    }

    func tryMovePeg(withId id: Entity.ID, offset: Vector) {
        let entity = level.board.getEntity(withId: id)
        guard let entity = entity else {
            return
        }

        guard let transform = entity.getComponent(ofType: Transform.self) else {
            return
        }

        var newTransform = transform
        newTransform.origin += offset

        level.board.tryTransformEntity(entity, transform: newTransform)
    }

    func canTransformPeg(withId id: Entity.ID, transform: Transform) -> Bool {
        let peg = level.board.getEntity(withId: id)
        guard let entity = peg else {
            return false
        }
        return level.board.canPlaceEntity(entity, transform: transform)
    }

    func tryTransformPeg(withId id: Entity.ID, transform: Transform) {
        if mode == .delete {
            return
        }

        guard let entity = level.board.getEntity(withId: id) else {
            return
        }

        level.board.tryTransformEntity(entity, transform: transform)
    }

    func tapPosition(_ position: Vector) {
        if case .delete = mode {
            return
        }

        if case .select = mode {
            selectedPegId = nil
            return
        }

        if case .add(option: let option) = mode {
            guard let pegPrefab = option.toPegPrefab() else {
                return
            }

            let peg = pegPrefab.create(transform: Transform(origin: position))
            let success = level.board.tryAddEntity(peg)
            if success {
                selectedPegId = peg.id
            }
            return
        }
    }

    func save() {
        do {
            try levelStore.writeLevel(level)
            savedLevel = level
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func saveAsNew(withName levelName: String) {
        do {
            var newLevel = level
            newLevel.id = UUID()
            newLevel.name = levelName
            try levelStore.writeLevel(newLevel)
            level = newLevel
            savedLevel = level
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    func reset() {
        level.board = Board(width: levelWidth, height: levelHeight, pegs: Entities())
    }

    func load(levelId: Level.ID) {
        if let loadedLevel = levels.first(where: { $0.level.id == levelId }) {
            self.level = loadedLevel.level
            self.savedLevel = loadedLevel.level
            self.isLevelCustom = !loadedLevel.isPreLoaded
            isLevelCorrupted = false
        } else {
            isLevelCorrupted = true
        }
    }

    func deleteCurrentLevel() {
        try? levelStore.deleteLevel(withId: level.id)
        level = Level(board: Board(width: levelWidth, height: levelHeight))
        savedLevel = nil
    }

    func loadInitial() async {
        // Assign level store to new struct to prevent
        // calling mutating async function 'initialize()' on actor-isolated property 'levelStore'
        var loadedLevelStore = levelStore
        try? await loadedLevelStore.initialize()
        levelStore = loadedLevelStore
    }
}
