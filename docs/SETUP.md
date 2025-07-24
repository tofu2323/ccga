# CCGA Project Setup Guide

## Overview

CCGA (Claude Collaborative Global Agents) is a multi-agent system built around Claude AI, designed to coordinate and execute complex tasks through distributed agent collaboration.

## Prerequisites

### System Requirements

- **Operating System**: macOS, Linux, or Windows (with WSL)
- **Memory**: Minimum 8GB RAM (16GB recommended)
- **Storage**: At least 2GB free space
- **Network**: Stable internet connection for API calls

### Required Software

- **Node.js**: Version 18 or higher
- **Python**: Version 3.8 or higher
- **Git**: Latest version
- **tmux**: For agent session management
- **jq**: For JSON processing

### API Keys

- **Anthropic API Key**: Required for Claude AI access
  - Get your key from: https://console.anthropic.com/

## Quick Start

### 1. Clone and Setup

```bash
# Clone the repository
git clone <repository-url> ccga
cd ccga

# Run the installation script
./scripts/install-dependencies.sh
```

### 2. Configure Environment

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file and add your API key
# ANTHROPIC_API_KEY=your_api_key_here
```

### 3. Setup Claude Environment

```bash
# Run the Claude setup script
./.github/scripts/setup-claude.sh
```

### 4. Start Agents

```bash
# Start 16 Claude agents in tmux
./scripts/tmux-16-agents.sh

# Or use the management script
./.github/scripts/manage-agents.sh start
```

## Configuration

### Agent Configuration

Edit `config/claude-config.json` to customize:

- **Model Settings**: Choose between different Claude models
- **Agent Profiles**: Configure specialized agent roles
- **Safety Settings**: Adjust content filtering and rate limits

### MCP Configuration

Edit `config/.mcp.json` to configure:

- **MCP Servers**: Model Context Protocol integrations
- **Tools**: Available tools for each agent type
- **Global Settings**: Timeout, retries, and logging

### Tmux Configuration

The `config/tmux.conf` file provides:

- **Key Bindings**: Custom shortcuts for agent management
- **Visual Styling**: Color-coded agent sessions
- **Logging**: Automatic log capture for debugging

## Agent Roles

### Coordinator (Agent 1)
- **Purpose**: Task planning and delegation
- **Tools**: File management, Git, Task management
- **Configuration**: Low temperature for consistent planning

### Analyzers (Agents 2-5)
- **Purpose**: Data and code analysis
- **Tools**: File management
- **Configuration**: Higher token limit for complex analysis

### Processors (Agents 6-10)
- **Purpose**: Task execution and data transformation
- **Tools**: File management, Task management
- **Configuration**: Balanced settings for processing work

### Validators (Agents 11-14)
- **Purpose**: Quality assurance and testing
- **Tools**: File management, Git
- **Configuration**: Low temperature for consistent validation

### Reporters (Agents 15-16)
- **Purpose**: Documentation and reporting
- **Tools**: File management, Task management
- **Configuration**: High token limit for comprehensive reports

## Usage

### Starting Agents

```bash
# Start all agents
./scripts/tmux-16-agents.sh

# Start specific number of agents
./scripts/tmux-16-agents.sh 8

# Use management script
./.github/scripts/manage-agents.sh start --count 12
```

### Managing Agents

```bash
# Check agent status
./.github/scripts/manage-agents.sh status

# View agent logs
./.github/scripts/manage-agents.sh logs

# Stop all agents
./.github/scripts/manage-agents.sh stop

# Restart agents
./.github/scripts/manage-agents.sh restart
```

### Tmux Commands

```bash
# Attach to agent session
tmux attach -t claude-agents

# List agent windows
tmux list-windows -t claude-agents

# Switch to specific agent
tmux select-window -t claude-agents:agent-5
```

## Monitoring

### Log Files

Agent logs are stored in `logs/`:

- `agent-{id}.log`: Individual agent logs
- `tmux-*.log`: Tmux session logs

### Status Monitoring

Use the status commands to monitor:

- **Agent Health**: Running/stopped status
- **Task Progress**: Current task execution
- **Resource Usage**: Memory and CPU utilization

## Troubleshooting

### Common Issues

**Agents not starting:**
- Check ANTHROPIC_API_KEY is set
- Verify tmux is installed
- Check script permissions

**API Rate Limits:**
- Reduce concurrent agents
- Adjust rate limits in config
- Check API quota

**Permission Errors:**
- Run: `chmod +x scripts/*.sh`
- Run: `chmod +x .github/scripts/*.sh`

### Debug Mode

Enable debug logging:

```bash
export DEBUG=true
./scripts/tmux-16-agents.sh
```

### Logs Analysis

```bash
# View all agent logs
tail -f logs/*.log

# Filter specific agent
grep "Agent 5" logs/agent-5.log

# Monitor errors
grep "ERROR" logs/*.log
```

## Development

### Adding New Agents

1. Update agent count in scripts
2. Add agent profile in `config/claude-config.json`
3. Update MCP configuration if needed
4. Test with development setup

### Custom Tools

1. Add MCP server configuration
2. Update agent tool permissions
3. Test tool integration
4. Document usage

### Testing

```bash
# Run agent tests
npm test

# Run specific agent test
npm test -- --agent=coordinator

# Integration tests
npm run test:integration
```

## Support

### Documentation

- **GitHub Issues**: Report bugs and feature requests
- **Wiki**: Detailed implementation guides
- **Examples**: Sample configurations and use cases

### Community

- **Discussions**: GitHub Discussions for questions
- **Discord**: Real-time community support
- **Stack Overflow**: Tag questions with `ccga-claude`

## Security

### API Key Security

- Never commit API keys to version control
- Use environment variables or secure vaults
- Rotate keys regularly

### Network Security

- Use HTTPS for all API calls
- Consider VPN for sensitive deployments
- Monitor API usage for anomalies

### Agent Isolation

- Agents run in separate tmux windows
- File system access is controlled
- Network access can be restricted

## License

This project is licensed under the MIT License. See LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes with tests
4. Submit a pull request

Please follow the contribution guidelines in CONTRIBUTING.md. 