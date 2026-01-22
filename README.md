# CC Suite

**The Standard Library for Claude Code Workflows**

English | [中文](README.zh-CN.md)

[![Claude Code](https://img.shields.io/badge/Claude_Code-Skills-blueviolet)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A curated collection of Claude Code skills that enhance your AI workflow with **Trust**, **Reach**, and **Efficiency**.

## Skills Overview

```
CC Suite
├── 🛡️ crosscheck          ─── Multi-model verification (Claude + Codex + Gemini)
├── 📢 social-publisher     ─── Automated social media publishing
└── ⚙️⚡ boris-workflow      ─── Claude Code environment tools
        ├── ⚙️ claude-code-setup  ─── Initialize dev environment (one-time)
        └── ⚡ create-subagent     ─── Create custom agents (ongoing)
```

| Skill | Description | MCP Dependencies | Install Command |
|-------|-------------|------------------|-----------------|
| crosscheck | 3-round cross-verification with Claude, Codex, Gemini | Codex, Gemini | `./install.sh crosscheck` |
| social-publisher | Publish to Twitter, WeChat, Xiaohongshu | Playwright | `./install.sh social-publisher` |
| boris-workflow | Dev environment tools (2 sub-skills) | Codex | `./install.sh boris-workflow` |

> **Note**: `boris-workflow` is a skill group containing two related skills. Install with `./install.sh boris-workflow` to get both, or install individually with `./install.sh claude-code-setup` or `./install.sh create-subagent`.

## One-Line Install

```bash
git clone https://github.com/leiMizzou/CC-Suite.git && cd CC-Suite && ./install.sh
```

Then login and restart:
```bash
codex        # Login to OpenAI (first time only)
gemini       # Login to Google (first time only)
/exit        # Restart Claude Code to load skills
```

## Modular Installation

Install only the skills you need:

```bash
# Install specific skills
./install.sh crosscheck social-publisher

# Install skill group
./install.sh boris-workflow    # Installs claude-code-setup + create-subagent

# Install single skill
./install.sh crosscheck

# Force reinstall
./install.sh --force
```

## Usage Examples

### 🛡️ CrossCheck - Multi-Model Verification

Reduce AI hallucinations through 3-round cross-verification:

```
/crosscheck Is microservices the right architecture for this project?
/crosscheck What's the best approach for real-time collaboration?
```

### 📢 SocialPublisher - Social Media Automation

One-click publish to multiple platforms:

```
/social-media-publisher "Today's AI highlights" xiaohongshu wechat
```

### ⚡ CreateSubagent - Custom Agent Builder

Create specialized agents for complex tasks:

```
/create-subagent code-reviewer
```

## Suite Synergy

CC-Suite's three parts form a powerful closed-loop system:

```
┌─────────────────────────────────────────────────────────┐
│                    SocialPublisher                       │
│              (Output Layer - Content Distribution)       │
└─────────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────────┐
│                      CrossCheck                          │
│              (Verification Layer - Quality Assurance)    │
└─────────────────────────────────────────────────────────┘
                           ↑
┌─────────────────────────────────────────────────────────┐
│                    BorisWorkflow                         │
│              (Foundation Layer - Environment & Tools)    │
└─────────────────────────────────────────────────────────┘
```

### Workflow 1: New Project Setup
```bash
/init                                    # Initialize Claude Code environment
/setup-permissions --preset recommended  # Configure permissions
/setup-plugins --preset web-dev          # Configure MCP plugins
/create-subagent                         # Create project-specific agents
```

### Workflow 2: Autonomous Development + Verification
```bash
/setup-ralph-loop --enable               # Enable Ralph Loop

/ralph-loop "Implement user auth with TDD, output <promise>DONE</promise> when complete" \
  --max-iterations 30                    # Autonomous iteration

/crosscheck "JWT vs Session - which is better for this use case?"  # Verify decisions
```

### Workflow 3: Trend Research → Development
```bash
# 1. Search trending discussions
/social-media-publisher "Search 10 hottest AI Agent posts today, no engagement"

# 2. Verify a popular claim
/crosscheck "Is ReAct pattern really the best for AI Agents?"

# 3. Develop based on verified insights
/ralph-loop "Implement a ReAct-based AI Agent" --max-iterations 20
```

### Workflow 4: Verify → Publish
```bash
# Verify technical insights
/crosscheck "Are React Server Components really better than traditional SSR?"

# Publish verified content
/social-media-publisher "Share today's tech findings to Twitter and Xiaohongshu"
```

### Synergy Matrix

| Combination | Use Case |
|-------------|----------|
| Boris + CrossCheck | Architecture review, tech decisions, code review |
| Boris + Social | Share project updates, document learnings |
| CrossCheck + Social | Verify content accuracy before publishing |
| **All Three** | Trend discovery → Verify → Develop → Re-verify → Publish |

## Project Structure

```
CC-Suite/
├── skills/
│   ├── crosscheck/              # 🛡️ Multi-model verification
│   │   └── SKILL.md
│   ├── social-publisher/        # 📢 Social media automation
│   │   ├── SKILL.md
│   │   ├── scripts/             # check_login.py, content_tracker.py
│   │   └── codex/               # AGENTS.md, login.py
│   └── boris-workflow/          # ⚙️⚡ Boris workflow tools
│       ├── claude-code-setup/   # ⚙️ Environment setup
│       ├── create-subagent/     # ⚡ Subagent creation
│       ├── commands/            # 7 slash commands (init, setup-ralph-loop, etc.)
│       └── templates/           # 14 templates (agents, permissions, plugins)
├── scripts/
│   └── verify.sh                # Installation verification
├── assets/                      # Shared resources
└── install.sh                   # Unified installer
```

## Verify Installation

Run the comprehensive verification script:
```bash
./scripts/verify.sh
```

This checks:
- Installed skills status
- MCP server connections
- Tool names match SKILL.md expectations
- Feature coverage

Manual checks:
```bash
claude mcp list
# codex: codex mcp-server - ✓ Connected
# gemini: npx -y gemini-mcp-tool - ✓ Connected

ls ~/.claude/skills/
# crosscheck  social-publisher  claude-code-setup  create-subagent
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| MCP "Failed to connect" | Run `codex` or `gemini` to login first |
| Skill not available | Restart Claude Code: `/exit` then `claude` |
| Permission denied | Run `chmod +x install.sh` |

## Community

Questions or suggestions? Join our WeChat group:

<table>
  <tr>
    <td align="center">
      <img src="./assets/wechat-group.jpg" width="200" alt="WeChat Group"/>
      <br/>
      <b>Scan to Join Group</b>
    </td>
    <td align="center">
      <img src="./assets/wechat-helper.jpg" width="200" alt="WeChat Helper"/>
      <br/>
      <b>Add Helper if QR Expired</b>
    </td>
  </tr>
</table>

## Related Projects

- [CrossCheck](https://github.com/leiMizzou/CrossCheck) - Standalone multi-model verification
- [SocialPublisher](https://github.com/leiMizzou/SocialPublisher) - Standalone social media automation
- [BorisWorkflow](https://github.com/leiMizzou/BorisWorkflow) - Workflow automation toolkit

## License

MIT
