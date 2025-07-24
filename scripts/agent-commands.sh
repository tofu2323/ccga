#!/bin/bash

# Agent Commands Script
# This script defines commands for individual Claude agents

set -e

AGENT_ID=${1:-1}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Log setup
LOG_DIR="$PROJECT_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/agent-${AGENT_ID}.log"

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Agent $AGENT_ID: $*" | tee -a "$LOG_FILE"
}

# Function to handle signals
cleanup() {
    log "Received shutdown signal, cleaning up..."
    exit 0
}

trap cleanup SIGTERM SIGINT

log "Starting Claude Agent $AGENT_ID"
log "Project root: $PROJECT_ROOT"
log "Log file: $LOG_FILE"

# Load environment variables if .env exists
if [[ -f "$PROJECT_ROOT/.env" ]]; then
    log "Loading environment variables from .env"
    source "$PROJECT_ROOT/.env"
fi

# Check if ANTHROPIC_API_KEY is set
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
    log "WARNING: ANTHROPIC_API_KEY is not set"
else
    log "ANTHROPIC_API_KEY is configured"
fi

# Agent-specific initialization based on AGENT_ID
case $AGENT_ID in
    1)
        log "Initializing as primary coordination agent"
        AGENT_ROLE="coordinator"
        ;;
    2|3|4|5)
        log "Initializing as analysis agent"
        AGENT_ROLE="analyzer"
        ;;
    6|7|8|9|10)
        log "Initializing as processing agent"
        AGENT_ROLE="processor"
        ;;
    11|12|13|14)
        log "Initializing as validation agent"
        AGENT_ROLE="validator"
        ;;
    15|16)
        log "Initializing as reporting agent"
        AGENT_ROLE="reporter"
        ;;
    *)
        log "Initializing as general purpose agent"
        AGENT_ROLE="general"
        ;;
esac

export AGENT_ROLE

log "Agent role: $AGENT_ROLE"

# Main agent loop
ITERATION=0
while true; do
    ITERATION=$((ITERATION + 1))
    log "Iteration $ITERATION - Agent $AGENT_ID ($AGENT_ROLE) is running"
    
    # Agent-specific tasks
    case $AGENT_ROLE in
        "coordinator")
            log "Coordinating tasks across agents..."
            # Add coordination logic here
            ;;
        "analyzer")
            log "Performing analysis tasks..."
            # Add analysis logic here
            ;;
        "processor")
            log "Processing data..."
            # Add processing logic here
            ;;
        "validator")
            log "Validating results..."
            # Add validation logic here
            ;;
        "reporter")
            log "Generating reports..."
            # Add reporting logic here
            ;;
        *)
            log "Performing general tasks..."
            # Add general logic here
            ;;
    esac
    
    # Check for task files
    TASK_FILE="$PROJECT_ROOT/tmp/task-${AGENT_ID}.json"
    if [[ -f "$TASK_FILE" ]]; then
        log "Found task file: $TASK_FILE"
        # Process task file here
        # For now, just log and remove it
        cat "$TASK_FILE" | while read -r line; do
            log "Task: $line"
        done
        rm "$TASK_FILE"
    fi
    
    # Health check
    if [[ $((ITERATION % 10)) -eq 0 ]]; then
        log "Health check - Agent $AGENT_ID is healthy after $ITERATION iterations"
    fi
    
    # Sleep between iterations
    sleep 30
done 