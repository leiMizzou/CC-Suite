# CC Suite

**The Standard Library for Claude Code Workflows**

English | [中文](README.zh-CN.md)

[![Claude Code](https://img.shields.io/badge/Claude_Code-Skills-blueviolet)](https://claude.ai/code)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A curated collection of Claude Code skills that enhance your AI workflow with **Trust**, **Reach**, and **Efficiency**.

## Skills

| Skill | Icon | Description | MCP Dependencies |
|-------|------|-------------|------------------|
| [CrossCheck](skills/crosscheck/) | 🛡️ | Multi-model verification (Claude + Codex + Gemini) | Codex, Gemini |
| [SocialPublisher](skills/social-publisher/) | 📢 | Automated social media publishing | Playwright |
| [ClaudeCodeSetup](skills/claude-code-setup/) | ⚙️ | Claude Code environment configuration | - |
| [CreateSubagent](skills/create-subagent/) | ⚡ | Subagent creation helper | Codex |

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

Combine skills for powerful workflows:

```
# Workflow: Verify → Publish
1. /crosscheck "Analysis of the latest AI trends"
2. /social-media-publisher <verified_content> all
```

## Project Structure

```
CC-Suite/
├── skills/
│   ├── crosscheck/          # 🛡️ Multi-model verification
│   ├── social-publisher/    # 📢 Social media automation
│   ├── claude-code-setup/   # ⚙️ Environment setup
│   └── create-subagent/     # ⚡ Subagent creation
├── assets/                  # Shared resources
├── docs/                    # Documentation
└── install.sh               # Unified installer
```

## Verify Installation

```bash
claude mcp list
# codex: codex mcp-server - ✓ Connected
# gemini: npx -y gemini-mcp-tool - ✓ Connected
```

Check installed skills:
```bash
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
