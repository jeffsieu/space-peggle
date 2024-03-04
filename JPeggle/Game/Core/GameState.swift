// swiftlint:disable large_tuple

import Foundation

private let physicsEntityArchetype = makeArchetype(PhysicsObject.self, Transform.self)
private let spriteEntityArchetype = makeArchetype(Sprite.self, Transform.self)

private func createWalls(width: Double, height: Double) -> [Entity] {
    let wallThickness = 500.0
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
    leftWall.assign(SideWall())
    let rightWall = Entity()
    rightWall.assign(Transform(origin: Vector(x: width, y: 0)))
    rightWall.assign(verticalPhysicsObject)
    rightWall.assign(SideWall())
    let bottomWall = Entity()
    bottomWall.assign(Transform(origin: Vector(x: 0, y: height)))
    bottomWall.assign(horizontalPhysicsObject)
    bottomWall.assign(BottomWall())
    let topWall = Entity()
    topWall.assign(Transform(origin: Vector(x: 0, y: -wallThickness)))
    topWall.assign(horizontalPhysicsObject)
    topWall.assign(TopWall())

    return [leftWall, rightWall, bottomWall, topWall]
}

private func createGameCollisionMatrix() -> GameCollisionMatrix {
    var matrix = GameCollisionMatrix()

    matrix.enableCollisions(between: .cannonBall, and: .cannonBall)
    matrix.enableCollisions(between: .peg, and: .cannonBall)
    matrix.enableCollisions(between: .block, and: .cannonBall)
    matrix.enableCollisions(between: .cannonBall, and: .horizontalBoundaries)
    matrix.enableCollisions(between: .cannonBall, and: .verticalBoundaries)
    matrix.enableCollisions(between: .cannonBall, and: .bucket)
    matrix.enableCollisions(between: .bucket, and: .verticalBoundaries)

    return matrix
}

private let gameCollisionMatrix = createGameCollisionMatrix()

struct GameState: Saveable, Hashable {
    let width: Double
    let height: Double
    private var physicsWorld: GamePhysicsWorld
    private var entities: Entities
    var aimPoint: Vector?
    var selectedPowerUp: PowerUp
    var soundsToPlay: [SoundAsset]

    var canShoot: Bool {
        !hasBall && ballsLeft > 0
    }

    var launchOrigin: Vector {
        Vector(x: width / 2, y: CannonBallPrefab.cannonBallSize.y / 2)
    }

    var gameStatus: GameStatus {
        let gameStatusComponent = entities.single(GameStatus.self)
        return gameStatusComponent ?? .ongoing
    }

    var score: Int {
        let scoreComponent = entities.single(Score.self)
        return scoreComponent?.currentScore ?? 0
    }

    private (set) var ballsLeft: Int {
        get {
            let ballsLeftComponent = entities.single(BallsLeft.self)
            return ballsLeftComponent?.count ?? 0
        }
         set {
             entities.setSingle(BallsLeft(count: newValue))
        }
    }

    var hasBall: Bool {
        !entities.ofArchetype(makeArchetype(CannonBall.self)).isEmpty
    }

    init(board: Board) {
        self.width = board.width
        self.height = board.height
        self.entities = Entities()

        for peg in board.placedEntities.all() {
            entities.add(peg.clone(withId: UUID()))
        }

        let verticalWallHeight = board.height + CannonBallPrefab.cannonBallSize.y * 2

        for wall in createWalls(width: width, height: verticalWallHeight) {
            entities.add(wall)
        }

        let cannon = CannonPrefab().create(at: Vector(x: width / 2, y: CannonBallPrefab.cannonBallSize.y / 2), towards: aimPoint)
        let bucket = BucketPrefab().create(transform:
            Transform(origin: Vector(x: width / 2, y: height)))

        self.selectedPowerUp = .kaboom
        let powerUpChoice = PowerUpChoice(powerUp: selectedPowerUp)
        self.soundsToPlay = []

        entities.add(cannon)
        entities.add(bucket)
        entities.setSingle(powerUpChoice)
        entities.setSingle(Sounds())
        entities.setSingle(GameStatus.ongoing)
        entities.setSingle(BallsLeft(count: 10))

        let bodies = entities.ofArchetype(physicsEntityArchetype).map {
            let id = $0.entity.id
            let (physicsObject, transform) = $0.components
            return physicsObject.createPhysicsBody(withId: id, transform: transform)
        }

        self.physicsWorld = GamePhysicsWorld(collisionMatrix: gameCollisionMatrix, bodies: bodies)
    }

    var allEntities: [Entity] {
        entities.all()
    }

    var physicsEntities: [QueryResult<(PhysicsObject, Transform)>] {
        entities.ofArchetype(physicsEntityArchetype)
    }

    var displayableEntities: [GameEntity] {
        entities.ofArchetype(spriteEntityArchetype)
            .map { result in
                let entity = result.entity
                let (sprite, transform) = result.components
                let zIndex = entity.getComponent(ofType: ZIndex.self)?.value ?? 0
                let health = entity.getComponent(ofType: Health.self)

                return GameEntity(id: entity.id, transform: transform, sprite: sprite, health: health, zIndex: zIndex)
            }
            .sorted {
                let firstZIndex = $0.zIndex
                let secondZIndex = $1.zIndex

                return firstZIndex < secondZIndex
            }
    }

    private mutating func addEntity(_ entity: Entity) {
        entities.add(entity)

        if let components = entity.getComponentsOf(archetype: physicsEntityArchetype) {
            let (physicsObject, transform) = components
            let physicsBody = physicsObject.createPhysicsBody(withId: entity.id, transform: transform)
            physicsWorld.addBody(physicsBody)
        }
    }

    mutating func shoot() {
        guard canShoot else {
            return
        }

        guard let aimPoint = aimPoint else {
            return
        }

        ballsLeft -= 1

        let direction = (aimPoint - launchOrigin).normalized()
        let cannonBallInitialVelocity = direction * 1_000
        let cannonBall = CannonBallPrefab().create(
            transform: Transform(origin: launchOrigin),
            initialVelocity: cannonBallInitialVelocity

        )
        addEntity(cannonBall)
    }

    mutating func update(deltaMs: Double) {
        syncDelta(deltaMs: deltaMs)
        syncAimPoint()
        syncPhysicsWorld(deltaMs: deltaMs)
        syncPowerUpChoice()

        StubbornPegInitializingSystem().update(entities: &entities)
        GravitySystem().update(entities: &entities)
        PegTouchDetectionSystem().update(entities: &entities)
        PegLightingSystem().update(entities: &entities)
        CollisionSoundSystem().update(entities: &entities)

        // detect and remove ball
        StuckBallDetectionSystem().update(entities: &entities)
        StuckBallClearingSystem().update(entities: &entities)
        OutOfBoundsDetectionSystem().update(entities: &entities)
        OutOfBoundsBallHandlingSystem().update(entities: &entities)
        BucketSystem().update(entities: &entities)
        EntityRemovalSystem().update(entities: &entities)

        WinSystem().update(entities: &entities)
        HealthPegUpdatingSystem().update(entities: &entities)
        PowerUpActivationSystem().update(entities: &entities)
        SpookyHandlingSystem().update(entities: &entities)
        KaboomSystem().update(entities: &entities)
        StubbornPegSystem().update(entities: &entities)
        CannonSpriteUpdatingSystem().update(entities: &entities)
        PegClearingSystem().update(entities: &entities)

        ScoringSystem().update(entities: &entities)
        EntityRemovalSystem().update(entities: &entities)
        PegTouchResetSystem().update(entities: &entities)

        ballsLeft = entities.single(BallsLeft.self)?.count ?? ballsLeft

        updateBallStatus()
        updateGameStatus()
        updateSoundsToPlay()
    }

    private mutating func syncDelta(deltaMs: Double) {
        entities.setSingle(Delta(deltaMs: deltaMs))
    }

    private mutating func syncPowerUpChoice() {
        entities.setSingle(PowerUpChoice(powerUp: selectedPowerUp))
    }

    private mutating func syncAimPoint() {
        guard let aimPoint = aimPoint else {
            return
        }
        entities.setSingle(AimPoint(origin: aimPoint, canShoot: canShoot))
    }

    private mutating func updateGameStatus() {
    }

    private mutating func updateBallStatus() {
    }

    private mutating func updateSoundsToPlay() {
        let sounds = entities.single(Sounds.self)
        soundsToPlay = sounds?.soundsToPlay ?? []

        entities.setSingle(Sounds())
    }

    private mutating func syncPhysicsWorld(deltaMs: Double) {
        let bodies = entities.ofArchetype(physicsEntityArchetype).map {
            let id = $0.entity.id
            let (physicsObject, transform) = $0.components
            return physicsObject.createPhysicsBody(withId: id, transform: transform)
        }

        var newPhysicsWorld = GamePhysicsWorld(collisionMatrix: gameCollisionMatrix, bodies: bodies)
        newPhysicsWorld.update(deltaMs: deltaMs)

        for physicsBody in newPhysicsWorld.bodies {
            guard let entity = entities.get(withId: physicsBody.id) else {
                continue
            }
            let transform = physicsBody.transform
            let collisions = newPhysicsWorld.getCollisions(body: physicsBody)

            entity.assign(physicsBody.toPhysicsObject(withCollisions: collisions))
            entity.assign(transform)
        }

        physicsWorld = newPhysicsWorld
    }
}

// swiftlint:enable large_tuple
