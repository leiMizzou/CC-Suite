#!/bin/bash

# CC Suite Verification Script
# Performs critical checks that shouldn't rely on LLM instructions
# Compatible with bash 3.2+ (macOS default)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SKILLS_DIR="$HOME/.claude/skills"

# Expected MCP tool names used in SKILL.md files
EXPECTED_TOOLS="mcp__codex__codex mcp__gemini__ask-gemini"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     CC Suite Verification Report       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# 1. Check Skills Installation
echo -e "${BLUE}[1/4] Checking Installed Skills${NC}"
echo "────────────────────────────────"

ALL_SKILLS="crosscheck social-publisher video-producer claude-code-setup create-subagent"
installed_count=0
total_count=0

for skill in $ALL_SKILLS; do
    total_count=$((total_count + 1))
    if [ -d "$SKILLS_DIR/$skill" ]; then
        if [ -f "$SKILLS_DIR/$skill/SKILL.md" ]; then
            echo -e "  ${GREEN}✓${NC} $skill"
            installed_count=$((installed_count + 1))
        else
            echo -e "  ${YELLOW}⚠${NC} $skill (directory exists but SKILL.md missing)"
        fi
    else
        echo -e "  ${RED}✗${NC} $skill (not installed)"
    fi
done

echo ""
echo "  Installed: $installed_count/$total_count skills"
echo ""

# 2. Check MCP Server Configuration
echo -e "${BLUE}[2/4] Checking MCP Server Configuration${NC}"
echo "────────────────────────────────────────"

mcp_output=$(claude mcp list 2>/dev/null || echo "FAILED")

if [ "$mcp_output" = "FAILED" ]; then
    echo -e "  ${RED}✗${NC} Unable to query MCP servers"
    echo "    Make sure Claude Code CLI is installed and configured"
else
    # Check codex
    if echo "$mcp_output" | grep -q "codex.*Connected"; then
        echo -e "  ${GREEN}✓${NC} codex MCP server: Connected"
    elif echo "$mcp_output" | grep -q "codex"; then
        echo -e "  ${YELLOW}⚠${NC} codex MCP server: Configured but not connected"
        echo "    → Run 'codex' to login"
    else
        echo -e "  ${RED}✗${NC} codex MCP server: Not configured"
    fi

    # Check gemini
    if echo "$mcp_output" | grep -q "gemini.*Connected"; then
        echo -e "  ${GREEN}✓${NC} gemini MCP server: Connected"
    elif echo "$mcp_output" | grep -q "gemini"; then
        echo -e "  ${YELLOW}⚠${NC} gemini MCP server: Configured but not connected"
        echo "    → Run 'gemini' to login"
    else
        echo -e "  ${RED}✗${NC} gemini MCP server: Not configured"
    fi

    # Check playwright
    if echo "$mcp_output" | grep -q "playwright.*Connected"; then
        echo -e "  ${GREEN}✓${NC} playwright MCP server: Connected"
    elif echo "$mcp_output" | grep -q "playwright"; then
        echo -e "  ${YELLOW}⚠${NC} playwright MCP server: Configured but not connected"
    fi
fi

echo ""

# 3. Verify Expected Tool Names in SKILL.md
echo -e "${BLUE}[3/4] Verifying Tool Names in SKILL.md${NC}"
echo "───────────────────────────────────────"

# Check crosscheck skill for expected tool calls
if [ -f "$SKILLS_DIR/crosscheck/SKILL.md" ]; then
    skill_content=$(cat "$SKILLS_DIR/crosscheck/SKILL.md")

    if echo "$skill_content" | grep -q "mcp__codex__codex"; then
        echo -e "  ${GREEN}✓${NC} crosscheck uses mcp__codex__codex"
    else
        echo -e "  ${RED}✗${NC} crosscheck missing mcp__codex__codex call"
    fi

    if echo "$skill_content" | grep -q "mcp__gemini__ask-gemini"; then
        echo -e "  ${GREEN}✓${NC} crosscheck uses mcp__gemini__ask-gemini"
    else
        echo -e "  ${RED}✗${NC} crosscheck missing mcp__gemini__ask-gemini call"
    fi
else
    echo -e "  ${YELLOW}⚠${NC} crosscheck skill not installed, skipping tool verification"
fi

echo ""

# 4. Feature Coverage Check
echo -e "${BLUE}[4/4] Feature Coverage Check${NC}"
echo "─────────────────────────────"

CC_SUITE_DIR="$(cd "$(dirname "$0")/.." && pwd)"

coverage_pass=true
for skill_path in \
    "skills/crosscheck/SKILL.md" \
    "skills/social-publisher/SKILL.md" \
    "skills/boris-workflow/claude-code-setup/SKILL.md" \
    "skills/boris-workflow/create-subagent/SKILL.md"; do

    if [ -f "$CC_SUITE_DIR/$skill_path" ]; then
        echo -e "  ${GREEN}✓${NC} $skill_path"
    else
        echo -e "  ${RED}✗${NC} $skill_path MISSING"
        coverage_pass=false
    fi
done

echo ""

# Summary
echo -e "${BLUE}════════════════════════════════════════${NC}"
if [ "$installed_count" -eq "$total_count" ] && $coverage_pass; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠ Some checks need attention.${NC}"
    echo "  Run './install.sh' to install missing components."
    exit 1
fi
