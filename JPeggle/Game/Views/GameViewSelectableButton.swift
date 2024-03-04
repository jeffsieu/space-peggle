import SwiftUI

struct GameViewSelectableButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.1 : 1)
            .animation(.bouncy(duration: 0.1, extraBounce: 0.1), value: configuration.isPressed)
    }
}

struct GameViewSelectableButton: View {
    var active = false
    var imageResource: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageResource)
                .resizable()
                .frame(width: 64, height: 64)
                .padding(8)
        }
        .buttonStyle(GameViewSelectableButtonStyle())
        .background(
            active ?
            RoundedRectangle(cornerRadius: 8)
                .stroke(.white, lineWidth: 4) : nil
        )
    }
}
