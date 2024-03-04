import Foundation

private let physicsEntityArchetype = makeArchetype(PhysicsObject.self, Transform.self)
private let displayableEntityArchetype = makeArchetype(Sprite.self, Transform.self)
private func createWalls(width: Double, height: Double) -> [Entity] {
    let wallThickness = 50.0
    let horizontalWallCollider = AnyCollider(PolygonCollider(
        points: [
            Vector(x: 0, y: 0),
            Vector(x: width, y: 0),
            Vector(x: width, y: wallThickness),
            Vector(x: 0, y: wallThickness)
        ]
    ))
    let horizontalPhysicsObject = PhysicsObject(
        mass: 0,
        velocity: Vector.zero,
        restitution: 1,
        collider: horizontalWallCollider,
        collisionLayer: .horizontalBoundaries,
        isKinematic: true,
        resolveCollisions: false,
        passThrough: false
    )

    let verticalWallCollider = AnyCollider(PolygonCollider(
        points: [
            Vector(x: 0, y: 0),
            Vector(x: wallThickness, y: 0),
            Vector(x: wallThickness, y: height),
            Vector(x: 0, y: height)
        ]
    ))

    let verticalPhysicsObject = PhysicsObject(
        mass: 0,
        velocity: Vector.zero,
        restitution: 1,
        collider: verticalWallCollider,
        collisionLayer: .verticalBoundaries,
        isKinematic: true,
        resolveCollisions: false,
        passThrough: false
    )

    let leftWall = Entity()
    leftWall.assign(Transform(origin: Vector(x: -wallThickness, y: 0)))
    leftWall.assign(verticalPhysicsObject)

    let rightWall = Entity()
    rightWall.assign(Transform(origin: Vector(x: width, y: 0)))
    rightWall.assign(verticalPhysicsObject)

    let topWall = Entity()
    topWall.assign(Transform(origin: Vector(x: 0, y: -wallThickness)))
    topWall.assign(horizontalPhysicsObject)

    let bottomWall = Entity()
    bottomWall.assign(Transform(origin: Vector(x: 0, y: height)))
    bottomWall.assign(horizontalPhysicsObject)

    return [leftWall, rightWall, topWall, bottomWall]
}

private func createBoardCollisionMatrix() -> GameCollisionMatrix {
    var matrix = GameCollisionMatrix()
    matrix.enableCollisions(between: .peg, and: .peg)
    matrix.enableCollisions(between: .peg, and: .horizontalBoundaries)
    matrix.enableCollisions(between: .peg, and: .verticalBoundaries)
    matrix.enableCollisions(between: .block, and: .peg)
    matrix.enableCollisions(between: .block, and: .horizontalBoundaries)
    matrix.enableCollisions(between: .block, and: .verticalBoundaries)

    return matrix
}

private let boardCollisionMatrix = createBoardCollisionMatrix()

struct Board: Saveable, Hashable {
    let width: Double
    let height: Double
    private (set) var entities: Entities
    private var physicsWorld: GamePhysicsWorld

    var placedEntities: Entities {
        var placedEntities = entities
        for entity in entities.all() {
            if entity.hasComponent(ofType: Peg.self) || entity.hasComponent(ofType: Block.self) {
                continue
            }
            placedEntities.remove(withId: entity.id)
        }

        return placedEntities
    }

    init(width: Double, height: Double, pegs: Entities = Entities()) {
        self.width = width
        self.height = height
        self.entities = Entities()
        self.physicsWorld = GamePhysicsWorld(collisionMatrix: boardCollisionMatrix)

        for peg in pegs.all() {
            self.entities.add(peg)
        }

        for wall in createWalls(width: width, height: height) {
            self.entities.add(wall)
        }

        syncPhysicsWorld()
    }

    mutating func syncPhysicsWorld() {
        let bodies = entities.ofArchetype(physicsEntityArchetype).map {
            let id = $0.entity.id
            let (physicsObject, transform) = $0.components
            return physicsObject.createPhysicsBody(withId: id, transform: transform)
        }

        self.physicsWorld = GamePhysicsWorld(collisionMatrix: boardCollisionMatrix, bodies: bodies)
        physicsWorld.update(deltaMs: 100)
    }

    var allEntities: [Entity] {
        entities.all()
    }

    var displayableEntities: [LevelDesignerEntity] {
        entities.ofArchetype(displayableEntityArchetype).map {
            let entity = $0.entity
            let (sprite, transform) = $0.components
            let zIndex = entity.getComponent(ofType: ZIndex.self)
            let canResizeFreely = entity.hasComponent(ofType: FreelyResizable.self)
            let health = entity.getComponent(ofType: Health.self)

            return LevelDesignerEntity(
                id: $0.entity.id,
                sprite: sprite,
                transform: transform,
                health: health,
                zIndex: zIndex?.value,
                canResizeFreely: canResizeFreely)
        }
    }

    mutating func deleteEntity(with id: UUID) {
        entities.remove(withId: id)

        syncPhysicsWorld()
    }

    func canPlaceEntity(_ entity: Entity, transform: Transform) -> Bool {
        guard let physicsObject = entity.getComponent(ofType: PhysicsObject.self) else {
            return true
        }

        let physicsBody = physicsObject.createPhysicsBody(withId: entity.id, transform: transform)

        var newPhysicsWorld = physicsWorld.clone()
        newPhysicsWorld.removeBodies(where: { $0.id == entity.id })
        newPhysicsWorld.addBody(physicsBody)
        newPhysicsWorld.update(deltaMs: 0)

        return newPhysicsWorld.getCollisions(body: physicsBody).isEmpty
    }

    mutating func tryTransformEntity(_ entity: Entity, transform: Transform) {
        guard canPlaceEntity(entity, transform: transform) else {
            return
        }

        entity.assign(transform)
        syncPhysicsWorld()
    }

    private func hasCollision(entity: Entity) -> Bool {
        guard let physicsObject = entity.getComponent(ofType: PhysicsObject.self) else {
            return false
        }

        return !physicsObject.collisions.isEmpty
    }

    @discardableResult
    mutating func tryAddEntity(_ entity: Entity) -> Bool {
        guard let transform = entity.getComponent(ofType: Transform.self) else {
            addPeg(entity)
            return true
        }

        guard canPlaceEntity(entity, transform: transform) else {
            return false
        }

        addPeg(entity)
        return true
    }

    private mutating func addPeg(_ entity: Entity) {
        entities.add(entity)

       syncPhysicsWorld()
    }

    private func containsEntity(_ entity: Entity) -> Bool {
        entities.contains(withId: entity.id)
    }

    func getEntity(withId id: UUID) -> Entity? {
        entities.get(withId: id)
    }

    var isValid: Bool {
        let hasWinningPeg = !entities.ofArchetype(makeArchetype(WinningPeg.self)).isEmpty

        return hasWinningPeg
    }
}
