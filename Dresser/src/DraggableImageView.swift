import SwiftUI

struct DraggableImageView: View {
    @Binding var draggable: DraggableItemState
    @GestureState private var dragOffset: CGSize = .zero
    
    var body: some View {
        if let image = draggable.item.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 120, height: 120)
                .offset(x: draggable.offset.width + dragOffset.width,
                        y: draggable.offset.height + dragOffset.height)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { value, state, _ in
                            state = value.translation
                        }
                        .onEnded { value in
                            draggable.offset.width += value.translation.width
                            draggable.offset.height += value.translation.height
                        }
                )
                .contextMenu {
                    Button(role: .destructive) {
                        draggable.offset = .zero
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
        }
    }
}
