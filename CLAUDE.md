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

## Ultimate Workflow (5-Phase) Rules

When executing Ultimate Workflow (docs/ULTIMATE_WORKFLOW.md):

### Phase 3: DEVELOP - MANDATORY Ralph Loop

**CRITICAL: Phase 3 MUST use Ralph Loop for autonomous development.**

Before writing ANY code in Phase 3:
1. Run `/setup-ralph-loop --enable` if not already enabled
2. Use `/ralph-loop` command to start autonomous development
3. NEVER manually write code with Edit/Write tools

```bash
# Correct way to develop in Phase 3:
/ralph-loop "
{Task based on CrossCheck conclusions}

Requirements:
1. ...
2. ...

Output <promise>DONE</promise> when complete
" --completion-promise "DONE" --max-iterations 30
```

**Why Ralph Loop is mandatory:**
- Ensures TDD-driven development
- Self-corrects on test failures
- Iterates until acceptance criteria met
- Prevents manual coding shortcuts
