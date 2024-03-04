extension ComponentId {
    // NOTE: Using switch case because a component id
    // MUST have an an associated component type.

    // Adding a new component means adding a new componentId already
    // So the modification of this file comes naturally as a side effect
    // of adding a new component

    // Allowing the component type to be nullable means that
    // errors cannot be handled at compile time. And this is much
    // much worse than trying to maintain OCP for the sake of "correctness".
    var componentType: any Component.Type {
        switch self {
        case .transform:
            return Transform.self
        case .physicsObject:
            return PhysicsObject.self
        case .sprite:
            return Sprite.self
        case .zIndex:
            return ZIndex.self
        case .peg:
            return Peg.self
        case .shouldRemove:
            return ShouldRemove.self
        case .outOfBounds:
            return OutOfBounds.self
        case .cannonBall:
            return CannonBall.self
        case .delta:
            return Delta.self
        case .cannon:
            return Cannon.self
        case .aimPoint:
            return AimPoint.self
        case .bucket:
            return Bucket.self
        case .scoringPeg:
            return ScoringPeg.self
        case .stubbornPeg:
            return StubbornPeg.self
        case .gameStatus:
            return GameStatus.self
        case .ballsLeft:
            return BallsLeft.self
        case .sideWall:
            return SideWall.self
        case .topWall:
            return TopWall.self
        case .bottomWall:
            return BottomWall.self
        case .powerUpPeg:
            return PowerUpPeg.self
        case .powerUpChoice:
            return PowerUpChoice.self
        case .spookyActive:
            return SpookyActive.self
        case .shouldKaboom:
            return ShouldKaboom.self
        case .gravityImpulse:
            return GravityImpulse.self
        case .health:
            return Health.self
        case .freelyResizable:
            return FreelyResizable.self
        case .block:
            return Block.self
        case .sounds:
            return Sounds.self
        case .winningPeg:
            return WinningPeg.self
        case .score:
            return Score.self
        }
    }
}

extension Component {
    var id: ComponentId {
        Self.id
    }
}
