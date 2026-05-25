# 開発ガイドライン (Development Guidelines)

## コーディング規約

### Swift (iOS)

#### 命名規則

```swift
// ✅ 変数・プロパティ: camelCase、名詞
let memoText = ""
var generatedQuestion: String?
var isLoading = false        // Bool は is/has/should で始める
var canSubmit: Bool { !memoText.isEmpty }

// ❌ 悪い例
var txt = ""
var q: String?
var loading = false
```

```swift
// ✅ 関数・メソッド: camelCase、動詞で始める
func submitMemo() async
func loadLogs() throws -> [MemoLog]
func deleteLog(id: UUID) throws

// ❌ 悪い例
func memo()
func logs()
```

```swift
// ✅ 型（class/struct/enum/protocol）: PascalCase
struct MemoLog
class MemoInputViewModel: ObservableObject
protocol AIServiceProtocol
enum ViewState { case idle, loading, success, error(Error) }
```

#### コードフォーマット

- インデント: 4スペース（Xcodeデフォルト）
- 行の長さ: 最大120文字
- `guard` を使って早期リターンを優先する

```swift
// ✅ 良い例: guard で早期リターン
func submitMemo() async {
    guard !memoText.isEmpty else { return }
    guard state == .idle else { return }
    // 本処理
}

// ❌ 悪い例: ネストが深い
func submitMemo() async {
    if !memoText.isEmpty {
        if state == .idle {
            // 本処理
        }
    }
}
```

#### async/await

```swift
// ✅ 良い例: async/await + Task
func submitMemo() {
    Task {
        do {
            state = .loading
            let question = try await aiService.generateQuestion(from: memoText)
            generatedQuestion = question
            state = .success
        } catch {
            state = .error(error)
        }
    }
}
```

#### エラーハンドリング（Swift）

```swift
// ✅ 良い例: カスタムエラー型を定義
enum AppError: LocalizedError {
    case networkUnavailable
    case aiGenerationFailed(String)
    case dataStoreFailed(Error)

    var errorDescription: String? {
        switch self {
        case .networkUnavailable:
            return "インターネット接続が必要です"
        case .aiGenerationFailed(let reason):
            return "問いの生成に失敗しました: \(reason)"
        case .dataStoreFailed:
            return "保存に失敗しました。ストレージを確認してください"
        }
    }
}
```

---

### TypeScript (バックエンド)

#### 命名規則

```typescript
// 変数・関数: camelCase
const memoText = "今日ふと思ったこと";
function generateQuestion(memo: string): Promise<string> {}

// クラス: PascalCase
class QuestionGenerationService {}

// 定数: UPPER_SNAKE_CASE
const MAX_REQUEST_BODY_SIZE = 50_000;
const SUMMARY_MIN_LOG_COUNT = 5;

// Boolean: is/has/should で始める
const isEmpty = memo.length === 0;
const hasEnoughLogs = logs.length >= SUMMARY_MIN_LOG_COUNT;
```

#### 型定義

```typescript
// ✅ 良い例: 明示的な型注釈
interface GenerateQuestionRequest {
    memo: string;
}

interface GenerateQuestionResponse {
    question: string;
}

// ✅ ユニオン型はtype aliasで
type ViewState = "idle" | "loading" | "success" | "error";

// ❌ 悪い例: any を使わない
function processRequest(data: any): any {}
```

#### エラーハンドリング（TypeScript）

```typescript
// ✅ 良い例: カスタムエラークラス
class ValidationError extends Error {
    constructor(
        message: string,
        public field: string,
        public value: unknown
    ) {
        super(message);
        this.name = "ValidationError";
    }
}

// ✅ 予期されるエラーを適切に処理し、予期しないエラーは伝播する
async function generateQuestion(memo: string): Promise<string> {
    if (!memo || memo.trim().length === 0) {
        throw new ValidationError("memoは必須です", "memo", memo);
    }
    try {
        return await callLLMApi(memo);
    } catch (error) {
        if (error instanceof ValidationError) throw error;
        throw new Error(`LLM API呼び出しに失敗しました: ${String(error)}`);
    }
}

// ❌ 悪い例: エラーを握りつぶす
async function generateQuestion(memo: string): Promise<string | null> {
    try {
        return await callLLMApi(memo);
    } catch {
        return null; // 原因が分からなくなる
    }
}
```

#### コードフォーマット

- インデント: 4スペース
- 行の長さ: 最大120文字
- セミコロン: あり

---

## コメント規約

### Swift: コメントは「なぜ」だけ書く

```swift
// ✅ 良い例: 非自明な理由を説明
// LLM APIの結果をメインスレッドで受け取るため、Task で包む
Task { @MainActor in
    state = .loading
    ...
}

// ❌ 悪い例: コードを読めば分かることを書く
// ローディング状態にする
state = .loading
```

### TypeScript: TSDocは公開APIのみ

```typescript
/**
 * メモからAIの問いを生成する
 * @param memo ユーザーが入力した一言メモ（1文字以上）
 * @returns 生成された問いのテキスト
 * @throws {ValidationError} memoが空の場合
 */
async function generateQuestion(memo: string): Promise<string> { ... }
```

---

## Git運用ルール

### ブランチ戦略（Git Flow）

```
main（本番・安定版）
└── develop（開発統合）
    ├── feature/[機能名]     新機能開発
    ├── fix/[修正内容]       バグ修正
    └── refactor/[対象]      リファクタリング
```

**ルール**:
- `main` / `develop` への直接コミット禁止
- feature/fix ブランチは `develop` から分岐し、PRで `develop` にマージ
- `develop` → `main` は動作確認後にマージ
- マージ方針: feature→develop は squash merge、develop→main は merge commit

### コミットメッセージ規約（Conventional Commits）

```
<type>(<scope>): <subject>

<body>（任意）

<footer>（任意）
```

**Type**:
| type | 用途 |
|------|------|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `docs` | ドキュメント |
| `style` | フォーマット変更（動作に影響なし） |
| `refactor` | リファクタリング |
| `test` | テスト追加・修正 |
| `chore` | ビルド、依存関係更新等 |

**scope（本プロジェクト固有）**:
- `ios`: iOSアプリ全般
- `view`: SwiftUI View
- `viewmodel`: ViewModel
- `service`: Service層
- `backend`: バックエンド全般
- `api`: APIエンドポイント
- `prompt`: AIプロンプト
- `docs`: ドキュメント

**例**:
```
feat(viewmodel): メモ入力のバリデーションを追加

空文字の場合に送信ボタンを無効化するロジックをMemoInputViewModelに実装。
canSubmit プロパティで状態を管理。

Closes #12
```

```
fix(api): サマリ生成のタイムアウトエラーを修正

LLM APIの応答が遅い場合にクラッシュしていた問題を修正。
axios のタイムアウト設定を10秒→30秒に変更。

Fixes #34
```

---

## プルリクエストプロセス

### 作成前のチェック

- [ ] 全テストがパス
- [ ] Lintエラーがない（バックエンド）
- [ ] 型チェックがパス（バックエンド `tsc --noEmit`）
- [ ] ビルドが通る（iOS: Xcode Build）
- [ ] 手動動作確認済み

### PRテンプレート

```markdown
## 変更の種類
- [ ] 新機能 (feat)
- [ ] バグ修正 (fix)
- [ ] リファクタリング (refactor)
- [ ] ドキュメント (docs)
- [ ] その他 (chore)

## 変更内容
### 何を変更したか
[簡潔な説明]

### なぜ変更したか
[背景・理由]

### どのように変更したか
- [変更点1]
- [変更点2]

## テスト
- [ ] ユニットテスト追加
- [ ] 手動テスト実施
- [ ] スクリーンショット（UI変更の場合）

## 関連Issue
Closes #[番号]
```

### PRの規模の目安

- 変更行数: 300行以内を推奨
- 変更ファイル数: 10ファイル以内を推奨
- 1PR = 1機能（大きい場合は分割する）

---

## テスト戦略

### テストピラミッド

```
       /\
      /E2E\        少 (UIテスト、主要フローのみ)
     /------\
    / 統合   \      中 (Core Data、APIエンドポイント)
   /----------\
  / ユニット   \    多 (ViewModel、Service、バリデーター)
 /--------------\
```

**目標比率**: ユニット70% / 統合20% / E2E10%

### iOSテスト（XCTest）

**テスト構造（Given-When-Then）**:
```swift
func test_submitMemo_whenMemoIsEmpty_canSubmitIsFalse() {
    // Given
    let viewModel = MemoInputViewModel(aiService: MockAIService())

    // When
    viewModel.memoText = ""

    // Then
    XCTAssertFalse(viewModel.canSubmit)
}

func test_generateSummary_whenLogsLessThan5_throwsInsufficientLogsError() async throws {
    // Given
    let service = WeeklySummaryService(
        repository: MockMemoLogRepository(logs: [makeMemoLog(), makeMemoLog()])
    )

    // When/Then
    await XCTAssertThrowsError(
        try await service.generateSummary()
    )
}
```

**テスト命名規則**:
```
test_[対象メソッド]_[条件]_[期待結果]
```

**カバレッジ目標**:
- ViewModel層: 70%以上
- Service層: 80%以上

### バックエンドテスト（Jest）

**ユニットテスト**:
```typescript
describe("QuestionGenerationService", () => {
    describe("generate", () => {
        it("正常なメモから問いを生成できる", async () => {
            // Given
            const service = new QuestionGenerationService(mockAnthropicClient);
            const memo = "宇宙のことを考えるとワクワクする";

            // When
            const question = await service.generate(memo);

            // Then
            expect(question).toBeTruthy();
            expect(typeof question).toBe("string");
        });

        it("メモが空の場合ValidationErrorをスローする", async () => {
            const service = new QuestionGenerationService(mockAnthropicClient);

            await expect(service.generate("")).rejects.toThrow(ValidationError);
        });
    });
});
```

**カバレッジ目標**:
```json
// jest.config.js
{
  "coverageThreshold": {
    "global": { "lines": 70 },
    "./src/services/": { "lines": 85 }
  }
}
```

### モック方針

**iOS**: Protocol準拠のモック実装を `Tests/Mocks/` に配置

```swift
// Tests/Mocks/MockAIService.swift
class MockAIService: AIServiceProtocol {
    var stubbedQuestion = "テスト用の問い"
    var shouldThrow = false

    func generateQuestion(from memo: String) async throws -> String {
        if shouldThrow { throw AppError.aiGenerationFailed("テスト") }
        return stubbedQuestion
    }
}
```

**バックエンド**: LLM APIクライアントはモック化、実際のビジネスロジックは実装を使用

```typescript
const mockAnthropicClient = {
    messages: {
        create: jest.fn().mockResolvedValue({
            content: [{ type: "text", text: "テスト用の問い" }]
        })
    }
};
```

---

## コードレビュー基準

### レビューポイント

**機能性**:
- [ ] PRDの要件を満たしているか
- [ ] エッジケース（空入力、ネットワークエラー等）が考慮されているか
- [ ] エラーハンドリングが適切か

**アーキテクチャ**:
- [ ] レイヤー間の依存方向が正しいか（View→ViewModel→Service→Repository）
- [ ] Protocolを通じた依存注入になっているか（テスト可能性）
- [ ] APIキーや機密情報がコードに含まれていないか

**可読性**:
- [ ] 命名が本ガイドの規約に従っているか
- [ ] コメントが「なぜ」の説明になっているか

**パフォーマンス**:
- [ ] Core DataのFetchRequestに適切な制限が設定されているか
- [ ] 不要なAPI呼び出しがないか

### レビューコメントの書き方

**優先度を明示**:
```
[必須] APIキーがハードコードされています。環境変数に移動してください。
[推奨] この fetch は fetchLimit を設定してください。ログが増えた時に全件取得になります。
[提案] このロジックを Service 層に移動すると ViewModel がシンプルになります。
[質問] この条件が false になるケースはありますか？
```

**具体的な改善案を提示**:
```
[推奨] ここの guard 文を使うと早期リターンできてネストが減ります:

guard !memo.isEmpty else { return }
// 本処理
```

---

## 開発環境セットアップ

### iOS開発

**必要なツール**:
| ツール | バージョン | インストール方法 |
|--------|-----------|-----------------|
| Xcode | 16.x | App Store |
| iOS Simulator | iOS 17.x | Xcode同梱 |
| SwiftLint（任意） | 最新版 | `brew install swiftlint` |

**セットアップ手順**:
```bash
# 1. リポジトリのクローン
git clone <URL>
cd selfmemoapp/iOS

# 2. Xcodeでプロジェクトを開く
open InnerOrbit.xcodeproj

# 3. シミュレーターでビルド・実行
# Xcode の ▶ ボタンまたは Cmd+R
```

### バックエンド開発

**必要なツール**:
| ツール | バージョン | インストール方法 |
|--------|-----------|-----------------|
| Node.js | v24.11.0 | devcontainer自動設定済み |
| TypeScript | 5.x | npm install |

**セットアップ手順**:
```bash
# 1. devcontainerを開く（VS Code + Dev Containers拡張）
# または直接ターミナルで

cd selfmemoapp/backend

# 2. 依存関係のインストール
npm install

# 3. 環境変数の設定
cp .env.example .env
# .envファイルのANTHROPIC_API_KEYを設定

# 4. TypeScript型チェック
npm run typecheck

# 5. テスト実行
npm test

# 6. 開発サーバー起動
npm run dev
```

### バックエンドの npm スクリプト

```json
{
  "scripts": {
    "dev": "ts-node src/app.ts",
    "build": "tsc",
    "typecheck": "tsc --noEmit",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "format": "prettier --write .",
    "test": "jest",
    "test:watch": "jest --watch",
    "test:coverage": "jest --coverage"
  }
}
```

---

## 自動化（バックエンド）

### Pre-commitフック（Husky + lint-staged）

```bash
# .husky/pre-commit
npm run lint-staged
npm run typecheck
```

```json
// package.json
{
  "lint-staged": {
    "*.{ts}": ["eslint --fix", "prettier --write"]
  }
}
```

### GitHub Actions（CI）

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
      - run: cd backend && npm ci
      - run: cd backend && npm run lint
      - run: cd backend && npm run typecheck
      - run: cd backend && npm test
```

---

## セキュリティチェックリスト

実装・レビュー時に確認する:

- [ ] APIキー・シークレットがコードに含まれていない（`.env` に記載）
- [ ] `.env` が `.gitignore` に含まれている
- [ ] バックエンドのリクエストボディがバリデーション済み（`zod` 等で検証）
- [ ] iOSのCore Dataストアに `NSFileProtectionComplete` が設定されている
- [ ] バックエンドとの通信がHTTPS（開発環境のみlocalhost許可）
- [ ] AI送信データにユーザーIDや個人情報が含まれていない（メモテキストのみ）
