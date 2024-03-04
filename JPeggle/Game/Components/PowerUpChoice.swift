struct PowerUpChoice: Component {
    static let id = ComponentId.powerUpChoice

    let powerUp: PowerUp
}

enum PowerUp: Saveable {
    case kaboom
    case spookyBall
    case duplicate
}
