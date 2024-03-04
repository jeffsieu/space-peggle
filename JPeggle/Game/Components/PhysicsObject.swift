struct PhysicsObject: Component {
    typealias Layer = GameCollisionLayer
    static let id = ComponentId.physicsObject

    var mass: Double
    var velocity: Vector
    var restitution: Double
    var collider: AnyCollider
    var collisionLayer: Layer
    var isKinematic: Bool
    var resolveCollisions: Bool
    var passThrough = false
    var impulses: [Vector] = []
    var collisions: [PhysicsBodyCollision<Layer>]

    init(mass: Double,
         velocity: Vector,
         restitution: Double,
         collider: AnyCollider,
         collisionLayer: GameCollisionLayer,
         isKinematic: Bool,
         resolveCollisions: Bool,
         passThrough: Bool,
         collisions: [PhysicsBodyCollision<Layer>] = []
    ) {
        self.mass = mass
        self.velocity = velocity
        self.restitution = restitution
        self.collider = collider
        self.collisionLayer = collisionLayer
        self.collisions = collisions
        self.isKinematic = isKinematic
        self.resolveCollisions = resolveCollisions
        self.passThrough = passThrough
        self.impulses = []
        assert(checkRepresentation())
    }

    mutating func addImpulse(_ impulse: Vector) {
        impulses.append(impulse)
    }

    func checkRepresentation() -> Bool {
        if mass < 0 || restitution < 0 || restitution > 1 {
            return false
        }

        return true
    }
}
