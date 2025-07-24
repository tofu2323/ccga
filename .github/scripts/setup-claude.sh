#!/bin/bash
# Claude Code セットアップスクリプト（GitHub Actions用）

set -e

echo "🚀 Setting up Claude Code..."

# Claude Code のインストール
if ! command -v claude &> /dev/null; then
    echo "📦 Installing Claude Code..."
    npm install -g @anthropic-ai/claude-code
else
    echo "✅ Claude Code is already installed"
fi

# OAuth トークンの設定
if [ -n "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    echo "🔐 Configuring OAuth token..."
    echo "$CLAUDE_CODE_OAUTH_TOKEN" > ~/.claude-token
    claude auth login --token-file ~/.claude-token
    rm ~/.claude-token  # セキュリティのため削除
    echo "✅ OAuth token configured"
else
    echo "⚠️  CLAUDE_CODE_OAUTH_TOKEN not found in environment"
    exit 1
fi

# プロジェクトコンテキストの設定
if [ -f ".claude/CLAUDE.md" ]; then
    echo "📄 Project context file found"
else
    echo "📝 Creating default project context..."
    mkdir -p .claude
    cat > .claude/CLAUDE.md << 'EOF'
# Claude Code Project Context

## プロジェクト概要
GitHub Actions と統合された Claude Code プロジェクト

## コーディング規約
- TypeScript/JavaScript: ESLint標準に従う
- コミットメッセージ: Conventional Commits形式
- テスト: 新機能には必ずテストを追加

## 重要な注意事項
- プライベートリポジトリでの使用を推奨
- 機密情報はコードに含めない
EOF
fi

# カスタムコマンドの設定
if [ -d ".claude/commands" ]; then
    echo "📁 Custom commands directory found"
else
    echo "📝 Creating custom commands..."
    mkdir -p .claude/commands
    
    # デバッグコマンド
    cat > .claude/commands/debug.md << 'EOF'
エラーメッセージを分析して、以下を実行してください：
1. エラーの原因を特定
2. 関連するファイルを調査
3. 修正案を提示
4. 必要であればテストを追加

エラー: $ARGUMENTS
EOF

    # PR作成コマンド
    cat > .claude/commands/create-pr.md << 'EOF'
以下のタスクについてPRを作成してください：
1. 必要な変更を実装
2. テストを追加/更新
3. コミットメッセージを作成（Conventional Commits形式）
4. PRの説明文を作成
5. `gh pr create` でPRを作成

タスク: $ARGUMENTS
EOF
fi

# MCP設定の確認
if [ -f "config/.mcp.json" ]; then
    echo "⚙️  MCP configuration found"
    cp config/.mcp.json ~/.claude/.mcp.json
else
    echo "📝 Creating default MCP configuration..."
    mkdir -p ~/.claude
    cat > ~/.claude/.mcp.json << 'EOF'
{
  "version": "1.0",
  "agents": {
    "default": {
      "model": "claude-opus-4-20250514",
      "temperature": 0.7,
      "max_tokens": 4096
    }
  }
}
EOF
fi

echo "✅ Claude Code setup complete!"
echo ""
echo "Available commands:"
echo "  claude code <prompt>     - Run Claude Code with a prompt"
echo "  claude --help           - Show help"
echo ""

# 環境変数をエクスポート（GitHub Actions用）
echo "CLAUDE_SETUP_COMPLETE=true" >> $GITHUB_ENV