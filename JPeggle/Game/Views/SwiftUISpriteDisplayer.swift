import SwiftUI

let imageResourcePaths: [DisplayableAsset: String] = [
    .pegBlue: "peg-blue",
    .pegBlueGlow: "peg-blue-glow",
    .pegBlueTriangle: "peg-blue-triangle",
    .pegBlueTriangleGlow: "peg-blue-glow-triangle",
    .pegOrange: "peg-orange",
    .pegOrangeGlow: "peg-orange-glow",
    .pegOrangeTriangle: "peg-orange-triangle",
    .pegOrangeTriangleGlow: "peg-orange-glow-triangle",
    .pegGreen: "peg-green",
    .pegGreenGlow: "peg-green-glow",
    .pegGreenTriangle: "peg-green-triangle",
    .pegGreenTriangleGlow: "peg-green-glow-triangle",
    .pegRed: "peg-red",
    .pegRedGlow: "peg-red-glow",
    .pegRedTriangle: "peg-red-triangle",
    .pegRedTriangleGlow: "peg-red-glow-triangle",
    .cannonBall: "ball",
    .cannonBallSpooky: "peg-purple-glow",
    .bucket: "bucket",
    .cannonUnloaded: "cannon-unloaded",
    .cannonLoaded: "cannon-loaded",
    .block: "block"
]

private let glowColors: [DisplayableAsset: Color] = [
    .pegBlueGlow: .blue,
    .pegBlueTriangleGlow: .blue,
    .pegOrangeGlow: .orange,
    .pegOrangeTriangleGlow: .orange,
    .pegGreenGlow: .green,
    .pegGreenTriangleGlow: .green,
    .pegRedGlow: .red,
    .pegRedTriangleGlow: .red,
    .cannonBallSpooky: .purple
]

private func getImageResourcePath(_ sprite: Sprite) -> String? {
    imageResourcePaths[sprite.asset]
}

private func getGlowColor(_ sprite: Sprite) -> Color? {
    glowColors[sprite.asset]
}

struct SwiftUISpriteDisplayer: SpriteDisplayer {
    func display(_ sprite: Sprite) -> some View {
        SwiftUiDisplayView(sprite: sprite)
    }
}

struct SwiftUiDisplayView: View {
    let sprite: Sprite
    @State var shadowSize = 20.0

    var imageResourcePath: String? {
        getImageResourcePath(sprite)
    }

    var glowColor: Color? {
        getGlowColor(sprite)
    }

    var body: some View {
        if let imageResourcePath {
            Image(imageResourcePath)
                .resizable()
                .scaledToFit()
                .shadow(color: glowColor ?? .clear, radius: shadowSize)
                .shadow(color: glowColor ?? .clear, radius: shadowSize)
                .frame(width: sprite.visualSize.x,
                       height: sprite.visualSize.y,
                       alignment: .center)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).repeatForever()) {
                        shadowSize = 10.0
                    }
                }
        }
    }
}
