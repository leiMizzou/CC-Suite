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

## Advanced Features

### 🔒 Safe Installation Modes

```bash
# Preview what would be installed (no changes made)
./install.sh --dry-run crosscheck

# Safe mode: skip all external dependencies
./install.sh --safe social-publisher

# Skip only dependency installation
./install.sh --skip-deps crosscheck
```

### 🐍 Python Virtual Environment

Automatic isolated Python environments for each skill:

```bash
# After installing social-publisher
source ~/.claude/skills/social-publisher/activate.sh

# Your Python packages are now isolated
# No version conflicts with system Python
```

### ✅ Quality Assurance

```bash
# Run all tests
./tests/run_all_tests.sh

# Validate manifest.json
python3 scripts/validate-manifest.py

# Install git hooks for automatic validation
./scripts/install-hooks.sh
```

### 📋 Manifest-Driven Architecture

All skills are defined in `skills/manifest.json` as the **single source of truth**:
- Skill metadata, paths, and dependencies
- Command and template mappings
- MCP server configurations with version pinning

The installer dynamically reads from the manifest:
```bash
# Manifest parser (used by install.sh)
python3 scripts/parse-manifest.py list-skills
python3 scripts/parse-manifest.py get-deps crosscheck
```

## Usage Examples

### 🛡️ CrossCheck - Multi-Model Verification

Reduce AI hallucinations through 3-round cross-verification:

```
/crosscheck Is microservices the right architecture for this project?
/crosscheck What's the best approach for real-time collaboration?
```

**Safe Mode** - For security-sensitive reviews:
```
/crosscheck --safe Review this production code for vulnerabilities
/crosscheck --safe Analyze this authentication flow for issues
```
> `--safe` uses restricted Codex access: `sandbox=read-only`, `approval-policy=on-failure`

### 📢 SocialPublisher - Social Media Automation

One-click publish to multiple platforms:

```
/social-publisher "Today's AI highlights" xiaohongshu wechat
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
/setup-plugins --preset {PRESET}         # Configure MCP plugins (web-dev, full, etc.)
/create-subagent {AGENT_NAME}            # Create project-specific agents
```

### Workflow 2: Autonomous Development + Verification
```bash
/setup-ralph-loop --enable               # Enable Ralph Loop

/ralph-loop "{TASK_DESCRIPTION}, output <promise>DONE</promise> when complete" \
  --max-iterations 30                    # Autonomous iteration

/crosscheck "{OPTION_A} vs {OPTION_B} - which is better for this use case?"
```

### Workflow 3: Trend Research → Development
```bash
# 1. Search trending discussions
/social-publisher "Search 10 hottest {TOPIC} posts today, no engagement"

# 2. Verify a popular claim
/crosscheck "{VERIFY_CLAIM_FROM_DISCOVERY}"

# 3. Develop based on verified insights
/ralph-loop "{IMPLEMENT_BASED_ON_VERIFICATION}" --max-iterations 20
```

### Workflow 4: Verify → Publish
```bash
# Verify technical insights
/crosscheck "{TECHNICAL_QUESTION}"

# Publish verified content
/social-publisher "Share {TOPIC} findings to Twitter and Xiaohongshu"
```

### Synergy Matrix

| Combination | Use Case |
|-------------|----------|
| Boris + CrossCheck | Architecture review, tech decisions, code review |
| Boris + Social | Share project updates, document learnings |
| CrossCheck + Social | Verify content accuracy before publishing |
| **All Three** | Trend discovery → Verify → Develop → Re-verify → Publish |

### Workflow 5: Ultimate - Full Closed Loop

> **[Complete Guide: docs/ULTIMATE_WORKFLOW.md](docs/ULTIMATE_WORKFLOW.md)**

```bash
# Phase 1: DISCOVER - Find trending discussions
/social-publisher "Search 15 hottest {TOPIC} posts today, no engagement"

# Phase 2: VERIFY - Validate technical direction
/crosscheck "{TECHNICAL_QUESTION_FROM_DISCOVERY}"

# Phase 3: DEVELOP - Autonomous iteration with TDD
/ralph-loop "{TASK_BASED_ON_VERIFIED_CONCLUSIONS}" \
  --completion-promise "DONE" --max-iterations 40

# Phase 4: RE-VERIFY - Validate code quality
/crosscheck "Review this implementation for issues and best practices"

# Phase 5: PUBLISH - Multi-platform distribution
/social-publisher "Publish development insights to all platforms"
```

```
   DISCOVER          VERIFY           DEVELOP         RE-VERIFY         PUBLISH
   ─────────────────────────────────────────────────────────────────────────────
   SocialPublisher → CrossCheck  →   Ralph Loop   →  CrossCheck   →  SocialPublisher
   (Search trends)   (Validate)      (Build + TDD)   (Code review)    (Distribute)
```

## Project Structure

```
CC-Suite/
├── skills/
│   ├── manifest.json            # 📋 Single source of truth for all skills
│   ├── crosscheck/              # 🛡️ Multi-model verification (--safe mode)
│   │   └── SKILL.md
│   ├── social-publisher/        # 📢 Social media automation
│   │   ├── SKILL.md
│   │   ├── scripts/             # check_login.py, content_tracker.py (atomic writes)
│   │   └── codex/               # AGENTS.md, login.py
│   ├── video-producer/          # 🎬 Remotion video generation
│   │   └── SKILL.md
│   └── boris-workflow/          # ⚙️⚡ Boris workflow tools
│       ├── claude-code-setup/   # ⚙️ Environment setup
│       ├── create-subagent/     # ⚡ Subagent creation
│       ├── commands/            # 7 slash commands (init, setup-ralph-loop, etc.)
│       └── templates/           # 14 templates (agents, permissions, plugins)
├── scripts/
│   ├── parse-manifest.py        # Manifest parser for install.sh
│   └── verify.sh                # Installation verification
├── tests/
│   ├── unit/                    # Unit tests
│   └── integration/             # Integration & E2E tests
├── .github/workflows/           # CI/CD pipelines
└── install.sh                   # Manifest-driven installer
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
