# CC Suite - Project Guidelines

## Project Overview

CC Suite (Claude Code Suite) is a collection of Claude Code skills for enhanced AI workflows:
- **crosscheck**: Multi-model verification (Claude + Codex + Gemini)
- **social-publisher**: Social media automation
- **boris-workflow**: Development environment tools (claude-code-setup + create-subagent)

## Development Workflow

### Shell Commands
```bash
# Test installation script
./install.sh --help
./install.sh crosscheck        # Install single skill
./install.sh boris-workflow    # Install skill group

# Check installed skills
ls ~/.claude/skills/
```

### Code Standards
- Shell scripts must be compatible with bash 3.2+ (macOS default)
- No associative arrays (`declare -A`) - use case statements instead
- All scripts must have `set -e` for fail-fast behavior

### Skill Development
- Each skill has a `SKILL.md` file defining its behavior
- Skills are installed to `~/.claude/skills/<skill-name>/`
- MCP dependencies are defined per-skill in install.sh

## Prohibited Actions
- Do not use bash 4+ features (breaks on macOS)
- Do not hardcode paths (use variables)
- Do not skip error handling in shell scripts

## Known Issues & Solutions

| Issue | Solution |
|-------|----------|
| `declare -A` fails on macOS | Use case statements instead |
| MCP server not connecting | Run `codex` or `gemini` to login first |
| Skill not loading | Restart Claude Code with `/exit` |

## Testing Checklist
- [ ] `./install.sh --help` shows usage
- [ ] `./install.sh` installs all 4 skills
- [ ] `./install.sh boris-workflow` installs 2 skills
- [ ] Skills appear in `~/.claude/skills/`
