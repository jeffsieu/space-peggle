enum ColliderKind: Int, Saveable {
    case circle = 0
    case polygon = 1
}

extension ColliderKind {
    // NOTE: Using switch case because this is actually a
    // definition on the enum type itself.

    // Adding values to the enum type SHOULD entail adding a new
    // case here. And we want the compiler to throw an error if
    // we forget to add such an entry.
    var colliderType: any ColliderProtocol.Type {
        switch self {
        case.circle:
            CircleCollider.self
        case.polygon:
            PolygonCollider.self
        }
    }
}

extension ColliderProtocol {
    func getColliderKind() -> ColliderKind {
        Self.colliderKind
    }
}

struct AnyCollider: Equatable, Saveable, Hashable {
    static func == (lhs: AnyCollider, rhs: AnyCollider) -> Bool {
        guard lhs.colliderKind == rhs.colliderKind else {
            return false
        }

        guard let lhsCollider = lhs.collider as? AnyHashable else {
            return false
        }

        guard let rhsCollider = rhs.collider as? AnyHashable else {
            return false
        }

        return lhsCollider == rhsCollider
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(colliderKind)
        hasher.combine(collider)
    }

    var collider: any ColliderProtocol
    var colliderKind: ColliderKind

    enum CodingKeys: String, CodingKey {
        case collider
        case colliderKind
    }

    init(_ collider: any ColliderProtocol) {
        self.collider = collider
        self.colliderKind = collider.getColliderKind()
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        colliderKind = try values.decode(ColliderKind.self, forKey: .colliderKind)

        let matchingColliderType = colliderKind.colliderType

        guard matchingColliderType.colliderKind == colliderKind else {
            throw ComponentDecodingError.componentIdDoesNotMatchComponent
        }

        collider = try values.decode(matchingColliderType, forKey: .collider)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(colliderKind, forKey: .colliderKind)
        try container.encode(collider, forKey: .collider)
    }
}
