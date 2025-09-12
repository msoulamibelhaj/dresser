import SwiftUI

struct CollageCanvasView: View {
    @Binding var layers: [LayerModel]
    @State private var selectedID: UUID?

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color(UIColor.systemBackground)
                ForEach($layers) { $layer in
                    LayerView(layer: $layer, isSelected: selectedID == layer.id)
                        .onTapGesture {
                            selectedID = layer.id
                        }
                }
            }
            .clipped()
            .navigationBarItems(trailing: Button("Export") {
                let img = renderCanvas(size: geo.size)
                if let data = img.pngData() {
                    let fname = "outfit-\(UUID().uuidString).png"
                    let _ = try? data.write(to: FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fname))
                    print("Saved outfit to \(fname)")
                }
            })
        }
    }

    // Render layers into a single UIImage
    func renderCanvas(size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            UIColor.systemBackground.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
            for layer in layers {
                let img = layer.image
                // We'll draw each image centered with transforms
                let w = img.size.width * layer.scale
                let h = img.size.height * layer.scale
                let x = (size.width - w)/2 + layer.offset.width
                let y = (size.height - h)/2 + layer.offset.height
                ctx.cgContext.saveGState()
                let center = CGPoint(x: x + w/2, y: y + h/2)
                ctx.cgContext.translateBy(x: center.x, y: center.y)
                ctx.cgContext.rotate(by: CGFloat(layer.rotation.radians))
                img.draw(in: CGRect(x: -w/2, y: -h/2, width: w, height: h))
                ctx.cgContext.restoreGState()
            }
        }
    }
}

struct LayerView: View {
    @Binding var layer: LayerModel
    var isSelected: Bool

    @State private var currentDrag: CGSize = .zero
    @State private var currentScale: CGFloat = 1.0
    @State private var currentRotation: Angle = .zero

    var body: some View {
        Image(uiImage: layer.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: layer.image.size.width * 0.4, height: layer.image.size.height * 0.4)
            .scaleEffect(layer.scale * currentScale)
            .rotationEffect(layer.rotation + currentRotation)
            .offset(x: layer.offset.width + currentDrag.width, y: layer.offset.height + currentDrag.height)
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2))
            .gesture(simultaneousGestures())
    }

    func simultaneousGestures() -> some Gesture {
        let drag = DragGesture()
            .onChanged { v in currentDrag = v.translation }
            .onEnded { v in
                layer.offset.width += v.translation.width
                layer.offset.height += v.translation.height
                currentDrag = .zero
            }
        let mag = MagnificationGesture()
            .onChanged { v in currentScale = v }
            .onEnded { v in layer.scale *= v; currentScale = 1.0 }
        let rot = RotationGesture()
            .onChanged { a in currentRotation = a }
            .onEnded { a in layer.rotation += a; currentRotation = .zero }
        return SimultaneousGesture(SimultaneousGesture(drag, mag), rot)
    }
}
