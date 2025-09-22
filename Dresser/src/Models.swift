import SwiftUI

struct ClothingItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let category: String
    var imageData: Data?

    var image: UIImage? {
        get { imageData.flatMap { UIImage(data: $0) } }
        set { imageData = newValue?.pngData() } // <-- PNG preserves transparency
    }

    init(id: UUID = UUID(), name: String, category: String, image: UIImage? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.imageData = image?.pngData() // <-- PNG
    }
}

struct Outfit: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var items: [CanvasItem]
    var previewData: Data?

    var preview: UIImage? {
        get { previewData.flatMap { UIImage(data: $0) } }
        set { previewData = newValue?.pngData() } // <-- PNG
    }

    static func == (lhs: Outfit, rhs: Outfit) -> Bool { lhs.id == rhs.id }
}


struct CanvasItem: Identifiable, Codable {
    let id: UUID
    let item: ClothingItem
    let position: CGPoint
}

struct DraggableItemState: Identifiable {
    let id = UUID()
    let item: ClothingItem
    var offset: CGSize = .zero
}
