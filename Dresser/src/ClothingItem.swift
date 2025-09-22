import SwiftUI

struct CanvasItem: Identifiable, Codable {
    var id: UUID = UUID()           // Unique ID
    var item: ClothingItem          // Reference to the clothing item
    var position: CGPoint = .zero   // x, y position on the canvas

    // Codable support for saving/loading
    enum CodingKeys: String, CodingKey {
        case id, item, position
    }
}
