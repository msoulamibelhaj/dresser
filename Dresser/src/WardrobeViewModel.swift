import SwiftUI

class WardrobeViewModel: ObservableObject {
    @Published var items: [ClothingItem] = []
    @Published var outfits: [Outfit] = []
    @Published var searchText = ""
    
    private let wardrobeKey = "SavedWardrobeItems"
    private let outfitsKey = "SavedOutfits"
    
    init() {
        loadWardrobe()
        loadOutfits()
    }
    
    var filteredItems: [ClothingItem] {
        if searchText.isEmpty { return items }
        return items.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
    
    // MARK: - Helper to save images
    private func saveImageToDisk(_ image: UIImage, id: UUID) -> String? {
        guard let data = image.pngData() else { return nil } // PNG keeps alpha
        let filename = getDocumentsDirectory().appendingPathComponent("\(id).png")
        do {
            try data.write(to: filename)
            return filename.path
        } catch {
            print("Failed to save image:", error)
            return nil
        }
    }
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    // MARK: - Wardrobe persistence
    func saveWardrobe() {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: wardrobeKey)
        } catch { print("Failed to save wardrobe:", error) }
    }
    
    func loadWardrobe() {
        guard let data = UserDefaults.standard.data(forKey: wardrobeKey) else { return }
        do { items = try JSONDecoder().decode([ClothingItem].self, from: data) }
        catch { print("Failed to load wardrobe:", error) }
    }
    
    func addItem(name: String, category: String, image: UIImage?) {
        let newItem = ClothingItem(
            name: name,
            category: category,
            image: image // ClothingItem will store PNG to preserve transparency
        )
        items.append(newItem)
        saveWardrobe()
    }
    
    func deleteItem(_ item: ClothingItem) {
        items.removeAll { $0.id == item.id }
        saveWardrobe()
    }
    
    // MARK: - Outfits persistence
    func saveOutfits() {
        do {
            let data = try JSONEncoder().encode(outfits)
            UserDefaults.standard.set(data, forKey: outfitsKey)
        } catch { print("Failed to save outfits:", error) }
    }
    
    func loadOutfits() {
        guard let data = UserDefaults.standard.data(forKey: outfitsKey) else { return }
        do { outfits = try JSONDecoder().decode([Outfit].self, from: data) }
        catch { print("Failed to load outfits:", error) }
    }
    
    func createOutfit(name: String, canvasItems: [DraggableItemState], preview: UIImage) {
        let outfitItems = canvasItems.map {
            CanvasItem(id: $0.id, item: $0.item, position: CGPoint(x: $0.offset.width, y: $0.offset.height))
        }
        let outfit = Outfit(
            id: UUID(),
            name: name,
            items: outfitItems,
            previewData: preview.pngData() // Use PNG to preserve transparency
        )
        outfits.append(outfit)
        saveOutfits()
    }
    
    func deleteOutfit(_ outfit: Outfit) {
        outfits.removeAll { $0.id == outfit.id }
        saveOutfits()
    }
}

