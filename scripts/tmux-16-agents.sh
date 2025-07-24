#!/bin/bash
# 16エージェント並列実行環境セットアップスクリプト

SESSION_NAME="claude-agents"
CONFIG_FILE="${CONFIG_FILE:-config/tmux.conf}"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Claude Code 16-Agent Environment Setup${NC}"
echo "========================================"

# tmuxの確認
if ! command -v tmux &> /dev/null; then
    echo -e "${RED}Error: tmux is not installed${NC}"
    echo "Please install tmux first: sudo apt-get install tmux"
    exit 1
fi

# Claude Codeの確認
if ! command -v claude &> /dev/null; then
    echo -e "${RED}Error: Claude Code is not installed${NC}"
    echo "Please install Claude Code first: npm install -g @anthropic-ai/claude-code"
    exit 1
fi

# 既存セッションの確認
if tmux has-session -t $SESSION_NAME 2>/dev/null; then
    echo -e "${YELLOW}Warning: Session '$SESSION_NAME' already exists${NC}"
    read -p "Kill existing session? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        tmux kill-session -t $SESSION_NAME
        echo "Existing session killed"
    else
        echo "Attaching to existing session..."
        tmux attach -t $SESSION_NAME
        exit 0
    fi
fi

# tmux設定ファイルの適用
if [ -f "$CONFIG_FILE" ]; then
    TMUX_CONFIG="-f $CONFIG_FILE"
else
    TMUX_CONFIG=""
fi

# セッション作成
echo -e "${GREEN}Creating new session: $SESSION_NAME${NC}"
tmux new-session -d -s $SESSION_NAME $TMUX_CONFIG

# 16分割のレイアウト作成
echo "Creating 4x4 grid layout..."
for i in {1..15}; do
    if [ $((i % 4)) -eq 0 ]; then
        tmux split-window -v -t $SESSION_NAME
        tmux select-layout -t $SESSION_NAME tiled
    else
        tmux split-window -h -t $SESSION_NAME
        tmux select-layout -t $SESSION_NAME tiled
    fi
done

# エージェントの役割定義
declare -A AGENT_ROLES=(
    [0]="ボス：全体設計・調整"
    [1]="マネージャー：フロントエンド"
    [2]="マネージャー：バックエンド"
    [3]="マネージャー：インフラ・DevOps"
    [4]="ワーカー：UI/UXデザイン"
    [5]="ワーカー：React/Vue開発"
    [6]="ワーカー：CSS/スタイリング"
    [7]="ワーカー：アクセシビリティ"
    [8]="ワーカー：API設計"
    [9]="ワーカー：データベース"
    [10]="ワーカー：認証・セキュリティ"
    [11]="ワーカー：ビジネスロジック"
    [12]="ワーカー：CI/CD"
    [13]="ワーカー：コンテナ・K8s"
    [14]="ワーカー：モニタリング"
    [15]="ワーカー：テスト・QA"
)

# 各ペインの初期設定
echo "Initializing agents..."
for i in {0..15}; do
    # ペインのタイトル設定
    tmux send-keys -t $SESSION_NAME:0.$i "printf '\\033]2;Agent $i: ${AGENT_ROLES[$i]}\\033\\\\'" C-m
    
    # エージェント起動メッセージ
    tmux send-keys -t $SESSION_NAME:0.$i "echo -e '${BLUE}Agent $i: ${AGENT_ROLES[$i]}${NC}'" C-m
    tmux send-keys -t $SESSION_NAME:0.$i "echo '======================================'" C-m
    
    # Claude Code起動（少し遅延を入れて順次起動）
    tmux send-keys -t $SESSION_NAME:0.$i "sleep $((i * 2)); claude --agent-name 'Agent-$i' --role '${AGENT_ROLES[$i]}'" C-m
done

# レイアウトを4x4グリッドに最終調整
tmux select-layout -t $SESSION_NAME:0 tiled

# エージェントコマンドのエイリアス設定
echo -e "${GREEN}Setting up agent commands...${NC}"
cat > /tmp/claude-agent-commands.sh << 'EOF'
# Claude Agent Commands
export CLAUDE_SESSION="claude-agents"

# 全エージェントにコマンド送信
ta() {
    for i in {0..15}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "$1" C-m
    done
}

# ボスエージェント（0番）にコマンド送信
tb() {
    tmux send-keys -t $CLAUDE_SESSION:0.0 "$1" C-m
}

# マネージャーエージェント（1-3番）にコマンド送信
tm() {
    for i in {1..3}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "$1" C-m
    done
}

# ワーカーエージェント（4-15番）にコマンド送信
tw() {
    for i in {4..15}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "$1" C-m
    done
}

# 特定のエージェントにコマンド送信
tg() {
    if [ -z "$2" ]; then
        echo "Usage: tg <agent_number> <command>"
        return 1
    fi
    tmux send-keys -t $CLAUDE_SESSION:0.$1 "$2" C-m
}

# エージェントのステータス確認
ts() {
    echo "Claude Agent Status:"
    echo "==================="
    tmux list-panes -t $CLAUDE_SESSION:0 -F "Agent #{pane_index}: #{pane_current_command}"
}

# エージェントビューの切り替え
tv() {
    if [ -z "$1" ]; then
        echo "Usage: tv <agent_number>"
        return 1
    fi
    tmux select-pane -t $CLAUDE_SESSION:0.$1
}

echo "Claude agent commands loaded!"
echo "Commands: ta, tb, tm, tw, tg, ts, tv"
EOF

echo ""
echo -e "${GREEN}✅ 16 Claude agents started successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Attach to session: tmux attach -t $SESSION_NAME"
echo "2. Load agent commands: source /tmp/claude-agent-commands.sh"
echo "3. Use commands: ta, tb, tm, tw, tg, ts, tv"
echo ""
echo "Quick start example:"
echo "  ta \"プロジェクトの要件を分析してください\""
echo ""

# オプション：自動的にセッションにアタッチ
read -p "Attach to session now? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    tmux attach -t $SESSION_NAME
fi