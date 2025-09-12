import SwiftUI

struct ContentView: View {
    @State private var showPicker = false
    @State private var pickerCamera = false
    @State private var pickedImage: UIImage?
    @State private var processedImage: UIImage?
    @State private var items: [ClothingItem] = []
    @State private var layers: [LayerModel] = []
    @State private var showingCanvas = false
    @State private var isProcessing = false
    @State private var statusText = ""

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: { pickerCamera = false; showPicker = true }) {
                        Label("Add Photo", systemImage: "photo.on.rectangle")
                    }
                    Spacer()
                    Button(action: { pickerCamera = true; showPicker = true }) {
                        Label("Take Photo", systemImage: "camera")
                    }
                    Spacer()
                    Button(action: loadSavedItems) {
                        Label("Refresh", systemImage: "arrow.clockwise")
                    }
                }.padding()

                if let img = processedImage {
                    Text("Processed preview")
                    Image(uiImage: img).resizable().scaledToFit().frame(height: 180).padding()
                }

                if isProcessing {
                    ProgressView(statusText)
                        .padding()
                }

                List {
                    Section(header: Text("Library")) {
                        if items.isEmpty {
                            Text("No items yet")
                        } else {
                            ForEach(items) { item in
                                HStack {
                                    if let ui = loadImageNamed(item.filename) {
                                        Image(uiImage: ui).resizable().frame(width: 60, height: 60).cornerRadius(6)
                                    } else {
                                        Rectangle().fill(Color.gray).frame(width: 60, height: 60)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                        Text(item.category ?? "").font(.caption)
                                    }
                                    Spacer()
                                    Button("Add to canvas") {
                                        if let ui = loadImageNamed(item.filename) {
                                            let layer = LayerModel(item: item, image: ui)
                                            layers.append(layer)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                NavigationLink(destination: CollageCanvasView(layers: $layers), isActive: $showingCanvas) {
                    EmptyView()
                }

                HStack {
                    Button(action: { showingCanvas = true }) {
                        Label("Open Canvas (\(layers.count))", systemImage: "square.on.square")
                    }
                    Spacer()
                    Button(action: { exportAllSaved() }) {
                        Label("Export Library", systemImage: "square.and.arrow.up")
                    }
                }.padding()
            }
            .navigationTitle("Wardrobe")
            .sheet(isPresented: $showPicker, onDismiss: handlePickedImage) {
                PhotoPicker(image: $pickedImage, sourceTypeCamera: pickerCamera)
            }
            .onAppear { loadSavedItems() }
        }
    }

    func handlePickedImage() {
        guard let img = pickedImage else { return }
        isProcessing = true
        statusText = "Removing background..."
        BackgroundRemover.removeBackground(from: img) { result in
            isProcessing = false
            if let r = result {
                processedImage = r
                // Save PNG
                let fname = "item-\(UUID().uuidString).png"
                do {
                    let _ = try savePNGToDocuments(r, filename: fname)
                    let item = ClothingItem(id: UUID(), name: "Item \(items.count + 1)", filename: fname, category: nil, createdAt: Date())
                    items.append(item)
                } catch {
                    print("Save failed: \(error)")
                }
            } else {
                statusText = "Background removal failed"
            }
            // reset picker
            pickedImage = nil
        }
    }

    func loadSavedItems() {
        items.removeAll()
        let urls = listSavedItems()
        for url in urls {
            let name = url.lastPathComponent
            let item = ClothingItem(id: UUID(), name: name, filename: name, category: nil, createdAt: Date())
            items.append(item)
        }
    }

    func loadImageNamed(_ filename: String) -> UIImage? {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = docs.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }

    func exportAllSaved() {
        // For demo: just print saved PNG paths
        let urls = listSavedItems()
        print("Saved library items:", urls)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
