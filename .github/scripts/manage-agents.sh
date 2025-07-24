#!/bin/bash

# Claude Agents Management Script
# This script manages Claude agents for the CCGA project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Default values
AGENT_COUNT=16
COMMAND=""
TMUX_SESSION="claude-agents"

# Usage function
usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  start     Start Claude agents"
    echo "  stop      Stop Claude agents"
    echo "  restart   Restart Claude agents"
    echo "  status    Show agent status"
    echo "  logs      Show agent logs"
    echo ""
    echo "Options:"
    echo "  -c, --count NUM    Number of agents (default: 16)"
    echo "  -h, --help         Show this help message"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        start|stop|restart|status|logs)
            COMMAND="$1"
            shift
            ;;
        -c|--count)
            AGENT_COUNT="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if command is provided
if [[ -z "$COMMAND" ]]; then
    echo "❌ Error: No command provided"
    usage
fi

# Function to start agents
start_agents() {
    echo "🚀 Starting $AGENT_COUNT Claude agents..."
    
    # Check if tmux session exists
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo "⚠️  Tmux session '$TMUX_SESSION' already exists. Stopping it first..."
        tmux kill-session -t "$TMUX_SESSION"
    fi
    
    # Start tmux session with agents
    cd "$PROJECT_ROOT"
    if [[ -f "scripts/tmux-16-agents.sh" ]]; then
        ./scripts/tmux-16-agents.sh "$AGENT_COUNT"
    else
        echo "❌ Error: tmux-16-agents.sh script not found"
        exit 1
    fi
    
    echo "✅ Claude agents started successfully"
}

# Function to stop agents
stop_agents() {
    echo "🛑 Stopping Claude agents..."
    
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        tmux kill-session -t "$TMUX_SESSION"
        echo "✅ Claude agents stopped successfully"
    else
        echo "⚠️  No running agents found"
    fi
}

# Function to show agent status
show_status() {
    echo "📊 Claude agents status:"
    
    if tmux has-session -t "$TMUX_SESSION" 2>/dev/null; then
        echo "✅ Tmux session '$TMUX_SESSION' is running"
        tmux list-windows -t "$TMUX_SESSION"
    else
        echo "❌ No running agents found"
    fi
}

# Function to show logs
show_logs() {
    echo "📝 Showing Claude agents logs..."
    
    if [[ -d "logs" ]]; then
        tail -f logs/*.log
    else
        echo "⚠️  No log directory found"
    fi
}

# Execute command
case "$COMMAND" in
    start)
        start_agents
        ;;
    stop)
        stop_agents
        ;;
    restart)
        stop_agents
        sleep 2
        start_agents
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs
        ;;
    *)
        echo "❌ Error: Unknown command '$COMMAND'"
        usage
        ;;
esac 