#!/bin/bash
# エージェント管理スクリプト（GitHub Actions用）

set -e

# コマンドライン引数の処理
COMMAND=${1:-help}
AGENT_COUNT=${2:-4}
TASK=${3:-""}

# エージェントステータスファイル
STATUS_DIR=".agent-status"
mkdir -p $STATUS_DIR

# 関数：エージェントの役割を取得
get_agent_role() {
    local agent_id=$1
    case $agent_id in
        1) echo "ボス：全体設計と調整" ;;
        2|3|4) echo "マネージャー：チーム管理" ;;
        *) echo "ワーカー：実装担当" ;;
    esac
}

# 関数：エージェントを起動
start_agent() {
    local agent_id=$1
    local task=$2
    local role=$(get_agent_role $agent_id)
    
    echo "🚀 Starting Agent $agent_id ($role)"
    
    # エージェント用のプロンプトを作成
    cat > "$STATUS_DIR/agent-$agent_id-prompt.txt" << EOF
エージェント番号: $agent_id
役割: $role
タスク: $task

あなたは16エージェントチームの一員です。
他のエージェントと協調して、タスクを効率的に完成させてください。
EOF

    # バックグラウンドでClaude Codeを実行
    (
        claude code "$(cat $STATUS_DIR/agent-$agent_id-prompt.txt)" \
            --context-path . \
            --output-format json > "$STATUS_DIR/agent-$agent_id-output.json" 2>&1
        echo "completed" > "$STATUS_DIR/agent-$agent_id.status"
    ) &
    
    echo $! > "$STATUS_DIR/agent-$agent_id.pid"
    echo "running" > "$STATUS_DIR/agent-$agent_id.status"
}

# 関数：全エージェントを起動
start_all_agents() {
    local count=$1
    local task=$2
    
    echo "🎯 Starting $count agents for task: $task"
    
    for i in $(seq 1 $count); do
        start_agent $i "$task"
    done
    
    echo "✅ All agents started"
}

# 関数：エージェントのステータスを確認
check_status() {
    echo "📊 Agent Status:"
    echo "================"
    
    for status_file in $STATUS_DIR/agent-*.status; do
        if [ -f "$status_file" ]; then
            agent_id=$(basename $status_file | sed 's/agent-\(.*\)\.status/\1/')
            status=$(cat $status_file)
            role=$(get_agent_role $agent_id)
            
            # ステータスに応じた絵文字
            case $status in
                running) emoji="🏃" ;;
                completed) emoji="✅" ;;
                failed) emoji="❌" ;;
                *) emoji="❓" ;;
            esac
            
            echo "$emoji Agent $agent_id ($role): $status"
        fi
    done
}

# 関数：エージェントの結果を収集
collect_results() {
    echo "📥 Collecting agent results..."
    
    mkdir -p results
    
    for output_file in $STATUS_DIR/agent-*-output.json; do
        if [ -f "$output_file" ]; then
            agent_id=$(basename $output_file | sed 's/agent-\(.*\)-output\.json/\1/')
            
            # 結果を整形して保存
            echo "## Agent $agent_id Results" > "results/agent-$agent_id.md"
            echo "" >> "results/agent-$agent_id.md"
            
            if [ -s "$output_file" ]; then
                jq -r '.message // "No message"' "$output_file" >> "results/agent-$agent_id.md" 2>/dev/null || \
                echo "Error processing output" >> "results/agent-$agent_id.md"
            else
                echo "No output generated" >> "results/agent-$agent_id.md"
            fi
        fi
    done
    
    # 統合レポートを作成
    echo "# Multi-Agent Task Results" > results/summary.md
    echo "" >> results/summary.md
    echo "Task: $(cat $STATUS_DIR/task.txt 2>/dev/null || echo 'Unknown')" >> results/summary.md
    echo "Agents: $AGENT_COUNT" >> results/summary.md
    echo "Date: $(date)" >> results/summary.md
    echo "" >> results/summary.md
    
    for result_file in results/agent-*.md; do
        if [ -f "$result_file" ]; then
            cat "$result_file" >> results/summary.md
            echo "" >> results/summary.md
        fi
    done
    
    echo "✅ Results collected in results/summary.md"
}

# 関数：全エージェントを停止
stop_all_agents() {
    echo "🛑 Stopping all agents..."
    
    for pid_file in $STATUS_DIR/*.pid; do
        if [ -f "$pid_file" ]; then
            pid=$(cat $pid_file)
            if kill -0 $pid 2>/dev/null; then
                kill $pid
                echo "Stopped process $pid"
            fi
        fi
    done
    
    rm -rf $STATUS_DIR
    echo "✅ All agents stopped"
}

# 関数：ヘルプを表示
show_help() {
    echo "Claude Code Multi-Agent Manager"
    echo "==============================="
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  start <count> <task>   Start multiple agents with a task"
    echo "  status                 Check status of all agents"
    echo "  results                Collect and display results"
    echo "  stop                   Stop all running agents"
    echo "  help                   Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 start 4 'Implement user authentication'"
    echo "  $0 status"
    echo "  $0 results"
}

# メインコマンド処理
case $COMMAND in
    start)
        if [ -z "$TASK" ]; then
            echo "Error: Task is required"
            show_help
            exit 1
        fi
        echo "$TASK" > "$STATUS_DIR/task.txt"
        start_all_agents $AGENT_COUNT "$TASK"
        ;;
    status)
        check_status
        ;;
    results)
        collect_results
        ;;
    stop)
        stop_all_agents
        ;;
    help|*)
        show_help
        ;;
esac