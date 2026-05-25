import SwiftUI

struct MemoLogListView: View {
    @StateObject private var viewModel: MemoLogListViewModel

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateFormat = "M月d日 HH:mm"
        return f
    }()

    init(repository: MemoLogRepository) {
        _viewModel = StateObject(wrappedValue: MemoLogListViewModel(repository: repository))
    }

    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            case .success where viewModel.logs.isEmpty:
                emptyView
            default:
                logList
            }
        }
        .navigationTitle("ログ一覧")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { viewModel.loadLogs() }
        .alert("エラー", isPresented: Binding(
            get: {
                if case .error = viewModel.state { return true }
                return false
            },
            set: { _ in viewModel.state = .idle }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            if case .error(let err) = viewModel.state {
                Text(err.localizedDescription)
            }
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("まだログがありません")
                .font(.headline)
                .foregroundStyle(.secondary)
            Text("メモを書いて感性を記録してみましょう")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var logList: some View {
        List {
            ForEach(viewModel.logs) { log in
                VStack(alignment: .leading, spacing: 4) {
                    Text(Self.dateFormatter.string(from: log.createdAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(memoPreview(log.memo))
                        .font(.body)
                        .lineLimit(2)
                }
                .padding(.vertical, 4)
            }
            .onDelete { indexSet in
                indexSet.forEach { i in
                    viewModel.deleteLog(id: viewModel.logs[i].id)
                }
            }
        }
    }

    private func memoPreview(_ memo: String) -> String {
        if memo.count > 50 {
            return String(memo.prefix(50)) + "…"
        }
        return memo
    }
}
