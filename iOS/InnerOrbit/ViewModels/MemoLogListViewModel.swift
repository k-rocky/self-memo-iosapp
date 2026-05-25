import Foundation

@MainActor
final class MemoLogListViewModel: ObservableObject {
    @Published var logs: [MemoLog] = []
    @Published var state: ViewState = .idle

    private let repository: MemoLogRepository

    init(repository: MemoLogRepository) {
        self.repository = repository
    }

    func loadLogs() {
        do {
            logs = try repository.fetchAll()
            state = .success
        } catch {
            state = .error(error)
        }
    }

    func deleteLog(id: UUID) {
        do {
            try repository.delete(id: id)
            logs.removeAll { $0.id == id }
        } catch {
            state = .error(error)
        }
    }
}
