# 技術仕様書 (Architecture Design Document)

## テクノロジースタック

### iOS アプリ

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Swift | 5.9+ | アプリ開発言語 | iOSネイティブ開発の標準言語、型安全性が高く保守性に優れる |
| SwiftUI | iOS 17+ | UIフレームワーク | 宣言的UIで実装が簡潔、アニメーション表現が豊か、モダンiOS開発の標準 |
| Combine | 標準ライブラリ | 非同期処理・データバインディング | SwiftUIとの親和性が高く、ViewModel層の状態管理が直感的に書ける |
| Core Data | 標準ライブラリ | ローカルデータ永続化 | iOSネイティブのORMで自動バックアップ対応、オフライン保証が容易 |
| URLSession | 標準ライブラリ | API通信 | ネイティブのHTTPクライアント、async/awaitで簡潔に書ける |
| XCTest | 標準ライブラリ | テスト | ネイティブテストフレームワーク、Xcodeとの統合が完全 |

### バックエンドサーバー（Phase 0〜）

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Node.js | v24.11.0 (LTS) | ランタイム | 軽量でLLM API連携実績が豊富、非同期I/Oが得意 |
| TypeScript | 5.x | 開発言語 | 静的型付けで型安全性を確保、iOSのSwift型定義と対応させやすい |
| Express | 4.x | Webフレームワーク | 軽量・シンプル、MVPに適した最小構成で始められる |
| Anthropic SDK | 最新版 | Claude API クライアント | TypeScript対応、プロンプトキャッシュ等の高度機能が利用可能 |
| npm | 11.x | パッケージマネージャー | Node.js標準、lock fileで依存関係を厳密管理 |

### 開発ツール

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Xcode | 16.x | iOS開発IDE | Apple公式IDE、シミュレーターとデバッガーが統合 |
| devcontainer | - | バックエンド開発環境 | 環境の再現性を保証、チーム間での環境差異を排除 |
| ESLint | 9.x | バックエンドLint | コードスタイル統一、バグの早期検出 |
| Prettier | 3.x | バックエンドフォーマッター | コードフォーマットを自動化 |

### Phase 2 追加技術（クラウド対応）

| 技術 | バージョン | 用途 | 選定理由 |
|------|-----------|------|----------|
| Firebase Auth | 最新版 | ユーザー認証 | Sign in with Appleとの統合が容易 |
| Firebase Firestore | 最新版 | クラウドデータベース | リアルタイム同期、iOSネイティブSDKが充実 |
| Firebase Functions | 最新版 | サーバーレスバックエンド | スケールアウトが自動化、コスト効率が高い |

---

## アーキテクチャパターン

### iOS: MVVM + Clean Architecture

```
┌─────────────────────────────────────┐
│         View Layer (SwiftUI)         │ ← 画面表示、ユーザーインタラクション
├─────────────────────────────────────┤
│     ViewModel Layer (ObservableObject) │ ← 状態管理、UIロジック
├─────────────────────────────────────┤
│      Service Layer (Protocol)        │ ← ビジネスロジック
├─────────────────────────────────────┤
│  Repository Layer (Core Data / API)  │ ← データ永続化・取得
└─────────────────────────────────────┘
```

#### View Layer
- **責務**: SwiftUIで画面を宣言的に記述、ViewModelの`@Published`プロパティをバインド
- **許可**: ViewModelのメソッド呼び出し
- **禁止**: Service/Repositoryへの直接アクセス、ビジネスロジックの実装

#### ViewModel Layer
- **責務**: `@Published`プロパティで状態管理、ユーザーアクションをServiceに委譲
- **許可**: Serviceのメソッド呼び出し、UI状態（loading/error/success）の管理
- **禁止**: CoreDataの直接操作、URLSessionの直接使用

#### Service Layer
- **責務**: ビジネスルールの実装（例: ログが5件未満ではサマリ生成不可）
- **許可**: Repositoryの呼び出し、複数Repositoryの協調
- **禁止**: UIへの依存、SwiftUIの型のインポート

#### Repository Layer
- **責務**: データの永続化・取得（CoreData or API）
- **許可**: CoreDataのFetchRequest実行、URLSessionによるHTTP通信
- **禁止**: ビジネスロジックの実装

---

### バックエンド: レイヤードアーキテクチャ

```
┌─────────────────────────┐
│   Route Layer (Express)  │ ← エンドポイント定義、リクエスト受付
├─────────────────────────┤
│   Controller Layer       │ ← リクエスト/レスポンス変換、バリデーション
├─────────────────────────┤
│   Service Layer          │ ← LLM APIプロンプト構築・呼び出し
└─────────────────────────┘
```

```
Route → Controller → Service → LLM API
```

---

## データ永続化戦略

### Phase 0〜1: ローカル中心

| データ種別 | ストレージ | フォーマット | 理由 |
|-----------|----------|-------------|------|
| MemoLog | Core Data (SQLite) | NSManagedObject | iOSネイティブ、自動バックアップ対応 |
| WeeklySummary | Core Data (SQLite) | NSManagedObject | MemoLogと同一ストアで整合性を保証 |
| ユーザー設定 | UserDefaults | Key-Value | 軽量な設定値に最適 |

### Phase 2: クラウド同期

| データ種別 | ストレージ | フォーマット | 理由 |
|-----------|----------|-------------|------|
| MemoLog | Firestore + Core Data | Document | オフライン対応、リアルタイム同期 |
| WeeklySummary | Firestore + Core Data | Document | MemoLogと同期 |
| ユーザーアカウント | Firebase Auth | - | 認証状態管理 |

### Core Data スキーマ

```
MemoLogEntity
├── id: UUID (必須)
├── createdAt: Date (必須)
├── memo: String (必須)
├── question: String (必須)
├── answer: String? (任意)
├── isAnswerSkipped: Bool (必須)
├── energyScore: Int16? (任意, Phase 1)
└── tags: [TagEntity] (0〜N, Phase 1)

TagEntity
├── name: String (必須)
└── memoLog: MemoLogEntity (必須)

WeeklySummaryEntity
├── id: UUID (必須)
├── createdAt: Date (必須)
├── periodStart: Date (必須)
├── periodEnd: Date (必須)
├── content: String (必須)
└── logCount: Int32 (必須)
```

### バックアップ戦略

- **Core Data**: iCloud バックアップに自動含有（Data Protection: `NSFileProtectionComplete`）
- **Phase 0**: 端末バックアップのみ（iCloud/iTunes）
- **Phase 2**: Firestore のリアルタイム同期 + Firebase自動バックアップ（日次）

---

## ディレクトリ構造

```
selfmemoapp/
├── iOS/                        # iOSアプリ本体
│   ├── InnerOrbit.xcodeproj
│   └── InnerOrbit/
│       ├── App/
│       │   └── InnerOrbitApp.swift
│       ├── Views/              # SwiftUI Views
│       │   ├── Home/
│       │   ├── MemoInput/
│       │   ├── Question/
│       │   ├── LogList/
│       │   └── WeeklySummary/
│       ├── ViewModels/         # ObservableObject ViewModels
│       ├── Services/           # ビジネスロジック（Protocol + 実装）
│       ├── Repositories/       # データアクセス（Protocol + 実装）
│       ├── Models/             # Swift値型モデル（struct）
│       ├── CoreData/           # .xcdatamodeld + NSManagedObject subclass
│       └── Resources/          # Assets, Localization
│
├── backend/                    # バックエンドサーバー（Node.js）
│   ├── src/
│   │   ├── routes/             # Expressルート定義
│   │   ├── controllers/        # リクエスト処理
│   │   ├── services/           # LLM API連携
│   │   └── prompts/            # プロンプトテンプレート
│   ├── package.json
│   └── tsconfig.json
│
└── docs/                       # プロジェクトドキュメント
```

---

## パフォーマンス要件

### レスポンスタイム

| 操作 | 目標時間 | 測定環境 |
|------|---------|---------|
| アプリ起動（コールドスタート） | 2秒以内 | iPhone 13以降 |
| メモ送信ボタンタップ → ローディング表示 | 100ms以内 | iPhone 13以降 |
| AI問い表示（LLM APIレスポンス後） | 100ms以内 | LLM API呼び出し除く |
| ログ一覧表示（100件） | 500ms以内 | iPhone 13以降、Core Data |
| ログ保存完了 | 200ms以内 | iPhone 13以降 |

### LLM API レイテンシ目標

| 操作 | 目標時間 | 対策 |
|------|---------|------|
| 問い生成（API側） | 5秒以内 | タイムアウト10秒設定、ローディング演出で体験を補完 |
| サマリ生成（API側） | 15秒以内 | タイムアウト30秒設定、非同期で処理 |

### リソース使用量（iOS）

| リソース | 上限 | 理由 |
|---------|------|------|
| メモリ | 100MB | バックグラウンド遷移時のOOM回避 |
| Core Data ストア | 50MB | 1ログあたり最大2KB × 25,000件相当 |

---

## セキュリティアーキテクチャ

### データ保護（iOS）

- **ローカルデータ暗号化**: Core Data ストアに `NSFileProtectionComplete` を適用（端末ロック中は復号化不可）
- **通信の暗号化**: App Transport Security (ATS) で全通信をHTTPS強制
- **APIキー管理**: LLM APIキーはiOSアプリに含めない。バックエンドの環境変数（`.env`）で管理

### バックエンドのAPIキー管理

```
.env ファイル（Gitignore済み）
├── ANTHROPIC_API_KEY=sk-...
└── NODE_ENV=production
```

### プライバシー設計

- **送信データの明示**: 初回起動時に「メモ内容はAI問い生成のためサーバーに送信されます」とアラート表示し、同意を得る
- **最小データ送信**: AI問い生成時はメモテキストのみ送信（日時・ユーザーID等は送信しない）
- **データ残留なし**: バックエンドはLLM APIへのプロキシのみで、送信データをサーバー側に保存しない

### 入力検証

**iOS側**:
- `memo` が空の場合は送信ボタンを無効化（クライアント側バリデーション）

**バックエンド側**:
- `memo` が空またはリクエストボディなしは `400 Bad Request`
- `logs` が空または5件未満のサマリリクエストは `400 Bad Request`
- リクエストボディサイズ上限: 50KB（過大なリクエストを拒否）

---

## スケーラビリティ設計

### データ増加への対応（Phase 0〜1）

- **想定データ量**: 1ユーザーあたり1日1〜3件 × 365日 = 約365〜1095件/年
- **Core Data フェッチ最適化**: `NSFetchRequest` に `fetchLimit: 100` と `sortDescriptors` を設定し、全件取得を避ける
- **サマリ生成のLLM送信量制限**: 直近30件のログのみを送信（古いログは除外）

### Phase 2 へのスケールアウト

- **Firestore**: 自動スケーリング対応、コレクション設計は `users/{uid}/logs/{logId}` でユーザーごとに分離
- **Firebase Functions**: LLM APIプロキシをサーバーレスに移行、トラフィックに応じて自動スケール
- **コスト制御**: Firebase の使用量アラートを設定し、LLM APIコストを監視

---

## テスト戦略

### ユニットテスト（XCTest）

- **対象**: ViewModel のステート遷移、Service のビジネスロジック（ログ件数チェック等）
- **カバレッジ目標**: ViewModel層70%以上、Service層80%以上（詳細は `docs/development-guidelines.md` 参照）
- **モック**: Protocol を使った依存関係のDI、テスト時はモック実装を注入

```swift
// テスト例
class MemoInputViewModelTests: XCTestCase {
    func testSubmitEmptyMemo_DisablesButton() {
        let vm = MemoInputViewModel(aiService: MockAIService())
        vm.memoText = ""
        XCTAssertFalse(vm.canSubmit)
    }
}
```

### 統合テスト

- **対象**: CoreDataService の保存・取得・削除フロー
- **方法**: In-memory Core Data ストアを使用し、実際のCoreData実装を検証

### E2Eテスト（XCUITest）

- **ツール**: Xcode XCUITest
- **主要シナリオ**:
  - 初回起動 → メモ入力 → 回答保存 → ログ一覧確認
  - ログ5件蓄積 → 週次サマリ生成 → 表示確認
  - オフライン状態 → メモ入力 → エラー表示確認

### バックエンドテスト（Jest）

- **対象**: Controller のバリデーション、Service のプロンプト生成ロジック
- **方法**: LLM APIはモックで代替してテスト速度を確保

---

## 技術的制約

### 環境要件

| 項目 | 要件 |
|------|------|
| iOS バージョン | iOS 17.0以上 |
| 対象デバイス | iPhone（iPad対応は Phase 2以降） |
| ネットワーク | AI問い生成・サマリ生成時にインターネット接続必須（閲覧はオフライン可） |
| バックエンド OS | Linux（Ubuntu 22.04 LTS推奨） |
| バックエンド Node.js | v24.11.0以上 |

### パフォーマンス制約

- LLM APIの呼び出し上限: 1ユーザーあたり1日50回（MVPでの上限目安）
- バックエンドのリクエストボディ上限: 50KB（過大なリクエストはエラー）
- サマリ生成の同時実行: 1ユーザーにつき1リクエストに制限（二重送信防止）

### セキュリティ制約

- APIキーはiOSアプリバイナリに含めない（App Store審査・リバースエンジニアリング対策）
- バックエンドはHTTPS必須（HTTP接続はリダイレクトまたは拒否）
- Core Data ストアは `NSFileProtectionComplete` で保護

---

## 依存関係管理

### iOS（Swift Package Manager）

| ライブラリ | 用途 | バージョン方針 |
|-----------|------|--------------|
| （外部依存なし） | 標準ライブラリのみで実装 | - |

> Phase 0〜1ではSwift標準ライブラリと Apple フレームワークのみを使用し、外部依存を最小化する。

### バックエンド（npm）

| ライブラリ | 用途 | バージョン方針 |
|-----------|------|--------------|
| express | Webフレームワーク | `^4.18.0`（マイナーまで許可） |
| @anthropic-ai/sdk | Claude API クライアント | `^0.x.x`（最新安定版） |
| typescript | 開発言語 | `~5.3.0`（パッチのみ自動） |
| dotenv | 環境変数管理 | `^16.0.0` |
| zod | スキーマバリデーション | `^3.0.0` |
| jest | テストフレームワーク | `^29.0.0` |
| eslint | Linter | `^9.0.0` |
