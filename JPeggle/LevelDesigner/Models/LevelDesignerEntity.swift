import Foundation

struct LevelDesignerEntity: Identifiable {
    let id: UUID
    let sprite: Sprite
    let transform: Transform
    let health: Health?
    let zIndex: Double?
    let canResizeFreely: Bool
}
