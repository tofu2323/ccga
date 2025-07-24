# セットアップガイド

このガイドでは、Claude Code + GitHub Actions 統合環境のセットアップ手順を詳しく説明します。

## 前提条件

- Node.js 18以上
- Git
- GitHub アカウント
- Claude Code Pro または Max プラン（GitHub Actions統合に必要）

## セットアップ手順

### 1. リポジトリの準備

```bash
# リポジトリをクローン
git clone https://github.com/your-username/your-repo.git
cd your-repo

# または新規作成
mkdir my-claude-project
cd my-claude-project
git init
```

### 2. 依存関係のインストール

```bash
# 実行権限を付与
chmod +x scripts/install-dependencies.sh

# インストールスクリプトを実行
./scripts/install-dependencies.sh
```

これにより以下がインストールされます：
- Claude Code (npm package)
- tmux（マルチエージェント環境用）
- GitHub CLI（オプション）

### 3. Claude Code の初期設定

#### 方法1: 自動セットアップ（推奨）

```bash
# Claude Code を起動
claude

# GitHub App を自動インストール
/init-github-app
```

このコマンドで以下が自動的に行われます：
- GitHub App のインストール
- OAuth トークンの生成と設定
- デフォルトワークフローの作成
  - `.github/workflows/claude.yml`
  - `.github/workflows/claude-review.yml`

#### 方法2: 手動セットアップ

```bash
# OAuth トークンを生成
claude setup-token

# 表示されたトークンをコピー
# GitHub リポジトリの Settings > Secrets > Actions で
# CLAUDE_CODE_OAUTH_TOKEN として追加
```

### 4. 環境変数の設定

```bash
# 環境変数ファイルをコピー
cp .env.example .env

# .env ファイルを編集
nano .env  # または好きなエディタで
```

必須の環境変数：
```bash
CLAUDE_CODE_OAUTH_TOKEN=your-oauth-token-here
GITHUB_TOKEN=your-github-token-here
```

### 5. GitHub Actions の設定

#### デフォルトワークフローの確認

`/init-github-app` を実行した場合、以下のワークフローが作成されています：

1. **claude.yml** - @claude メンション応答
2. **claude-review.yml** - PR自動レビュー

#### カスタムワークフローの追加

マルチエージェント機能を使いたい場合：

```bash
# カスタムワークフローをコピー
cp .github/workflows/claude-multi-agent.yml.example .github/workflows/claude-multi-agent.yml
cp .github/workflows/claude-enhanced.yml.example .github/workflows/claude-enhanced.yml
```

### 6. マルチエージェント環境のセットアップ

#### ローカル環境（16エージェント）

```bash
# 実行権限を付与
chmod +x scripts/tmux-16-agents.sh
chmod +x scripts/agent-commands.sh

# 16エージェント環境を起動
./scripts/tmux-16-agents.sh

# 別のターミナルで、エージェントコマンドを読み込み
source scripts/agent-commands.sh
```

#### 基本的な使い方

```bash
# 全エージェントにタスクを送信
ta "プロジェクトの初期構造を作成してください"

# ボスエージェントに指示
tb "全体の設計方針を決定してください"

# 特定のエージェントに指示
tg 5 "ログインコンポーネントを実装してください"

# エージェントのステータス確認
ts
```

### 7. プロジェクトコンテキストの設定

```bash
# .claude ディレクトリを作成
mkdir -p .claude

# CLAUDE.md を作成（プロジェクトの説明）
cat > .claude/CLAUDE.md << 'EOF'
# プロジェクト名

## 概要
このプロジェクトの説明

## 技術スタック
- Frontend: React/TypeScript
- Backend: Node.js/Express
- Database: PostgreSQL

## コーディング規約
- ESLint の設定に従う
- Prettier でフォーマット
- Conventional Commits を使用

## 重要事項
- テストを必ず書く
- ドキュメントを更新する
EOF
```

### 8. セキュリティの確認

```bash
# .gitignore の確認
cat >> .gitignore << 'EOF'
.env
.env.local
.claude-token
*.log
.agent-status/
node_modules/
EOF

# プライベートリポジトリであることを確認
gh repo view --json private
```

## トラブルシューティング

### Claude Code が起動しない

```bash
# Node.js バージョンを確認
node --version  # 18以上である必要があります

# Claude Code を再インストール
npm uninstall -g @anthropic-ai/claude-code
npm install -g @anthropic-ai/claude-code
```

### GitHub Actions が動作しない

1. CLAUDE_CODE_OAUTH_TOKEN が正しく設定されているか確認
2. GitHub App がリポジトリにインストールされているか確認
3. ワークフローのログを確認

```bash
# 最新のワークフロー実行を確認
gh run list --limit 5

# 特定の実行のログを表示
gh run view <run-id> --log
```

### tmux セッションの問題

```bash
# 既存のセッションを確認
tmux ls

# セッションを強制終了
tmux kill-session -t claude-agents

# tmux の設定をリセット
rm -rf ~/.tmux.conf
cp config/tmux.conf ~/.tmux.conf
```

## 次のステップ

1. [デフォルトワークフローガイド](DEFAULT_WORKFLOWS.md) を読む
2. 最初のタスクを実行してみる
3. チームメンバーにセットアップ手順を共有する

## サポート

問題が解決しない場合：
- [GitHub Issues](https://github.com/your-username/your-repo/issues) で報告
- [Anthropic サポート](https://support.anthropic.com) に連絡