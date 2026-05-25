import Foundation

protocol MemoLogRepository {
    func save(_ log: MemoLog) throws
    func fetchAll() throws -> [MemoLog]
    func fetchRecentLogs(limit: Int) throws -> [MemoLog]
    func fetchByTag(_ tag: String) throws -> [MemoLog]
    func delete(id: UUID) throws
}
