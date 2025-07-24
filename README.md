# Claude Code + GitHub Actions Integration

kamui_qai式の16並列AIエージェントシステムとGitHub Actions統合開発環境。

## 🚀 クイックスタート

### 1. 初期セットアップ

```bash
# リポジトリをクローン
git clone https://github.com/your-username/your-repo.git
cd your-repo

# 依存関係をインストール
./scripts/install-dependencies.sh

# 環境変数を設定
cp .env.example .env
# .envファイルを編集してトークンを設定
```

### 2. Claude Code のセットアップ

```bash
# Claude Code をインストール
npm install -g @anthropic-ai/claude-code

# Claude Code を起動
claude

# GitHub App の自動セットアップ（推奨）
/init-github-app

# これにより以下が自動作成される：
# - .github/workflows/claude.yml（@claudeメンション対応）
# - .github/workflows/claude-review.yml（PR自動レビュー）
# - OAuth トークンの設定

# もし手動でトークンを設定する場合：
claude setup-token
# 生成されたトークンをGitHub Secretsに追加
# Settings > Secrets > Actions > New repository secret
# Name: CLAUDE_CODE_OAUTH_TOKEN
```

### 3. 16エージェント環境の起動

```bash
# tmuxセッションを開始
./scripts/tmux-16-agents.sh

# エージェントコマンドを読み込み
source ./scripts/agent-commands.sh

# 全エージェントにタスクを割り当て
ta "プロジェクトの初期構造を作成してください"
```

## 📂 ワークフローの構成

### デフォルトワークフロー（`/init-github-app` で自動生成）
- **claude.yml** - @claude メンション応答
- **claude-review.yml** - PR自動レビュー

### カスタムワークフロー（追加機能）
- **claude-multi-agent.yml** - 16並列エージェント実行
- **claude-enhanced.yml** - 統合版（単一/マルチ両対応）

詳細は [docs/DEFAULT_WORKFLOWS.md](docs/DEFAULT_WORKFLOWS.md) を参照。

## 📝 使い方

### デフォルト機能（単一エージェント）

```markdown
# Issue/PRでのClaude呼び出し
@claude このバグを修正してください

# PRは自動的にレビューされる（claude-review.yml）
```

### カスタム機能（マルチエージェント）

```markdown
# 4エージェント並列実行
@claude-multi この機能を実装してください

# GitHub Actions から手動実行
Actions > Claude Multi-Agent Build > Run workflow
```

### ローカル16エージェント環境

```bash
# tmuxセッションを開始
./scripts/tmux-16-agents.sh

# エージェントコマンドを読み込み
source ./scripts/agent-commands.sh

# 全エージェントにタスクを割り当て
ta "プロジェクトの初期構造を作成してください"
```

### エージェント管理コマンド

- `ta "command"` - 全16エージェントで実行
- `tb "command"` - ボスエージェントのみ
- `tw "command"` - ワーカーエージェント
- `tm "command"` - マネージャーエージェント
- `tg 5 "command"` - 特定のエージェント（5番）

## 🔒 セキュリティ

- プライベートリポジトリでの使用を推奨
- OAuth トークンは必ず GitHub Secrets で管理
- `.env` ファイルは絶対にコミットしない

## 📊 アーキテクチャ

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   Boss (0)  │ Manager (1) │ Manager (2) │ Manager (3) │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ Worker (4)  │ Worker (5)  │ Worker (6)  │ Worker (7)  │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ Worker (8)  │ Worker (9)  │ Worker (10) │ Worker (11) │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ Worker (12) │ Worker (13) │ Worker (14) │ Worker (15) │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

## 🤝 貢献

PRは大歓迎！特に以下の改善を求めています：
- エージェント間通信の効率化
- 新しいワークフローテンプレート
- セキュリティ強化

## 📄 ライセンス

MIT License