#!/bin/bash
# エージェント管理用コマンドエイリアス

# セッション名（環境変数で上書き可能）
CLAUDE_SESSION="${CLAUDE_SESSION:-claude-agents}"

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# 全エージェントにコマンド送信
ta() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: ta \"command\"${NC}"
        echo "Send command to all 16 agents"
        return 1
    fi
    
    echo -e "${BLUE}📢 Broadcasting to all agents...${NC}"
    for i in {0..15}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "$1" C-m
    done
    echo -e "${GREEN}✅ Command sent to all agents${NC}"
}

# ボスエージェント（0番）にコマンド送信
tb() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: tb \"command\"${NC}"
        echo "Send command to boss agent (Agent 0)"
        return 1
    fi
    
    echo -e "${MAGENTA}👑 Sending to Boss agent...${NC}"
    tmux send-keys -t $CLAUDE_SESSION:0.0 "$1" C-m
    echo -e "${GREEN}✅ Command sent to Boss${NC}"
}

# マネージャーエージェント（1-3番）にコマンド送信
tm() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: tm \"command\"${NC}"
        echo "Send command to manager agents (Agents 1-3)"
        return 1
    fi
    
    echo -e "${CYAN}👔 Sending to Manager agents...${NC}"
    for i in {1..3}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "$1" C-m
    done
    echo -e "${GREEN}✅ Command sent to all Managers${NC}"
}

# ワーカーエージェント（4-15番）にコマンド送信
tw() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: tw \"command\"${NC}"
        echo "Send command to worker agents (Agents 4-15)"
        return 1
    fi
    
    echo -e "${YELLOW}👷 Sending to Worker agents...${NC}"
    for i in {4..15}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "$1" C-m
    done
    echo -e "${GREEN}✅ Command sent to all Workers${NC}"
}

# 特定のエージェントにコマンド送信
tg() {
    if [ -z "$2" ]; then
        echo -e "${RED}Usage: tg <agent_number> \"command\"${NC}"
        echo "Send command to specific agent"
        echo "Example: tg 5 \"implement authentication\""
        return 1
    fi
    
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 0 ] || [ "$1" -gt 15 ]; then
        echo -e "${RED}Error: Agent number must be between 0 and 15${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📨 Sending to Agent $1...${NC}"
    tmux send-keys -t $CLAUDE_SESSION:0.$1 "$2" C-m
    echo -e "${GREEN}✅ Command sent to Agent $1${NC}"
}

# エージェントのステータス確認
ts() {
    echo -e "${BLUE}📊 Claude Agent Status${NC}"
    echo "======================"
    
    # エージェントの役割マッピング
    declare -A ROLES=(
        [0]="Boss"
        [1]="Manager (Frontend)"
        [2]="Manager (Backend)"
        [3]="Manager (DevOps)"
        [4]="Worker (UI/UX)"
        [5]="Worker (React/Vue)"
        [6]="Worker (CSS)"
        [7]="Worker (A11y)"
        [8]="Worker (API)"
        [9]="Worker (Database)"
        [10]="Worker (Auth)"
        [11]="Worker (Logic)"
        [12]="Worker (CI/CD)"
        [13]="Worker (K8s)"
        [14]="Worker (Monitor)"
        [15]="Worker (QA)"
    )
    
    for i in {0..15}; do
        STATUS=$(tmux list-panes -t $CLAUDE_SESSION:0 -F "#{pane_index}:#{pane_current_command}" | grep "^$i:" | cut -d: -f2)
        
        # ステータスに応じた絵文字
        if [[ "$STATUS" == *"claude"* ]]; then
            EMOJI="🟢"
        elif [[ "$STATUS" == *"sleep"* ]]; then
            EMOJI="😴"
        else
            EMOJI="🔴"
        fi
        
        printf "${EMOJI} Agent %2d [%-20s]: %s\n" $i "${ROLES[$i]}" "$STATUS"
    done
}

# エージェントビューの切り替え
tv() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: tv <agent_number>${NC}"
        echo "Switch to specific agent's pane"
        return 1
    fi
    
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 0 ] || [ "$1" -gt 15 ]; then
        echo -e "${RED}Error: Agent number must be between 0 and 15${NC}"
        return 1
    fi
    
    tmux select-pane -t $CLAUDE_SESSION:0.$1
    echo -e "${GREEN}✅ Switched to Agent $1${NC}"
}

# チーム別コマンド送信
tt() {
    if [ -z "$2" ]; then
        echo -e "${RED}Usage: tt <team> \"command\"${NC}"
        echo "Teams: frontend, backend, devops, all"
        return 1
    fi
    
    case $1 in
        frontend)
            echo -e "${CYAN}🎨 Sending to Frontend team...${NC}"
            for i in 1 4 5 6 7; do
                tmux send-keys -t $CLAUDE_SESSION:0.$i "$2" C-m
            done
            ;;
        backend)
            echo -e "${YELLOW}⚙️ Sending to Backend team...${NC}"
            for i in 2 8 9 10 11; do
                tmux send-keys -t $CLAUDE_SESSION:0.$i "$2" C-m
            done
            ;;
        devops)
            echo -e "${MAGENTA}🚀 Sending to DevOps team...${NC}"
            for i in 3 12 13 14 15; do
                tmux send-keys -t $CLAUDE_SESSION:0.$i "$2" C-m
            done
            ;;
        all)
            ta "$2"
            return
            ;;
        *)
            echo -e "${RED}Unknown team: $1${NC}"
            echo "Available teams: frontend, backend, devops, all"
            return 1
            ;;
    esac
    
    echo -e "${GREEN}✅ Command sent to $1 team${NC}"
}

# エージェントのログを表示
tl() {
    if [ -z "$1" ]; then
        echo -e "${RED}Usage: tl <agent_number>${NC}"
        echo "Show logs for specific agent"
        return 1
    fi
    
    if ! [[ "$1" =~ ^[0-9]+$ ]] || [ "$1" -lt 0 ] || [ "$1" -gt 15 ]; then
        echo -e "${RED}Error: Agent number must be between 0 and 15${NC}"
        return 1
    fi
    
    echo -e "${BLUE}📜 Logs for Agent $1:${NC}"
    tmux capture-pane -t $CLAUDE_SESSION:0.$1 -p | tail -n 50
}

# 全エージェントをクリア
tc() {
    echo -e "${YELLOW}🧹 Clearing all agent screens...${NC}"
    for i in {0..15}; do
        tmux send-keys -t $CLAUDE_SESSION:0.$i "clear" C-m
    done
    echo -e "${GREEN}✅ All screens cleared${NC}"
}

# ヘルプメッセージ
th() {
    echo -e "${BLUE}Claude Agent Commands${NC}"
    echo "===================="
    echo ""
    echo "Basic Commands:"
    echo "  ta \"cmd\"     - Send to all agents"
    echo "  tb \"cmd\"     - Send to boss (Agent 0)"
    echo "  tm \"cmd\"     - Send to managers (Agents 1-3)"
    echo "  tw \"cmd\"     - Send to workers (Agents 4-15)"
    echo "  tg N \"cmd\"   - Send to specific agent N"
    echo ""
    echo "Team Commands:"
    echo "  tt frontend \"cmd\"  - Send to frontend team"
    echo "  tt backend \"cmd\"   - Send to backend team"
    echo "  tt devops \"cmd\"    - Send to devops team"
    echo ""
    echo "Utility Commands:"
    echo "  ts           - Show agent status"
    echo "  tv N         - Switch view to agent N"
    echo "  tl N         - Show logs for agent N"
    echo "  tc           - Clear all screens"
    echo "  th           - Show this help"
    echo ""
    echo "Examples:"
    echo "  ta \"analyze requirements.txt\""
    echo "  tb \"create project plan\""
    echo "  tg 5 \"implement login component\""
    echo "  tt frontend \"review UI components\""
}

# 初期化メッセージ
echo -e "${GREEN}✅ Claude agent commands loaded!${NC}"
echo "Type 'th' for help on available commands"