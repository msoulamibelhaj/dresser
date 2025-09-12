import SwiftUI
import Foundation
// Simple models used by the starter app

struct ClothingItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var filename: String // PNG in Documents
    var category: String?
    var createdAt: Date
}

struct LayerModel: Identifiable {
    let id = UUID()
    var item: ClothingItem
    var image: UIImage
    var offset: CGSize = .zero
    var scale: CGFloat = 1.0
    var rotation: Angle = .zero
}
