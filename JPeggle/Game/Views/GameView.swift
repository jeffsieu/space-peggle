import SwiftUI

private let powerUpLabels: [PowerUp: String] = [
    .kaboom: "Kaboom",
    .spookyBall: "Spooky Ball",
    .duplicate: "Duplicate"
]

private let powerUpDescriptions: [PowerUp: String] = [
    .kaboom: "Light up all pegs within a radius",
    .spookyBall: "Ball reappears at the top after falling out",
    .duplicate: "Duplicate all balls on the playing field"
]

extension PowerUp {
    var label: String {
        assert(powerUpLabels[self] != nil, "Unknown powerup")
        return powerUpLabels[self] ?? "Unknown powerup"
    }

    var description: String {
        assert(powerUpDescriptions[self] != nil, "Unknown powerup")
        return powerUpDescriptions[self] ?? "Unknown powerup"
    }
}

struct GameView: View {
    private static let objectDestroyAnimationDuration: TimeInterval = 1.5

    let level: Level
    let displayableAdapter = SwiftUISpriteDisplayer()
    private let soundPlayer = SwiftUISoundPlayer()
    @State private var screenWidth = CGFloat.zero
    @State private var showWinAlert = false
    @State private var showLoseAlert = false
    @ObservedObject var gameEngineRunner: SwiftUIGameUpdater
    @State private var gameAreaViewSize: CGSize = .zero
    @State private var showBlackHole = false
    @State private var powerUpLabelScale = 1.0

    var aimAngle: CGFloat {
        guard let aimPoint = gameState.aimPoint else {
            return 0
        }
        let cannonOrigin = gameState.launchOrigin.toCGPoint()
        let x = aimPoint.x - cannonOrigin.x
        let y = aimPoint.y - cannonOrigin.y
        return atan2(y, x) - .pi / 2
    }

    init(level: Level) {
        self.level = level
        _gameEngineRunner = ObservedObject(initialValue: SwiftUIGameUpdater(gameState: GameState(board: level.board)))
    }

    private var gameState: GameState {
        get {
            gameEngineRunner.gameState
        }
        nonmutating set {
            gameEngineRunner.gameState = newValue
        }
    }

    private var screenSizeCaptureView: some View {
        GeometryReader { proxy in
            Color.clear
                .onAppear {
                    gameAreaViewSize = proxy.size
                }
                .onChange(of: proxy.size) {
                    gameAreaViewSize = proxy.size
                }
        }
    }

    var blackHoleSize: Double {
        min(gameState.width / 2, gameState.height / 2)
    }

    private var gameAreaView: some View {
        ZStack {
            BlackHoleView(showBlackHole: showBlackHole,
                          blackHoleSize: blackHoleSize,
                          openDuration: Self.objectDestroyAnimationDuration)
                .onChange(of: gameState.canShoot) {
                    if gameState.canShoot {
                        activateBlackHole()
                    }
                }
                .zIndex(-1_000)
            if gameState.canShoot, let aimPoint = gameState.aimPoint {
                Path { path in
                    path.move(to: CGPoint(x: gameState.width / 2, y: CannonBallPrefab.cannonBallSize.y / 2))
                    path.addLine(to: aimPoint.toCGPoint())
                }
                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, dash: [10]))
            }
            ForEach(gameState.displayableEntities, id: \.id) { entity in
                let sprite = entity.sprite
                let transform = entity.transform
                let zIndex = entity.zIndex
                let health = entity.health

                displayableAdapter.display(sprite)
                    .zIndex(zIndex)
                    .scaleEffect(transform.scale.toCGSize())
                    .frame(width: sprite.visualSize.x * transform.scale.x,
                           height: sprite.visualSize.y * transform.scale.y)
                    .rotationEffect(.radians(Double(transform.rotation)))
                    .position(transform.origin.toCGPoint())
                    .transition(
                        .asymmetric(
                            insertion: .identity,
                            removal: .opacity
                                .animation(.linear(duration: Self.objectDestroyAnimationDuration))
                                .combined(with:
                                    .scale.animation(.easeInOut(duration: Self.objectDestroyAnimationDuration))
                                )
                        )
                    )
            }
            ForEach(gameState.displayableEntities, id: \.id) { entity in
                let sprite = entity.sprite
                let transform = entity.transform
                let health = entity.health

                let offset = CGSize(
                    width: 0,
                    height: (-sprite.visualSize.y / 2 * transform.scale.y) - 16
                )

                if let health {
                    HealthBar(currentHealth: health.value, maxHealth: health.max)
                        .offset(offset)
                        .position(transform.origin.toCGPoint())
                        .zIndex(10)
                }
            }
        }
        .accessibilityIdentifier("gameArea")
        .frame(width: gameState.width, height: gameState.height)
        .contentShape(Rectangle())
        .clipped()
        .onTapGesture {
            trySetAimPoint($0)
        }
        .simultaneousGesture(DragGesture(minimumDistance: 1)
            .onChanged {
                trySetAimPoint($0.location)
            }
            .onEnded {
                trySetAimPoint($0.location)
            }
        )
        .toolbar {
            Button("Reset level") {
                resetGame()
            }
        }
        .task {
            gameEngineRunner.createDisplayLink()
            soundPlayer.initialize()
        }
        .onDisappear {
            gameEngineRunner.removeDisplayLink()
        }
        .onChange(of: gameState.gameStatus == .win) {
            if gameState.gameStatus == .win {
                showWinAlert = true
            }
        }
        .onChange(of: gameState.gameStatus == .lose) {
            if gameState.gameStatus == .lose {
                showLoseAlert = true
            }
        }
        .onChange(of: gameState.soundsToPlay) {
            for sound in gameState.soundsToPlay {
                soundPlayer.play(sound)
            }
        }
        .alert("You won! You cleared all orange pegs!", isPresented: $showWinAlert) {
            Button("Restart") {
                resetGame()
                showWinAlert = false
            }
            Button("Continue playing", role: .cancel) {
                showWinAlert = false
            }
        }
        .alert("You lost! You have no balls left!", isPresented: $showLoseAlert) {
            Button("Retry") {
                resetGame()
                showLoseAlert = false
            }
            Button("OK", role: .cancel) {
                showLoseAlert = false
            }
        }
        .background(
            Image("background")
                .resizable()
                .contentShape(Rectangle())
        )
    }

    private var selectedPowerUpLabel: String {
        gameState.selectedPowerUp.label
    }

    private var selectedPowerUpDescription: String {
        gameState.selectedPowerUp.description
    }

    private func resetGame() {
        activateBlackHole()
        gameState = GameState(board: level.board)
    }

    private func activateBlackHole() {
        showBlackHole = gameState.canShoot
        DispatchQueue.main.asyncAfter(deadline: .now() + Self.objectDestroyAnimationDuration) {
            showBlackHole = false
        }
    }

    var body: some View {
        VStack {
            VStack {
                Text("\(gameState.score)")
                    .font(.system(size: 60))
                    .fontWeight(.bold)
                    .fontWidth(.compressed)
                    .foregroundStyle(.white)
                Text("Balls left: \(gameState.ballsLeft)")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
            }
            HStack {
                GameViewSelectableButton(
                    active: gameState.selectedPowerUp == .kaboom,
                    imageResource: "peg-orange"
                ) {
                    gameState.selectedPowerUp = .kaboom
                }
                GameViewSelectableButton(
                    active: gameState.selectedPowerUp == .spookyBall,
                    imageResource: "peg-purple"
                ) {
                    gameState.selectedPowerUp = .spookyBall
                }
                GameViewSelectableButton(
                    active: gameState.selectedPowerUp == .duplicate,
                    imageResource: "peg-yellow"
                ) {
                    gameState.selectedPowerUp = .duplicate
                }
                Button {
                    guard gameState.canShoot else {
                        return
                    }
                    gameState.shoot()
                } label: {
                    Text("Fire").font(.largeTitle)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.extraLarge)
                .tint(.orange)
                .disabled(!gameState.canShoot || gameState.aimPoint == nil)
            }
            VStack {
                Text(selectedPowerUpLabel)
                    .font(.largeTitle)
                    .foregroundColor(.white)
                Text(selectedPowerUpDescription)
                    .font(.title)
                    .foregroundColor(.gray)
            }
            .scaleEffect(powerUpLabelScale)
            .onChange(of: gameState.selectedPowerUp) {
                withAnimation(Animation.easeIn(duration: 0.3)) {
                    powerUpLabelScale = 1.2
                } completion: {
                    withAnimation(Animation.easeOut(duration: 0.3)) {
                        powerUpLabelScale = 1
                    }
                }
            }
            GeometryReader { proxy in
                let widthBasedScale = proxy.size.width / gameState.width
                let heightBasedScale = proxy.size.height / gameState.height
                let scale = min(widthBasedScale, heightBasedScale)

                gameAreaView
                    .scaleEffect(scale)
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .shadow(radius: 10)
            }
        }
        .contentShape(Rectangle())
        .clipped()
        .background(
            Image("background").resizable().contentShape(Rectangle())
                // scale to compensate blur
                .scaleEffect(1.1)
                .blur(radius: 10)
                .ignoresSafeArea()
        )
    }

    func trySetAimPoint(_ point: CGPoint) {
        let minY = CannonBallPrefab.cannonBallSize.y / 2
        if point.y < minY {
            gameState.aimPoint = Vector(x: point.x, y: minY)
        } else {
            gameEngineRunner.gameState.aimPoint = point.toVector()
        }
    }
}
