import Foundation

final class PhoneticManager {
    static let shared = PhoneticManager()

    private let fallbackPhonetics: [String: String] = [
        "apple": "[ˈæpl]",
        "banana": "[bəˈnænə]",
        "cat": "[kæt]",
        "dog": "[dɔːɡ]",
        "hello": "[həˈloʊ]",
        "love": "[lʌv]",
        "mac": "[mæk]",
        "swift": "[swɪft]",
        "translation": "[trænzˈleɪʃn]",
        "word": "[wɜːrd]"
    ]

    private init() {}

    func phonetic(sourceText: String, translatedText: String) async -> String {
        guard let word = LanguageHelper.bestEnglishWord(source: sourceText, translated: translatedText) else {
            return ""
        }

        let normalized = word
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if let fallback = fallbackPhonetics[normalized] {
            return fallback
        }

        do {
            return try await fetchPhonetic(for: normalized)
        } catch {
            return ""
        }
    }

    private func fetchPhonetic(for word: String) async throws -> String {
        guard let escapedWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://api.dictionaryapi.dev/api/v2/entries/en/\(escapedWord)") else {
            return ""
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            return ""
        }

        let entries = try JSONDecoder().decode([DictionaryEntry].self, from: data)
        let phonetic = entries
            .flatMap(\.phonetics)
            .compactMap(\.text)
            .first { $0.isEmpty == false } ?? entries.first?.phonetic ?? ""

        if phonetic.isEmpty {
            return ""
        }

        if phonetic.hasPrefix("[") || phonetic.hasPrefix("/") {
            return phonetic
        }

        return "[\(phonetic)]"
    }
}

private struct DictionaryEntry: Decodable {
    let phonetic: String?
    let phonetics: [Phonetic]

    struct Phonetic: Decodable {
        let text: String?
    }
}
