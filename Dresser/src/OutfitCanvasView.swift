import SwiftUI

struct OutfitCanvasView: View {
    @ObservedObject var viewModel: WardrobeViewModel
    @State var canvasItems: [DraggableItemState] = []
    @State private var outfitName: String = ""
    @State private var showSaveAlert = false
    
    @State private var selectedCategory: String = "All"
    private let categories = ["All","Tops","Bottoms","Shoes","Outerwear","Accessories"]
    @State private var hideOnCanvas: Bool = true
    
    var body: some View {
        VStack(spacing: 16) {
            // MARK: - Category filter
            Picker("Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { Text($0) }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .background(Color.black)
            .accentColor(.white) // Selected segment white
            
            // MARK: - Hide toggle
            Toggle("Hide items already on canvas", isOn: $hideOnCanvas)
                .padding(.horizontal)
                .toggleStyle(SwitchToggleStyle(tint: .white))
                .foregroundColor(.black)
            
            // MARK: - Scrollable items
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(filteredItems) { item in
                        if let img = item.image {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .onTapGesture {
                                    if !canvasItems.contains(where: { $0.item.id == item.id }) {
                                        canvasItems.append(DraggableItemState(item: item))
                                    }
                                }
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // MARK: - Canvas
            ZStack {
                Color.black.opacity(0.9)
                    .cornerRadius(12)
                    .shadow(radius: 3)
                
                ForEach($canvasItems) { $draggable in
                    DraggableImageView(draggable: $draggable)
                }
            }
            .frame(width: 300, height: 400)
            .padding()
            
            // MARK: - Save button
            Button(action: { showSaveAlert = true }) {
                Text("Save Outfit")
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert("Outfit Name", isPresented: $showSaveAlert) {
            TextField("Name", text: $outfitName)
            Button("Save") {
                guard !canvasItems.isEmpty else { return }
                let preview = snapshotCanvas()
                viewModel.createOutfit(
                    name: outfitName.isEmpty ? "Untitled" : outfitName,
                    canvasItems: canvasItems,
                    preview: preview
                )
                canvasItems.removeAll()
                outfitName = ""
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    // MARK: - Filtered items
    private var filteredItems: [ClothingItem] {
        var arr = viewModel.items
        if selectedCategory != "All" { arr = arr.filter { $0.category == selectedCategory } }
        if hideOnCanvas { arr = arr.filter { item in !canvasItems.contains(where: { $0.item.id == item.id }) } }
        return arr
    }
    
    // MARK: - Snapshot Canvas
    private func snapshotCanvas() -> UIImage {
        let canvasView = ZStack {
            Color.black.opacity(0.9)
            ForEach(canvasItems) { draggable in
                if let img = draggable.item.image {
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .offset(draggable.offset)
                }
            }
        }
        .frame(width: 300, height: 400)
        
        let controller = UIHostingController(rootView: canvasView)
        let view = controller.view
        view?.bounds = CGRect(origin: .zero, size: CGSize(width: 300, height: 400))
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 300, height: 400))
        return renderer.image { _ in
            view?.drawHierarchy(in: view!.bounds, afterScreenUpdates: true)
        }
    }
}
