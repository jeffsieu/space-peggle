enum ComponentDecodingError: Error {
    case componentIdDoesNotMatchComponent
}

struct AnyComponent: Equatable, Saveable, Hashable {
    static func == (lhs: AnyComponent, rhs: AnyComponent) -> Bool {
        guard lhs.componentId == rhs.componentId else {
            return false
        }

        guard let lhsComponent = lhs.component as? AnyHashable else {
            return false
        }

        guard let rhsComponent = rhs.component as? AnyHashable else {
            return false
        }

        return lhsComponent == rhsComponent
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(componentId)
        hasher.combine(component)
    }

    var component: any Component
    var componentId: ComponentId

    enum CodingKeys: String, CodingKey {
          case component
          case componentId
      }

    init(_ component: any Component) {
        self.component = component
        self.componentId = component.id
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        componentId = try values.decode(ComponentId.self, forKey: .componentId)

        let matchingComponentType = componentId.componentType

        guard matchingComponentType.id == componentId else {
            throw ComponentDecodingError.componentIdDoesNotMatchComponent
        }

        component = try values.decode(matchingComponentType, forKey: .component)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(
            keyedBy: CodingKeys.self
        )
        try container.encode(
            componentId,
            forKey: .componentId
        )
        try container.encode(
            component,
            forKey: .component
        )
    }
}
