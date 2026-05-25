import Foundation

enum RepositoryError: Error, LocalizedError {
    case encodingFailed(Error)
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let e):
            return "保存に失敗しました: \(e.localizedDescription)"
        case .decodingFailed(let e):
            return "データの読み込みに失敗しました: \(e.localizedDescription)"
        }
    }
}

final class LocalMemoLogRepository: MemoLogRepository {
    private static let key = "innerOrbit.memoLogs"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    init(defaults: UserDefaults = .standard) {
        encoder.dateEncodingStrategy = .iso8601
        self.defaults = defaults
    }

    func save(_ log: MemoLog) throws {
        var all = try loadAll()
        if let idx = all.firstIndex(where: { $0.id == log.id }) {
            all[idx] = log
        } else {
            all.append(log)
        }
        try persist(all)
    }

    func fetchAll() throws -> [MemoLog] {
        let all = try loadAll()
        return all.sorted { $0.createdAt > $1.createdAt }
    }

    func fetchRecentLogs(limit: Int) throws -> [MemoLog] {
        let sorted = try fetchAll()
        return Array(sorted.prefix(limit))
    }

    func fetchByTag(_ tag: String) throws -> [MemoLog] {
        let all = try fetchAll()
        return all.filter { $0.tags.contains(tag) }
    }

    func delete(id: UUID) throws {
        var all = try loadAll()
        all.removeAll { $0.id == id }
        try persist(all)
    }

    private func loadAll() throws -> [MemoLog] {
        guard let data = defaults.data(forKey: Self.key) else {
            return []
        }
        do {
            return try decoder.decode([MemoLog].self, from: data)
        } catch {
            throw RepositoryError.decodingFailed(error)
        }
    }

    private func persist(_ logs: [MemoLog]) throws {
        do {
            let data = try encoder.encode(logs)
            defaults.set(data, forKey: Self.key)
        } catch {
            throw RepositoryError.encodingFailed(error)
        }
    }
}
