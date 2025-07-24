#!/bin/bash

# Claude Setup Script
# This script sets up the Claude environment for the CCGA project

set -e

echo "🤖 Setting up Claude environment..."

# Check if required environment variables are set
if [[ -z "${ANTHROPIC_API_KEY}" ]]; then
    echo "❌ Error: ANTHROPIC_API_KEY environment variable is not set"
    echo "Please set your Anthropic API key in the environment variables"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
if command -v npm &> /dev/null; then
    npm install
elif command -v yarn &> /dev/null; then
    yarn install
elif command -v pnpm &> /dev/null; then
    pnpm install
else
    echo "❌ Error: No package manager found (npm, yarn, or pnpm)"
    exit 1
fi

# Create necessary directories if they don't exist
echo "📁 Creating directories..."
mkdir -p logs
mkdir -p tmp
mkdir -p data

# Set executable permissions for scripts
echo "🔧 Setting executable permissions..."
chmod +x scripts/*.sh
chmod +x .github/scripts/*.sh

# Validate configuration files
echo "✅ Validating configuration..."
if [[ -f "config/claude-config.json" ]]; then
    echo "✓ Claude configuration found"
else
    echo "⚠️  Warning: Claude configuration not found"
fi

if [[ -f "config/.mcp.json" ]]; then
    echo "✓ MCP configuration found"
else
    echo "⚠️  Warning: MCP configuration not found"
fi

echo "🎉 Claude environment setup complete!" 