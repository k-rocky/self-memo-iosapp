import SwiftUI

struct QuestionView: View {
    @ObservedObject var viewModel: MemoInputViewModel
    @State private var answerText: String = ""
    @State private var saveError: Error?
    @FocusState private var isAnswerFocused: Bool

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                questionSection
                answerSection

                if let error = saveError {
                    Text(error.localizedDescription)
                        .foregroundStyle(.red)
                        .font(.caption)
                }

                Spacer(minLength: 40)
                actionButtons
            }
            .padding()
        }
        .navigationTitle("あなたへの問い")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { isAnswerFocused = true }
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("問い")
                .font(.caption)
                .foregroundStyle(.secondary)
                .textCase(.uppercase)

            Text(viewModel.generatedQuestion ?? "")
                .font(.title3)
                .fontWeight(.medium)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.accentColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("あなたの答え（任意）")
                .font(.caption)
                .foregroundStyle(.secondary)

            TextEditor(text: $answerText)
                .focused($isAnswerFocused)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                save()
            } label: {
                Text("保存して閉じる")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button(role: .cancel) {
                skip()
            } label: {
                Text("スキップ")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func save() {
        do {
            try viewModel.submitAnswer(answerText)
        } catch {
            saveError = error
        }
    }

    private func skip() {
        do {
            try viewModel.skipAnswer()
        } catch {
            saveError = error
        }
    }
}
