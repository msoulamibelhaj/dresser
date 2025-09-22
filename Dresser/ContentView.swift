import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WardrobeViewModel()
    @State private var showImagePicker = false
    @State private var selectedImage: UIImage?
    @State private var itemName = ""
    @State private var category = "Uncategorized"
    
    init() {
        // Tab bar appearance
        UITabBar.appearance().barTintColor = .black
        UITabBar.appearance().unselectedItemTintColor = .gray
        // Navigation bar appearance
        UINavigationBar.appearance().barTintColor = .black
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    var body: some View {
        TabView {
            wardrobeTab
            OutfitCanvasView(viewModel: viewModel)
                .tabItem { Label("Builder", systemImage: "rectangle.3.offgrid") }
            SavedOutfitsView(viewModel: viewModel)
                .tabItem { Label("Outfits", systemImage: "star") }
            WardrobeCategoriesView(viewModel: viewModel)
                .tabItem { Label("Categories", systemImage: "square.grid.2x2") }
        }
        .accentColor(.white)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                selectedImage = image
            }
        }
        .alert("Add Clothing Item", isPresented: Binding<Bool>(
            get: { selectedImage != nil },
            set: { if !$0 { selectedImage = nil } }
        )) {
            TextField("Name", text: $itemName)
                .foregroundColor(.white)
            Button("Save") {
                if let img = selectedImage {
                    img.removeBackground { processed in
                        DispatchQueue.main.async {
                            let finalImage = processed ?? img
                            let predictedCategory = ClothingClassifier.shared.classify(name: itemName)
                            viewModel.addItem(
                                name: itemName.isEmpty ? "Untitled" : itemName,
                                category: predictedCategory,
                                image: finalImage
                            )
                            resetForm()
                        }
                    }
                }
            }
            .foregroundColor(.white)
            Button("Cancel", role: .cancel) { resetForm() }
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Wardrobe Tab
    private var wardrobeTab: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(viewModel.filteredItems) { item in
                        HStack {
                            if let image = item.image {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                            }
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .foregroundColor(.white)
                                Text(item.category)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete(perform: deleteItem)
                }
                .listStyle(PlainListStyle())
                .searchable(text: $viewModel.searchText)
                .background(Color.black)
            }
            .navigationTitle("Wardrobe")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showImagePicker = true }) {
                        Label("Add Item", systemImage: "plus")
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
        .tabItem { Label("Wardrobe", systemImage: "tshirt") }
    }
    
    // MARK: - Helper Functions
    private func resetForm() {
        selectedImage = nil
        itemName = ""
        category = "Uncategorized"
    }
    
    private func deleteItem(at offsets: IndexSet) {
        let allItems = viewModel.filteredItems
        for index in offsets {
            if let originalIndex = viewModel.items.firstIndex(of: allItems[index]) {
                viewModel.items.remove(at: originalIndex)
            }
        }
    }
}
