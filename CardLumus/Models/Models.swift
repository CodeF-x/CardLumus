import UIKit

struct Word: Codable {
    let term: String
    let translation: String
    let sentence: String 
}

struct Category: Codable {
    let id: UUID
    var name: String
    var words: [Word]
}
