import Foundation

protocol AIService {
    func generateQuestion(from memo: String) async throws -> String
    func generateWeeklySummary(from logs: [MemoLog]) async throws -> String
}
