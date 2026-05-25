import SwiftUI

@main
struct InnerOrbitApp: App {
    // Phase 0: 依存を直接生成。Phase 1 以降は AppContainer 等に切り出す
    private let repository: MemoLogRepository = LocalMemoLogRepository()
    // TODO(Phase 1): Info.plist の "BackendSecretToken" キーから読み込む形式に移行する
    // 現在値は backend/.env の APP_SECRET_TOKEN=dev-secret-token と対応している
    private let aiService: AIService = BackendAPIService(secretToken: "dev-secret-token")

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MemoLogListView(repository: repository, aiService: aiService)
            }
        }
    }
}
