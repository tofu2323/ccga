#!/bin/bash

# Install Dependencies Script
# This script installs all dependencies for the CCGA project

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "🔧 Installing dependencies for CCGA project..."

# Change to project root
cd "$PROJECT_ROOT"

# Check operating system
OS="$(uname -s)"
case $OS in
    Linux*)
        PLATFORM="Linux"
        ;;
    Darwin*)
        PLATFORM="macOS"
        ;;
    CYGWIN*|MINGW*)
        PLATFORM="Windows"
        ;;
    *)
        echo "❌ Unsupported operating system: $OS"
        exit 1
        ;;
esac

echo "🖥️  Detected platform: $PLATFORM"

# Install system dependencies
install_system_deps() {
    echo "📦 Installing system dependencies..."
    
    case $PLATFORM in
        "Linux")
            if command -v apt-get &> /dev/null; then
                sudo apt-get update
                sudo apt-get install -y curl wget git tmux jq
            elif command -v yum &> /dev/null; then
                sudo yum install -y curl wget git tmux jq
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y curl wget git tmux jq
            else
                echo "⚠️  Could not detect package manager. Please install curl, wget, git, tmux, and jq manually."
            fi
            ;;
        "macOS")
            if command -v brew &> /dev/null; then
                brew install curl wget git tmux jq
            else
                echo "⚠️  Homebrew not found. Please install Homebrew first: https://brew.sh/"
                echo "Or install curl, wget, git, tmux, and jq manually"
            fi
            ;;
        "Windows")
            echo "⚠️  Please install the following tools manually on Windows:"
            echo "  - Git: https://git-scm.com/download/win"
            echo "  - tmux (via WSL): https://docs.microsoft.com/en-us/windows/wsl/"
            echo "  - jq: https://stedolan.github.io/jq/download/"
            ;;
    esac
}

# Install Node.js dependencies
install_node_deps() {
    echo "📦 Installing Node.js dependencies..."
    
    # Check if package.json exists
    if [[ -f "package.json" ]]; then
        # Detect package manager
        if [[ -f "pnpm-lock.yaml" ]] && command -v pnpm &> /dev/null; then
            echo "Using pnpm..."
            pnpm install
        elif [[ -f "yarn.lock" ]] && command -v yarn &> /dev/null; then
            echo "Using yarn..."
            yarn install
        elif command -v npm &> /dev/null; then
            echo "Using npm..."
            npm install
        else
            echo "❌ No Node.js package manager found"
            echo "Please install Node.js and npm: https://nodejs.org/"
            exit 1
        fi
    else
        echo "⚠️  No package.json found. Skipping Node.js dependencies."
    fi
}

# Install Python dependencies
install_python_deps() {
    echo "🐍 Installing Python dependencies..."
    
    if [[ -f "requirements.txt" ]]; then
        if command -v python3 &> /dev/null; then
            # Create virtual environment if it doesn't exist
            if [[ ! -d "venv" ]]; then
                echo "Creating Python virtual environment..."
                python3 -m venv venv
            fi
            
            # Activate virtual environment and install dependencies
            source venv/bin/activate
            pip install --upgrade pip
            pip install -r requirements.txt
            
            echo "✅ Python dependencies installed in virtual environment"
        else
            echo "⚠️  Python3 not found. Skipping Python dependencies."
        fi
    else
        echo "⚠️  No requirements.txt found. Skipping Python dependencies."
    fi
}

# Set executable permissions for scripts
set_permissions() {
    echo "🔧 Setting executable permissions..."
    
    find scripts/ -name "*.sh" -exec chmod +x {} \;
    find .github/scripts/ -name "*.sh" -exec chmod +x {} \;
    
    echo "✅ Executable permissions set"
}

# Create necessary directories
create_directories() {
    echo "📁 Creating necessary directories..."
    
    mkdir -p logs
    mkdir -p tmp
    mkdir -p data
    mkdir -p config
    
    echo "✅ Directories created"
}

# Validate installation
validate_installation() {
    echo "✅ Validating installation..."
    
    # Check required commands
    REQUIRED_COMMANDS=("git" "tmux" "jq")
    
    for cmd in "${REQUIRED_COMMANDS[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            echo "✓ $cmd is installed"
        else
            echo "❌ $cmd is not installed"
            exit 1
        fi
    done
    
    # Check API key
    if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
        echo "⚠️  ANTHROPIC_API_KEY environment variable is not set"
        echo "Please set your Anthropic API key in your environment or .env file"
    else
        echo "✓ ANTHROPIC_API_KEY is configured"
    fi
    
    echo "🎉 Installation validation complete!"
}

# Main installation flow
main() {
    echo "🚀 Starting installation process..."
    
    install_system_deps
    install_node_deps
    install_python_deps
    set_permissions
    create_directories
    validate_installation
    
    echo ""
    echo "🎉 CCGA project dependencies installed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Set your ANTHROPIC_API_KEY environment variable"
    echo "2. Review configuration files in config/"
    echo "3. Run: ./scripts/tmux-16-agents.sh to start agents"
    echo "4. Run: ./.github/scripts/manage-agents.sh status to check status"
}

# Run main function
main "$@" 