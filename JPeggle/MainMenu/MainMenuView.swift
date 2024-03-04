import SwiftUI

struct MainMenuView: View {
    var body: some View {
        VStack(spacing: 16) {
            NavigationLink(destination: LevelSelectionView()) {
                Text("Level Selection")
            }
            NavigationLink(destination: LevelDesignerView()) {
                Text("Level Designer")
            }
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.extraLarge)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .background(
            Image("background")
                .resizable()
                .contentShape(Rectangle())
                .allowsHitTesting(false)
        )
        .ignoresSafeArea()
        .navigationTitle("Main menu")
        .toolbar(.hidden)
    }
}

#Preview {
    MainMenuView()
}
