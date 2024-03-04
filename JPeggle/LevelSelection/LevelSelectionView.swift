import SwiftUI

struct LevelSelectionView: View {
    @StateObject private var controller = LevelSelectionController()

    var body: some View {
        List(controller.levels, id: \.level.id) { loadedLevel in
            NavigationLink(
                destination: GameView(level: loadedLevel.level)) {
                Text(loadedLevel.level.name)
            }
        }
        .task {
            await controller.initialize()
        }
        .navigationTitle("Level selection")
    }
}

#Preview {
    NavigationStack {
        EmptyView().navigationTitle("Main menu")
        LevelSelectionView()
    }
}
