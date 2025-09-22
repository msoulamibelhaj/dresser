import SwiftUI

struct WardrobeCategoriesView: View {
    @ObservedObject var viewModel: WardrobeViewModel
    
    // Categories
    @State private var selectedCategory: String = "All"
    private let categories = ["All","Tops","Bottoms","Shoes","Outerwear","Accessories"]
    
    // Delete
    @State private var showDeleteAlert: Bool = false
    @State private var itemToDelete: ClothingItem? = nil
    
    var body: some View {
        VStack {
            // MARK: - Scrollable category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categories, id: \.self) { category in
                        Text(category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16)
                            .background(
                                selectedCategory == category
                                    ? Color.white.opacity(0.1)
                                    : Color.white.opacity(0.05)
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedCategory == category ? Color.white : Color.clear, lineWidth: 1)
                            )
                            .cornerRadius(12)
                            .onTapGesture {
                                selectedCategory = category
                            }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            
            // MARK: - Grid of clothing items
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100), spacing: 12)], spacing: 12) {
                    ForEach(filteredItems) { item in
                        ZStack(alignment: .topTrailing) {
                            if let img = item.image {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 140)
                                    .background(Color.white.opacity(0.05))
                                    .cornerRadius(12)
                                    .shadow(color: Color.white.opacity(0.1), radius: 3, x: 0, y: 2)
                                    .onLongPressGesture {
                                        itemToDelete = item
                                        showDeleteAlert = true
                                    }
                            } else {
                                Rectangle()
                                    .fill(Color.white.opacity(0.05))
                                    .frame(height: 140)
                                    .cornerRadius(12)
                            }
                            
                            // Small delete button when selected
                            if itemToDelete?.id == item.id {
                                Button(action: {
                                    deleteItem(item)
                                    itemToDelete = nil
                                }) {
                                    Image(systemName: "trash.fill")
                                        .foregroundColor(.red)
                                        .padding(6)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                }
                                .offset(x: -8, y: 8)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .alert(isPresented: $showDeleteAlert) {
            Alert(
                title: Text("Delete Item"),
                message: Text("Are you sure you want to delete this item?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let item = itemToDelete {
                        deleteItem(item)
                    }
                },
                secondaryButton: .cancel {
                    itemToDelete = nil
                }
            )
        }
    }
    
    // MARK: - Filtered items
    private var filteredItems: [ClothingItem] {
        if selectedCategory == "All" {
            return viewModel.items
        } else {
            return viewModel.items.filter { $0.category == selectedCategory }
        }
    }
    
    // MARK: - Delete
    private func deleteItem(_ item: ClothingItem) {
        if let index = viewModel.items.firstIndex(of: item) {
            viewModel.items.remove(at: index)
        }
    }
}
