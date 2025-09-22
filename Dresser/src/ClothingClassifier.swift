import UIKit

class ClothingClassifier {
    static let shared = ClothingClassifier()
    
    private let categoryKeywords: [String: [String]] = [
        "Tops": ["tshirt", "shirt", "blouse", "hoodie", "sweater", "tank", "top", "jacket", "tee", "pullover"],
        "Bottoms": ["jeans", "pants", "trousers", "shorts", "skirt", "leggings", "slacks", "denim"],
        "Shoes": ["sneaker", "shoe", "boot", "sandals", "heels", "loafers", "sneakers"],
        "Outerwear": ["coat", "jacket", "parka", "blazer", "anorak", "overcoat"],
        "Accessories": ["hat", "cap", "scarf", "belt", "glasses", "watch", "bag", "beanie", "sunglasses"]
    ]
    
    private let matchThreshold: Double = 0.7
    
    func classify(name: String) -> String {
        let lowercased = name.lowercased()
        // Check all words in the name
        let words = lowercased.split(separator: " ").map { String($0) }
        
        for word in words {
            for (category, keywords) in categoryKeywords {
                for keyword in keywords {
                    if fuzzyMatch(word, keyword) {
                        return category
                    }
                }
            }
        }
        return "Uncategorized"
    }
    
    private func fuzzyMatch(_ a: String, _ b: String) -> Bool {
        let distance = levenshtein(a, b)
        let maxLength = Double(max(a.count, b.count))
        let similarity = 1 - (Double(distance) / maxLength)
        return similarity >= matchThreshold
    }
    
    private func levenshtein(_ a: String, _ b: String) -> Int {
        let aChars = Array(a), bChars = Array(b)
        var dist = [[Int]](repeating: [Int](repeating: 0, count: bChars.count + 1), count: aChars.count + 1)
        for i in 0...aChars.count { dist[i][0] = i }
        for j in 0...bChars.count { dist[0][j] = j }
        for i in 1...aChars.count {
            for j in 1...bChars.count {
                if aChars[i-1] == bChars[j-1] {
                    dist[i][j] = dist[i-1][j-1]
                } else {
                    dist[i][j] = 1 + min(dist[i-1][j-1], dist[i][j-1], dist[i-1][j])
                }
            }
        }
        return dist[aChars.count][bChars.count]
    }
}
