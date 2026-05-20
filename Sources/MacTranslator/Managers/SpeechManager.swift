import AppKit
import Foundation

@MainActor
final class SpeechManager: NSObject, NSSpeechSynthesizerDelegate {
    static let shared = SpeechManager()

    private var synthesizer: NSSpeechSynthesizer?

    private override init() {
        super.init()
    }

    func speak(_ text: String, language: TranslationLanguage? = nil) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            return
        }

        synthesizer?.stopSpeaking()

        let detectedLanguage = language ?? LanguageHelper.detectLanguage(for: trimmed)
        let nextSynthesizer = NSSpeechSynthesizer()
        nextSynthesizer.delegate = self
        if let voice = preferredVoice(for: detectedLanguage) {
            nextSynthesizer.setVoice(voice)
        }
        nextSynthesizer.rate = detectedLanguage == .chinese ? 170 : 180
        nextSynthesizer.startSpeaking(trimmed)
        synthesizer = nextSynthesizer
    }

    func stop() {
        synthesizer?.stopSpeaking()
        synthesizer = nil
    }

    nonisolated func speechSynthesizer(
        _ sender: NSSpeechSynthesizer,
        didFinishSpeaking finishedSpeaking: Bool
    ) {
        Task { @MainActor in
            if synthesizer === sender {
                synthesizer = nil
            }
        }
    }

    private func preferredVoice(for language: TranslationLanguage) -> NSSpeechSynthesizer.VoiceName? {
        let voices = NSSpeechSynthesizer.availableVoices
        let preferredIdentifiers: [String]

        switch language {
        case .english:
            preferredIdentifiers = [
                "com.apple.voice.compact.en-US.Samantha",
                "com.apple.speech.synthesis.voice.Alex",
                "com.apple.speech.synthesis.voice.samantha"
            ]
        case .chinese:
            preferredIdentifiers = [
                "com.apple.voice.compact.zh-CN.Tingting",
                "com.apple.speech.synthesis.voice.ting-ting",
                "com.apple.speech.synthesis.voice.ting-ting.premium"
            ]
        }

        if let exactMatch = preferredIdentifiers.first(where: { identifier in
            voices.contains(NSSpeechSynthesizer.VoiceName(rawValue: identifier))
        }) {
            return NSSpeechSynthesizer.VoiceName(rawValue: exactMatch)
        }

        return voices.first { voiceName in
            let attributes = NSSpeechSynthesizer.attributes(forVoice: voiceName)
            let localeIdentifier = attributes[.localeIdentifier] as? String ?? ""
            switch language {
            case .english:
                return localeIdentifier.hasPrefix("en")
            case .chinese:
                return localeIdentifier.hasPrefix("zh")
            }
        }
    }
}
