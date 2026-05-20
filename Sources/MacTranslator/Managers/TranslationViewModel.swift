import Combine
import Foundation

@MainActor
final class TranslationViewModel: ObservableObject {
    @Published var inputText = ""
    @Published private(set) var result: TranslationResult?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let translationManager = TranslationManager()
    private var cancellables = Set<AnyCancellable>()
    private var translationTask: Task<Void, Never>?

    init() {
        $inputText
            .removeDuplicates()
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.scheduleTranslation(for: text)
            }
            .store(in: &cancellables)
    }

    deinit {
        translationTask?.cancel()
    }

    private func scheduleTranslation(for text: String) {
        translationTask?.cancel()
        errorMessage = nil

        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else {
            result = nil
            isLoading = false
            return
        }

        isLoading = true
        translationTask = Task { [weak self] in
            guard let self else { return }

            do {
                let translated = try await translationManager.translate(trimmed)
                guard Task.isCancelled == false else { return }
                result = translated
                isLoading = false
            } catch {
                guard Task.isCancelled == false else { return }
                result = nil
                isLoading = false
                errorMessage = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
            }
        }
    }
}
