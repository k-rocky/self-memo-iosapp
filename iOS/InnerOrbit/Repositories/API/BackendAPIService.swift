import Foundation

enum BackendAPIError: Error, LocalizedError {
    case unauthorized
    case badRequest(String)
    case serverError(String)
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "認証エラーが発生しました"
        case .badRequest(let message):
            return message
        case .serverError(let message):
            return "サーバーエラー: \(message)"
        case .invalidResponse:
            return "不正なレスポンスを受信しました"
        }
    }
}

final class BackendAPIService: AIService {
    private let baseURL: URL
    private let secretToken: String
    private let session: URLSession

    init(
        baseURL: URL = URL(string: "http://localhost:3000")!,
        secretToken: String,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.secretToken = secretToken
        self.session = session
    }

    func generateQuestion(from memo: String) async throws -> String {
        let url = baseURL.appending(path: "api/question")
        var request = URLRequest(url: url, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(secretToken)", forHTTPHeaderField: "Authorization")

        let body = ["memo": memo]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            guard let question = decoded["question"] else {
                throw BackendAPIError.invalidResponse
            }
            return question
        case 401:
            throw BackendAPIError.unauthorized
        case 400:
            let decoded = try? JSONDecoder().decode([String: String].self, from: data)
            throw BackendAPIError.badRequest(decoded?["error"] ?? "Bad request")
        default:
            let decoded = try? JSONDecoder().decode([String: String].self, from: data)
            throw BackendAPIError.serverError(decoded?["error"] ?? "Unknown error")
        }
    }

    func generateWeeklySummary(from logs: [MemoLog]) async throws -> String {
        let url = baseURL.appending(path: "api/summary")
        var request = URLRequest(url: url, timeoutInterval: 15.0)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(secretToken)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        request.httpBody = try encoder.encode(["logs": logs])

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw BackendAPIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200:
            let decoded = try JSONDecoder().decode([String: String].self, from: data)
            guard let summary = decoded["summary"] else {
                throw BackendAPIError.invalidResponse
            }
            return summary
        case 401:
            throw BackendAPIError.unauthorized
        case 400:
            let decoded = try? JSONDecoder().decode([String: String].self, from: data)
            throw BackendAPIError.badRequest(decoded?["error"] ?? "Bad request")
        default:
            let decoded = try? JSONDecoder().decode([String: String].self, from: data)
            throw BackendAPIError.serverError(decoded?["error"] ?? "Unknown error")
        }
    }
}
