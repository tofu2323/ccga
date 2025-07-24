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

### 2. Claude Code OAuth トークンの取得

```bash
# Claude Code をインストール
npm install -g @anthropic-ai/claude-code

# OAuth トークンを生成
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

## 📝 使い方

### Issue/PRでのClaude呼び出し

```markdown
@claude このバグを修正してください
```

### マルチエージェントビルドの実行

GitHub Actions の "Claude Multi-Agent Build" ワークフローを手動実行。

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