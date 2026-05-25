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
    // QuestionView 実装時に repository を渡して保存を有効化する。
    // nil の場合 submitAnswer/skipAnswer は保存をスキップする（Phase 0 暫定）。
    private let repository: MemoLogRepository?

    init(aiService: AIService, repository: MemoLogRepository? = nil) {
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
        guard !trimmed.isEmpty else {
            try skipAnswer()
            return
        }

        let log = MemoLog(
            memo: memoText,
            question: question,
            answer: trimmed,
            isAnswerSkipped: false
        )
        assert(repository != nil, "submitAnswer called without a repository — wire up repository in MemoInputView init")
        try repository?.save(log)
    }

    func skipAnswer() throws {
        guard let question = generatedQuestion else { return }

        let log = MemoLog(
            memo: memoText,
            question: question,
            answer: nil,
            isAnswerSkipped: true
        )
        assert(repository != nil, "skipAnswer called without a repository — wire up repository in MemoInputView init")
        try repository?.save(log)
    }
}
