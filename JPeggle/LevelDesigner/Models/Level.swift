import Foundation

struct Level: Saveable, Hashable, Identifiable {
    var id = UUID()
    var name: String = "Untitled level"
    var board: Board
}
