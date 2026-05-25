import Foundation
import Combine

@MainActor
final class MemoInputViewModel: ObservableObject {
    @Published var memoText: String = ""
    @Published var generatedQuestion: String?
    @Published var state: ViewState = .idle
    @Published var isSaved: Bool = false

    var canSubmit: Bool {
        !memoText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private let aiService: AIService
    private let repository: MemoLogRepository

    init(
        aiService: AIService,
        repository: MemoLogRepository = LocalMemoLogRepository()
    ) {
        self.aiService = aiService
        self.repository = repository
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

    func submitAnswer(_ answer: String) throws {
        guard let question = generatedQuestion else { return }

        let trimmed = answer.trimmingCharacters(in: .whitespacesAndNewlines)
        let log = MemoLog(
            memo: memoText,
            question: question,
            answer: trimmed.isEmpty ? nil : trimmed,
            isAnswerSkipped: trimmed.isEmpty
        )
        try repository.save(log)
        isSaved = true
    }

    func skipAnswer() throws {
        guard let question = generatedQuestion else { return }

        let log = MemoLog(
            memo: memoText,
            question: question,
            answer: nil,
            isAnswerSkipped: true
        )
        try repository.save(log)
        isSaved = true
    }
}
