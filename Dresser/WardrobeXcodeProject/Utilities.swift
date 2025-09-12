import Foundation
import UIKit

func savePNGToDocuments(_ image: UIImage, filename: String) throws -> URL {
    guard let data = image.pngData() else {
        throw NSError(domain: "SavePNG", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to create PNG data"])
    }
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = docs.appendingPathComponent(filename)
    try data.write(to: fileURL, options: .atomic)
    return fileURL
}

func listSavedItems() -> [URL] {
    let fm = FileManager.default
    let docs = fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    do {
        let items = try fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil, options: [])
        return items.filter { $0.pathExtension.lowercased() == "png" }
    } catch {
        return []
    }
}
