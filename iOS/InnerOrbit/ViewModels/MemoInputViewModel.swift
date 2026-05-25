import Foundation
import Combine

@MainActor
final class MemoInputViewModel: ObservableObject {
    @Published var memoText: String = ""
    @Published var generatedQuestion: String?
    @Published var state: ViewState = .idle

    var canSubmit: Bool {
        !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let aiService: AIService

    init(aiService: AIService) {
        self.aiService = aiService
    }

    func submitMemo() async {
        guard canSubmit else { return }
        if case .loading = state { return }

        state = .loading

        do {
            let question = try await aiService.generateQuestion(from: memoText)
            generatedQuestion = question
            state = .success
        } catch {
            state = .error(error)
        }
    }
}
