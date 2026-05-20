import Foundation
import SwiftData

@Model
final class VocabularyItem {
    var word: String
    var translation: String
    var phonetic: String
    var timestamp: Date
    var isLearned: Bool

    init(
        word: String,
        translation: String,
        phonetic: String = "",
        timestamp: Date = .now,
        isLearned: Bool = false
    ) {
        self.word = word
        self.translation = translation
        self.phonetic = phonetic
        self.timestamp = timestamp
        self.isLearned = isLearned
    }
}
