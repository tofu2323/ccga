#!/bin/bash

echo "Installing dependencies..."

# Node.js と npm の確認
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Please install Node.js first."
    exit 1
fi

# tmux のインストール
if ! command -v tmux &> /dev/null; then
    echo "Installing tmux..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install tmux
    else
        sudo apt-get update && sudo apt-get install -y tmux
    fi
fi

# Claude Code のインストール
echo "Installing Claude Code..."
npm install -g @anthropic-ai/claude-code

echo ""
echo "✅ Claude Code installed!"
echo ""
echo "Next steps:"
echo "1. Run 'claude' to start Claude Code"
echo "2. Run '/init-github-app' within Claude Code to set up GitHub integration"
echo "3. Or manually set up with 'claude setup-token'"
echo ""

# GitHub CLI のインストール（オプション）
if ! command -v gh &> /dev/null; then
    echo "Installing GitHub CLI..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    else
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install gh
    fi
fi

echo "All dependencies installed successfully!"
echo ""
echo "🚀 Quick Start:"
echo "1. cd to your project directory"
echo "2. Run 'claude' to start Claude Code"
echo "3. Run '/init-github-app' to set up GitHub integration"
echo "4. Run './scripts/tmux-16-agents.sh' for multi-agent setup"