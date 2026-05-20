import SwiftData
import SwiftUI

struct TranslationView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = TranslationViewModel()
    @State private var archivedResultIDs = Set<UUID>()

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            header

            GeometryReader { proxy in
                if proxy.size.width > 820 {
                    HStack(spacing: 18) {
                        inputPanel
                        outputPanel
                    }
                } else {
                    VStack(spacing: 18) {
                        inputPanel
                        outputPanel
                    }
                }
            }
        }
        .padding(24)
        .navigationTitle("即时翻译")
        .onChange(of: viewModel.result?.id) { _, _ in
            archiveCurrentWordIfNeeded()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("即时翻译")
                    .font(.largeTitle.bold())
                Text("输入停止 0.5 秒后自动识别语言并翻译")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if viewModel.isLoading {
                ProgressView()
                    .controlSize(.small)
            }
        }
    }

    private var inputPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            panelTitle(
                title: "原文",
                subtitle: LanguageHelper.detectLanguage(for: viewModel.inputText).displayName,
                text: viewModel.inputText,
                language: LanguageHelper.detectLanguage(for: viewModel.inputText)
            )

            TextEditor(text: $viewModel.inputText)
                .font(.system(size: 19, weight: .regular, design: .rounded))
                .scrollContentBackground(.hidden)
                .padding(10)
                .frame(minHeight: 260)
                .background(.background)
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(.quaternary, lineWidth: 1)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var outputPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            panelTitle(
                title: "译文",
                subtitle: viewModel.result?.targetLanguage.displayName ?? "自动",
                text: viewModel.result?.translatedText ?? "",
                language: viewModel.result?.targetLanguage
            )

            VStack(alignment: .leading, spacing: 14) {
                ScrollView {
                    Text(outputText)
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundStyle(viewModel.result == nil ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .textSelection(.enabled)
                }

                if let phonetic = viewModel.result?.phonetic, phonetic.isEmpty == false {
                    Text(phonetic)
                        .font(.system(.title3, design: .rounded))
                        .foregroundStyle(.blue)
                        .textSelection(.enabled)
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.callout)
                        .foregroundStyle(.red)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 260, maxHeight: .infinity, alignment: .topLeading)
            .background(.background)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(.quaternary, lineWidth: 1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var outputText: String {
        if let translatedText = viewModel.result?.translatedText {
            return translatedText
        }

        if viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "译文会在这里自动出现"
        }

        return viewModel.isLoading ? "正在翻译..." : "等待翻译"
    }

    private func panelTitle(
        title: String,
        subtitle: String,
        text: String,
        language: TranslationLanguage?
    ) -> some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                SpeechManager.shared.speak(text, language: language)
            } label: {
                Image(systemName: "speaker.wave.2")
            }
            .buttonStyle(.borderless)
            .help("朗读")
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        }
    }

    private func archiveCurrentWordIfNeeded() {
        guard let result = viewModel.result,
              archivedResultIDs.contains(result.id) == false,
              LanguageHelper.isSingleWord(result.sourceText) else {
            return
        }

        archivedResultIDs.insert(result.id)

        let word = result.sourceText.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<VocabularyItem>()

        do {
            let existingItems = try modelContext.fetch(descriptor)
            let hasSameWord = existingItems.contains { item in
                item.word.caseInsensitiveCompare(word) == .orderedSame
            }

            guard hasSameWord == false else {
                return
            }

            let item = VocabularyItem(
                word: result.sourceText,
                translation: result.translatedText,
                phonetic: result.phonetic
            )
            modelContext.insert(item)
            try modelContext.save()
        } catch {
            print("Failed to archive vocabulary item: \(error.localizedDescription)")
        }
    }
}
