import Foundation

struct MemoLog: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    var memo: String
    var question: String
    var answer: String?
    var isAnswerSkipped: Bool
    var energyScore: Int?
    var tags: [String]

    init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        memo: String,
        question: String,
        answer: String? = nil,
        isAnswerSkipped: Bool = false,
        energyScore: Int? = nil,
        tags: [String] = []
    ) {
        self.id = id
        self.createdAt = createdAt
        self.memo = memo
        self.question = question
        self.answer = answer
        self.isAnswerSkipped = isAnswerSkipped
        self.energyScore = energyScore
        self.tags = tags
    }
}
