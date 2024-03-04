import SwiftUI

struct BlackHoleView: View {
    let showBlackHole: Bool
    let blackHoleSize: Double
    let openDuration: TimeInterval
    @State private var blackHoleVisible = false
    @State private var showParticles = false
    @State private var blackHoleRotation = 0.0

    var blackHole: some View {
        let blackCircleParticle = Circle()
            .fill(.black)
            .frame(width: 32, height: 32)

        return Circle()
            .fill(.black)
            .frame(width: blackHoleSize, height: blackHoleSize)
            .shadow(radius: blackHoleSize)
            .overlay(
                ZStack {
                    blackCircleParticle.offset(x: -blackHoleSize * 1.7, y: -blackHoleSize * 1.2)
                    blackCircleParticle.offset(x: blackHoleSize * 0.45, y: -blackHoleSize * 1.1)
                    blackCircleParticle.offset(x: -blackHoleSize * 0.75, y: blackHoleSize * 1.05)
                    blackCircleParticle.offset(x: blackHoleSize * 1.05, y: blackHoleSize * 0.45)

                }
                .opacity(showParticles ? 1 : 0)
            )
            .rotationEffect(.radians(blackHoleRotation))
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    blackHoleRotation = .pi * 2
                }
            }
    }

    var body: some View {
        blackHole
            .scaleEffect(blackHoleVisible ? 1 : 0)
            .opacity(blackHoleVisible ? 1 : 0)
            .onChange(of: showBlackHole) {
                guard showBlackHole else {
                    return
                }

                showParticles = false
                withAnimation(.easeInOut(duration: openDuration / 4)) {
                    blackHoleVisible = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + openDuration) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showParticles = true
                        blackHoleVisible = false
                    }
                }
            }
    }
}

#Preview {
    BlackHoleView(
        showBlackHole: true,
        blackHoleSize: 100,
        openDuration: 1
    )
}
