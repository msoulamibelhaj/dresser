import SwiftUI

struct ClothingItemCard: View {
    let item: ClothingItem
    let onDelete: () -> Void
    @State private var showingOriginal = false
    
    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                Image(uiImage: showingOriginal ? item.originalImage : item.processedImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 150)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    .onTapGesture {
                        showingOriginal.toggle()
                    }
                
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                        .background(Color.white)
                        .clipShape(Circle())
                }
                .padding(8)
            }
            
            HStack {
                Button(showingOriginal ? "Show Processed" : "Show Original") {
                    showingOriginal.toggle()
                }
                .font(.caption)
                .foregroundColor(.blue)
                Spacer()
            }
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
