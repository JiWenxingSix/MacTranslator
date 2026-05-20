import Foundation

enum TranslationLanguage: String, Codable {
    case english = "en"
    case chinese = "zh-CN"

    var displayName: String {
        switch self {
        case .english:
            "English"
        case .chinese:
            "中文"
        }
    }
}

enum LanguageHelper {
    static func detectLanguage(for text: String) -> TranslationLanguage {
        text.containsChineseCharacters ? .chinese : .english
    }

    static func targetLanguage(for source: TranslationLanguage) -> TranslationLanguage {
        source == .chinese ? .english : .chinese
    }

    static func isSingleWord(_ text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard (2...32).contains(trimmed.count) else {
            return false
        }

        let separators = CharacterSet.whitespacesAndNewlines
            .union(.punctuationCharacters)
            .subtracting(CharacterSet(charactersIn: "-'"))

        return trimmed.rangeOfCharacter(from: separators) == nil
    }

    static func bestEnglishWord(source: String, translated: String) -> String? {
        let sourceText = source.trimmingCharacters(in: .whitespacesAndNewlines)
        let translatedText = translated.trimmingCharacters(in: .whitespacesAndNewlines)

        if detectLanguage(for: sourceText) == .english, isSingleWord(sourceText) {
            return sourceText
        }

        if detectLanguage(for: translatedText) == .english, isSingleWord(translatedText) {
            return translatedText
        }

        return nil
    }
}

private extension String {
    var containsChineseCharacters: Bool {
        unicodeScalars.contains { scalar in
            (0x4E00...0x9FFF).contains(Int(scalar.value)) ||
            (0x3400...0x4DBF).contains(Int(scalar.value))
        }
    }
}
