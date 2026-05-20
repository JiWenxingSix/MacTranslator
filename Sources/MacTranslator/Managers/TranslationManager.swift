import Foundation

struct TranslationResult: Identifiable, Equatable {
    let id = UUID()
    let sourceText: String
    let translatedText: String
    let sourceLanguage: TranslationLanguage
    let targetLanguage: TranslationLanguage
    let phonetic: String
}

enum TranslationError: LocalizedError {
    case invalidURL
    case invalidResponse
    case emptyResult

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            "无法创建翻译请求。"
        case .invalidResponse:
            "翻译服务暂时不可用。"
        case .emptyResult:
            "没有获得有效译文。"
        }
    }
}

final class TranslationManager {
    private struct MyMemoryResponse: Decodable {
        let responseData: ResponseData

        struct ResponseData: Decodable {
            let translatedText: String
        }
    }

    func translate(_ text: String) async throws -> TranslationResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let sourceLanguage = LanguageHelper.detectLanguage(for: trimmed)
        let targetLanguage = LanguageHelper.targetLanguage(for: sourceLanguage)
        let translated = try await fetchTranslation(
            text: trimmed,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage
        )
        let phonetic = await PhoneticManager.shared.phonetic(
            sourceText: trimmed,
            translatedText: translated
        )

        return TranslationResult(
            sourceText: trimmed,
            translatedText: translated,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLanguage,
            phonetic: phonetic
        )
    }

    private func fetchTranslation(
        text: String,
        sourceLanguage: TranslationLanguage,
        targetLanguage: TranslationLanguage
    ) async throws -> String {
        var components = URLComponents(string: "https://api.mymemory.translated.net/get")
        components?.queryItems = [
            URLQueryItem(name: "q", value: text),
            URLQueryItem(
                name: "langpair",
                value: "\(sourceLanguage.rawValue)|\(targetLanguage.rawValue)"
            )
        ]

        guard let url = components?.url else {
            throw TranslationError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw TranslationError.invalidResponse
        }

        let payload = try JSONDecoder().decode(MyMemoryResponse.self, from: data)
        let translated = payload.responseData.translatedText
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard translated.isEmpty == false else {
            throw TranslationError.emptyResult
        }

        return translated
    }
}
