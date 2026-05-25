import SwiftUI

struct MemoInputView: View {
    @StateObject private var viewModel: MemoInputViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isTextFieldFocused: Bool

    init(aiService: AIService) {
        _viewModel = StateObject(wrappedValue: MemoInputViewModel(aiService: aiService))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("今、何を感じていますか？")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    TextEditor(text: $viewModel.memoText)
                        .focused($isTextFieldFocused)
                        .frame(minHeight: 120)
                        .padding(8)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .disabled(viewModel.state == .loading)
                }

                if case .error(let error) = viewModel.state {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Spacer()

                Button {
                    Task { await viewModel.submitMemo() }
                } label: {
                    Group {
                        if viewModel.state == .loading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text("問いを生成する")
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.canSubmit ? Color.accentColor : Color.gray.opacity(0.4))
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
                .disabled(!viewModel.canSubmit || viewModel.state == .loading)
            }
            .padding()
            .navigationTitle("一言メモ")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") { dismiss() }
                }
            }
            .onAppear { isTextFieldFocused = true }
            .navigationDestination(isPresented: Binding(
                get: { viewModel.state == .success && viewModel.generatedQuestion != nil },
                set: { _ in }
            )) {
                if let question = viewModel.generatedQuestion {
                    Text(question) // QuestionView は別タスクで実装
                }
            }
        }
    }
}

