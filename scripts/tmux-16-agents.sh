#!/bin/bash

# Tmux 16 Agents Script
# This script creates a tmux session with 16 Claude agents

set -e

AGENT_COUNT=${1:-16}
SESSION_NAME="claude-agents"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🚀 Starting $AGENT_COUNT Claude agents in tmux session '$SESSION_NAME'..."

# Kill existing session if it exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "⚠️  Killing existing session '$SESSION_NAME'..."
    tmux kill-session -t "$SESSION_NAME"
fi

# Create new tmux session
echo "📱 Creating tmux session '$SESSION_NAME'..."
tmux new-session -d -s "$SESSION_NAME" -c "$PROJECT_ROOT"

# Rename the first window
tmux rename-window -t "$SESSION_NAME:0" "agent-1"

# Create additional windows for each agent
for ((i=2; i<=AGENT_COUNT; i++)); do
    tmux new-window -t "$SESSION_NAME" -c "$PROJECT_ROOT" -n "agent-$i"
done

# Start agent processes in each window
for ((i=1; i<=AGENT_COUNT; i++)); do
    echo "🤖 Starting agent $i..."
    tmux send-keys -t "$SESSION_NAME:agent-$i" "cd $PROJECT_ROOT" C-m
    tmux send-keys -t "$SESSION_NAME:agent-$i" "echo 'Agent $i started. PID: \$\$'" C-m
    tmux send-keys -t "$SESSION_NAME:agent-$i" "export AGENT_ID=$i" C-m
    tmux send-keys -t "$SESSION_NAME:agent-$i" "export AGENT_COUNT=$AGENT_COUNT" C-m
    
    # Run agent-specific commands
    if [[ -f "$SCRIPT_DIR/agent-commands.sh" ]]; then
        tmux send-keys -t "$SESSION_NAME:agent-$i" "./scripts/agent-commands.sh $i" C-m
    else
        # Default command if agent-commands.sh doesn't exist
        tmux send-keys -t "$SESSION_NAME:agent-$i" "echo 'Claude Agent $i running... (no agent-commands.sh found)'" C-m
        tmux send-keys -t "$SESSION_NAME:agent-$i" "while true; do sleep 10; echo 'Agent $i heartbeat at \$(date)'; done" C-m
    fi
done

# Configure tmux settings
tmux set-option -t "$SESSION_NAME" mouse on
tmux set-option -t "$SESSION_NAME" status-bg colour235
tmux set-option -t "$SESSION_NAME" status-fg colour136
tmux set-option -t "$SESSION_NAME" status-left "#[fg=colour166]#S #[fg=colour245]| "
tmux set-option -t "$SESSION_NAME" status-right "#[fg=colour166]%Y-%m-%d %H:%M"

# Create a summary window
tmux new-window -t "$SESSION_NAME" -c "$PROJECT_ROOT" -n "summary"
tmux send-keys -t "$SESSION_NAME:summary" "clear" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo '=== Claude Agents Summary ==='" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo 'Session: $SESSION_NAME'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo 'Agent count: $AGENT_COUNT'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo 'Started at: \$(date)'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo ''" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo 'Commands:'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo '  tmux attach -t $SESSION_NAME  # Attach to session'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo '  tmux kill-session -t $SESSION_NAME  # Kill session'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo '  tmux list-windows -t $SESSION_NAME  # List windows'" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo ''" C-m
tmux send-keys -t "$SESSION_NAME:summary" "echo 'Use Ctrl+b then number to switch between agents'" C-m

# Focus on summary window
tmux select-window -t "$SESSION_NAME:summary"

echo "✅ Tmux session '$SESSION_NAME' created with $AGENT_COUNT agents"
echo "📱 To attach: tmux attach -t $SESSION_NAME"
echo "🛑 To kill: tmux kill-session -t $SESSION_NAME"

# Optionally attach to the session
if [[ "${TMUX_AUTO_ATTACH:-}" == "true" ]]; then
    tmux attach -t "$SESSION_NAME"
fi 