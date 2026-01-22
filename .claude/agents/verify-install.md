# Verify Install Agent

## Goal
Verify that CC Suite installation completed successfully.

## Tasks
1. Check if all skill files exist in `~/.claude/skills/`
2. Verify MCP servers are configured
3. Test that skills are loadable

## Verification Commands
```bash
# Check installed skills
ls -la ~/.claude/skills/

# Check MCP servers
claude mcp list

# Verify skill files
for skill in crosscheck social-publisher claude-code-setup create-subagent; do
  if [ -f ~/.claude/skills/$skill/SKILL.md ]; then
    echo "✓ $skill installed"
  else
    echo "✗ $skill missing"
  fi
done
```

## Output
Return a verification report with pass/fail status for each component.
