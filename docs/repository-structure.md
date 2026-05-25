# リポジトリ構造定義書 (Repository Structure Document)

## プロジェクト全体構造

```
selfmemoapp/                        # リポジトリルート
├── iOS/                            # iOSアプリ本体
│   └── InnerOrbit/                 # Xcodeプロジェクト
├── backend/                        # バックエンドサーバー (Node.js)
├── docs/                           # プロジェクトドキュメント
├── .steering/                      # 作業単位のステアリングファイル
├── .claude/                        # Claude Code設定
├── .devcontainer/                  # バックエンド開発環境設定
├── CLAUDE.md                       # Claude Codeプロジェクト設定
└── README.md                       # プロジェクト概要
```

---

## iOS ディレクトリ詳細

```
iOS/
├── InnerOrbit.xcodeproj/           # Xcodeプロジェクトファイル
└── InnerOrbit/
    ├── App/                        # アプリエントリーポイント
    │   ├── InnerOrbitApp.swift     # @main アプリ定義
    │   └── AppContainer.swift      # 依存性注入のルート設定
    │
    ├── Views/                      # SwiftUI View (画面単位)
    │   ├── Home/
    │   │   └── HomeView.swift
    │   ├── MemoInput/
    │   │   └── MemoInputView.swift
    │   ├── Question/
    │   │   └── QuestionView.swift
    │   ├── LogList/
    │   │   ├── LogListView.swift
    │   │   └── LogRowView.swift    # ログ一覧の行コンポーネント
    │   ├── LogDetail/
    │   │   └── LogDetailView.swift
    │   ├── WeeklySummary/
    │   │   └── WeeklySummaryView.swift
    │   └── Shared/                 # 複数画面で使う共通コンポーネント
    │       ├── LoadingView.swift
    │       └── ErrorView.swift
    │
    ├── ViewModels/                 # ObservableObject (画面単位)
    │   ├── HomeViewModel.swift
    │   ├── MemoInputViewModel.swift
    │   ├── QuestionViewModel.swift
    │   ├── LogListViewModel.swift
    │   ├── LogDetailViewModel.swift
    │   └── WeeklySummaryViewModel.swift
    │
    ├── Services/                   # ビジネスロジック
    │   ├── Protocols/              # Protocol定義（テスト用モックの注入を可能にする）
    │   │   ├── MemoLogRepositoryProtocol.swift
    │   │   └── AIServiceProtocol.swift
    │   ├── MemoLogService.swift    # ログの作成・取得・削除ロジック
    │   └── WeeklySummaryService.swift  # サマリ生成ロジック（件数チェック等）
    │
    ├── Repositories/               # データアクセス層
    │   ├── CoreData/
    │   │   ├── CoreDataMemoLogRepository.swift   # MemoLogRepositoryProtocol の実装
    │   │   └── CoreDataWeeklySummaryRepository.swift
    │   └── API/
    │       └── BackendAPIService.swift   # AIServiceProtocol の実装（バックエンド経由）
    │
    ├── Models/                     # Swift値型モデル（struct）
    │   ├── MemoLog.swift
    │   ├── WeeklySummary.swift
    │   └── ViewState.swift         # enum: .idle | .loading | .success | .error
    │
    ├── CoreData/                   # Core Data スキーマと生成クラス
    │   ├── InnerOrbit.xcdatamodeld
    │   ├── MemoLogEntity+CoreDataClass.swift
    │   ├── MemoLogEntity+CoreDataProperties.swift
    │   ├── WeeklySummaryEntity+CoreDataClass.swift
    │   └── WeeklySummaryEntity+CoreDataProperties.swift
    │
    ├── Resources/                  # 静的リソース
    │   ├── Assets.xcassets         # 画像・色定義
    │   └── Localizable.strings     # 文字列定数（将来の多言語対応用）
    │
    └── Tests/                      # iOSテストコード
        ├── UnitTests/
        │   ├── ViewModels/
        │   │   ├── MemoInputViewModelTests.swift
        │   │   └── LogListViewModelTests.swift
        │   └── Services/
        │       ├── MemoLogServiceTests.swift
        │       └── WeeklySummaryServiceTests.swift
        ├── IntegrationTests/
        │   └── CoreDataRepositoryTests.swift
        └── UITests/
            ├── MemoInputFlowTests.swift
            └── WeeklySummaryFlowTests.swift
```

---

## バックエンド ディレクトリ詳細

```
backend/
├── src/
│   ├── routes/                     # Express ルート定義
│   │   ├── question.ts             # POST /api/question
│   │   ├── summary.ts              # POST /api/summary
│   │   └── health.ts               # GET /health
│   │
│   ├── controllers/                # リクエスト/レスポンス処理
│   │   ├── QuestionController.ts
│   │   └── SummaryController.ts
│   │
│   ├── middleware/                 # Expressミドルウェア
│   │   └── auth.ts                 # Bearer トークン認証
│   │
│   ├── services/                   # LLM API連携ロジック
│   │   ├── QuestionGenerationService.ts
│   │   └── SummaryGenerationService.ts
│   │
│   ├── prompts/                    # プロンプトテンプレート
│   │   ├── questionPrompt.ts       # 問い生成のシステムプロンプト
│   │   └── summaryPrompt.ts        # サマリ生成のシステムプロンプト
│   │
│   ├── validators/                 # リクエストバリデーション
│   │   ├── questionValidator.ts    # memo フィールドの検証
│   │   └── summaryValidator.ts     # logs フィールドの検証
│   │
│   ├── types/                      # TypeScript型定義
│   │   ├── api.ts                  # リクエスト/レスポンス型
│   │   └── models.ts               # ドメインモデル型（MemoLog等）
│   │
│   └── app.ts                      # Expressアプリ設定・起動
│
├── tests/
│   ├── unit/
│   │   ├── services/
│   │   │   ├── QuestionGenerationService.test.ts
│   │   │   └── SummaryGenerationService.test.ts
│   │   └── validators/
│   │       ├── questionValidator.test.ts
│   │       └── summaryValidator.test.ts
│   └── integration/
│       ├── question-endpoint.test.ts
│       └── summary-endpoint.test.ts
│
├── package.json
├── tsconfig.json
├── .env                            # 環境変数（Gitignore済み）
├── .env.example                    # 環境変数テンプレート（Gitに含める）
└── .eslintrc.json
```

---

## docs/ ディレクトリ詳細

```
docs/
├── ideas/                          # 壁打ち・ブレインストーミング成果物
│   └── initial-requirements.md    # アプリ企画メモ（プロジェクト起点）
├── product-requirements.md         # プロダクト要求定義書 (PRD)
├── functional-design.md            # 機能設計書
├── architecture.md                 # アーキテクチャ設計書（本ドキュメント）
├── repository-structure.md         # リポジトリ構造定義書（本ドキュメント）
├── development-guidelines.md       # 開発ガイドライン
└── glossary.md                     # ユビキタス言語定義
```

---

## ファイル配置規則

### iOSソースファイル

| ファイル種別 | 配置先 | 命名規則 | 例 |
|------------|--------|---------|-----|
| SwiftUI View | `Views/[画面名]/` | PascalCase + `View.swift` | `MemoInputView.swift` |
| 共通コンポーネント | `Views/Shared/` | PascalCase + `View.swift` | `LoadingView.swift` |
| ViewModel | `ViewModels/` | PascalCase + `ViewModel.swift` | `MemoInputViewModel.swift` |
| Service Protocol | `Services/Protocols/` | PascalCase + `Protocol.swift` | `AIServiceProtocol.swift` |
| Service 実装 | `Services/` | PascalCase + `Service.swift` | `MemoLogService.swift` |
| Repository Protocol | `Services/Protocols/` | PascalCase + `RepositoryProtocol.swift` | `MemoLogRepositoryProtocol.swift` |
| Repository 実装 | `Repositories/CoreData/` or `Repositories/API/` | PascalCase + `Repository.swift` | `CoreDataMemoLogRepository.swift` |
| 値型モデル | `Models/` | PascalCase + `.swift` | `MemoLog.swift` |
| Core Data クラス | `CoreData/` | Xcodeが自動生成 | `MemoLogEntity+CoreDataClass.swift` |

### バックエンドソースファイル

| ファイル種別 | 配置先 | 命名規則 | 例 |
|------------|--------|---------|-----|
| Expressルート | `src/routes/` | camelCase + `.ts` | `question.ts` |
| コントローラー | `src/controllers/` | PascalCase + `Controller.ts` | `QuestionController.ts` |
| ミドルウェア | `src/middleware/` | camelCase + `.ts` | `auth.ts` |
| サービス | `src/services/` | PascalCase + `Service.ts` | `QuestionGenerationService.ts` |
| プロンプト | `src/prompts/` | camelCase + `Prompt.ts` | `questionPrompt.ts` |
| バリデーター | `src/validators/` | camelCase + `Validator.ts` | `questionValidator.ts` |
| 型定義 | `src/types/` | camelCase + `.ts` | `api.ts` |

### テストファイル

| テスト種別 | 配置先 | 命名規則 | 例 |
|-----------|--------|---------|-----|
| iOSユニットテスト | `iOS/InnerOrbit/Tests/UnitTests/[レイヤー]/` | PascalCase + `Tests.swift` | `MemoInputViewModelTests.swift` |
| iOS統合テスト | `iOS/InnerOrbit/Tests/IntegrationTests/` | PascalCase + `Tests.swift` | `CoreDataRepositoryTests.swift` |
| iOS UIテスト | `iOS/InnerOrbit/Tests/UITests/` | PascalCase + `FlowTests.swift` | `MemoInputFlowTests.swift` |
| バックエンドユニットテスト | `backend/tests/unit/[レイヤー]/` | `[クラス名].test.ts`（PascalCase） | `QuestionGenerationService.test.ts` |
| バックエンド統合テスト | `backend/tests/integration/` | `[リソース]-endpoint.test.ts`（kebab-case） | `question-endpoint.test.ts` |

---

## 命名規則

### ディレクトリ名

| 種別 | 規則 | 例 |
|-----|-----|-----|
| iOSレイヤーディレクトリ | PascalCase（Xcode慣習） | `Views/`, `ViewModels/`, `Services/` |
| iOS画面ディレクトリ | PascalCase | `MemoInput/`, `LogList/` |
| バックエンドディレクトリ | 複数形 + camelCase | `routes/`, `controllers/`, `services/` |

### ファイル名

| 種別 | 規則 | 例 |
|-----|-----|-----|
| Swift クラス/struct/enum | PascalCase | `MemoLog.swift`, `ViewState.swift` |
| TypeScript クラス | PascalCase | `QuestionController.ts` |
| TypeScript 関数/設定 | camelCase | `questionPrompt.ts`, `api.ts` |
| テスト（Swift） | PascalCase + `Tests` | `MemoInputViewModelTests.swift` |
| テスト（TypeScript） | PascalCase + `.test.ts` | `QuestionController.test.ts` |

---

## 依存関係のルール

### iOS: レイヤー間依存

```
View → ViewModel → Service → Repository
```

**禁止される依存**:
- `Views/` → `Services/` 直接アクセス（❌ ViewModelを経由すること）
- `Views/` → `Repositories/` 直接アクセス（❌）
- `Services/` → `Views/` or `ViewModels/` への依存（❌ SwiftUIをインポートしない）
- `Repositories/` → `Services/` or `Views/` への依存（❌）

**テスト時の依存注入**:
- ServiceとRepositoryはProtocolを通じて参照する
- テスト時はProtocol準拠のモックを注入する

```swift
// ✅ 良い例: Protocol経由で依存
class MemoInputViewModel: ObservableObject {
    private let aiService: AIServiceProtocol  // Protocolに依存
    init(aiService: AIServiceProtocol) {
        self.aiService = aiService
    }
}

// ❌ 悪い例: 具体クラスに直接依存
class MemoInputViewModel: ObservableObject {
    private let aiService = BackendAPIService()  // テスト時に差し替え不可
}
```

### バックエンド: レイヤー間依存

```
routes/ → controllers/ → services/ → (LLM API)
```

**禁止される依存**:
- `services/` → `controllers/` or `routes/` への依存（❌）
- `validators/` → `services/` or `controllers/` への依存（❌）
- `prompts/` → その他のレイヤーへの依存（❌ 純粋な文字列テンプレートのみ）

---

## 除外設定

### .gitignore

```
# iOS
*.xcuserstate
xcuserdata/
DerivedData/
*.ipa

# バックエンド
node_modules/
dist/
.env                    # 環境変数（APIキーを含む）

# 作業ファイル
.DS_Store
*.log
coverage/
```

### .env.example（Gitに含める）

```
# LLM API
ANTHROPIC_API_KEY=your_api_key_here

# サーバー設定
PORT=3000
NODE_ENV=development

# （Phase 2）Firebase
FIREBASE_PROJECT_ID=your_project_id
```

---

## スケーリング戦略

### 機能追加時の配置方針

| 機能の規模 | 方針 | 例 |
|-----------|-----|-----|
| 小規模（コンポーネント追加） | 既存ディレクトリに配置 | `Views/Shared/` に新コンポーネント追加 |
| 中規模（新画面追加） | 既存レイヤーにサブディレクトリ追加 | `Views/Settings/SettingsView.swift` |
| 大規模（新ドメイン追加） | Phase 2以降でモジュール化を検討 | 認証機能を `Modules/Auth/` として分離 |

### Phase 2 への拡張（クラウド対応）

Phase 2でクラウド同期を追加する際は、以下のように拡張する:

```
Repositories/
├── CoreData/           # 既存：ローカル実装
├── API/                # 既存：バックエンドAI連携
└── Firestore/          # Phase 2追加：クラウド同期実装
    ├── FirestoreMemoLogRepository.swift
    └── FirestoreWeeklySummaryRepository.swift
```

Protocolを通じた依存注入のため、ViewModelやServiceはコード変更不要でリポジトリを差し替えられる。
