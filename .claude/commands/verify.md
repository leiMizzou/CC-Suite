# /verify

Verify CC Suite installation status.

## Steps
1. Check skill directories exist
2. Check MCP server connections
3. Report installation status

## Commands
```bash
echo "=== CC Suite Installation Status ==="
echo ""
echo "Installed Skills:"
for skill in crosscheck social-publisher claude-code-setup create-subagent; do
  if [ -d ~/.claude/skills/$skill ]; then
    echo "  ✓ $skill"
  else
    echo "  ✗ $skill (not installed)"
  fi
done
echo ""
echo "MCP Servers:"
claude mcp list 2>/dev/null | grep -E "(codex|gemini|playwright)" || echo "  (run claude mcp list to check)"
```
