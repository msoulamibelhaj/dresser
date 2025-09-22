import SwiftUI

struct SavedOutfitsView: View {
    @ObservedObject var viewModel: WardrobeViewModel
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var outfitToPreview: Outfit? = nil
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.outfits) { outfit in
                    ZStack(alignment: .topTrailing) {
                        VStack(alignment: .leading) {
                            if let preview = outfit.preview {
                                Image(uiImage: preview)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 180)
                                    .clipped()
                                    .cornerRadius(16)
                                    .shadow(radius: 3)
                                    .onLongPressGesture {
                                        outfitToPreview = outfit
                                    }
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.2))
                                    .frame(height: 180)
                                    .cornerRadius(16)
                                    .onLongPressGesture {
                                        outfitToPreview = outfit
                                    }
                            }
                            
                            Text(outfit.name)
                                .font(.headline)
                                .padding(.leading, 6)
                                .padding(.top, 4)
                        }
                        
                        // Small trash button
                        Button(role: .destructive) {
                            viewModel.deleteOutfit(outfit)
                        } label: {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(.red)
                                .font(.title2)
                        }
                        .padding(6)
                    }
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Saved Outfits")
        // MARK: - Full preview sheet
        .sheet(item: $outfitToPreview) { outfit in
            VStack {
                if let preview = outfit.preview {
                    Image(uiImage: preview)
                        .resizable()
                        .scaledToFit()
                        .padding()
                } else {
                    Text("No preview available")
                        .font(.headline)
                }
                
                Button("Close") {
                    outfitToPreview = nil
                }
                .padding()
            }
        }
    }
}
