#!/bin/bash

# CC Suite - Claude Code Suite Installer
# Unified installer for CrossCheck, SocialPublisher, and BorisWorkflow skills

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Version pinning
CODEX_VERSION="0.1"
GEMINI_CLI_VERSION="0.1"
GEMINI_MCP_VERSION="0.1.8"

# Skills directory
SKILLS_DIR="$HOME/.claude/skills"
CC_SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"

# Dependency map: skill -> required MCP servers
declare -A SKILL_DEPS
SKILL_DEPS[crosscheck]="codex gemini"
SKILL_DEPS[social-publisher]="playwright"
SKILL_DEPS[claude-code-setup]=""
SKILL_DEPS[create-subagent]="codex"

# Parse arguments
FORCE=false
SELECTED_SKILLS=()

print_banner() {
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                                                           ║"
    echo "║   ██████╗ ██████╗    ███████╗██╗   ██╗██╗████████╗███████╗║"
    echo "║  ██╔════╝██╔════╝    ██╔════╝██║   ██║██║╚══██╔══╝██╔════╝║"
    echo "║  ██║     ██║         ███████╗██║   ██║██║   ██║   █████╗  ║"
    echo "║  ██║     ██║         ╚════██║██║   ██║██║   ██║   ██╔══╝  ║"
    echo "║  ╚██████╗╚██████╗    ███████║╚██████╔╝██║   ██║   ███████╗║"
    echo "║   ╚═════╝ ╚═════╝    ╚══════╝ ╚═════╝ ╚═╝   ╚═╝   ╚══════╝║"
    echo "║                                                           ║"
    echo "║        Claude Code Suite - Enhance Your AI Workflow       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

usage() {
    echo "Usage: $0 [OPTIONS] [SKILLS...]"
    echo ""
    echo "Options:"
    echo "  --force       Force reinstall CLIs even if already installed"
    echo "  --help        Show this help message"
    echo ""
    echo "Skills (if none specified, installs all):"
    echo "  crosscheck         Multi-model cross verification"
    echo "  social-publisher   Social media automation"
    echo "  claude-code-setup  Claude Code environment setup"
    echo "  create-subagent    Subagent creation helper"
    echo ""
    echo "Examples:"
    echo "  $0                           # Install all skills"
    echo "  $0 crosscheck                # Install only crosscheck"
    echo "  $0 crosscheck social-publisher  # Install selected skills"
    echo "  $0 --force                   # Reinstall everything"
}

check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"

    # Check Claude Code CLI
    if ! command -v claude &> /dev/null; then
        echo -e "${RED}Error: Claude Code CLI is required but not installed.${NC}"
        echo "Install it from: https://claude.ai/code"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Claude Code CLI found"

    # Check Node.js
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}Error: Node.js/npm is required but not installed.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓${NC} Node.js/npm found"
}

install_mcp_server() {
    local server=$1

    case $server in
        codex)
            if $FORCE || ! command -v codex &> /dev/null; then
                echo -e "${YELLOW}Installing Codex CLI v${CODEX_VERSION}...${NC}"
                npm install -g @openai/codex@${CODEX_VERSION}
            else
                echo -e "${GREEN}✓${NC} Codex CLI already installed"
            fi

            # Add MCP server if not exists
            if ! claude mcp list 2>/dev/null | grep -q "codex"; then
                echo -e "${YELLOW}Adding Codex MCP server...${NC}"
                claude mcp add codex -- codex mcp-server
            fi
            ;;

        gemini)
            if $FORCE || ! command -v gemini &> /dev/null; then
                echo -e "${YELLOW}Installing Gemini CLI v${GEMINI_CLI_VERSION}...${NC}"
                npm install -g @google/gemini-cli@${GEMINI_CLI_VERSION}
            else
                echo -e "${GREEN}✓${NC} Gemini CLI already installed"
            fi

            # Add MCP server if not exists
            if ! claude mcp list 2>/dev/null | grep -q "gemini"; then
                echo -e "${YELLOW}Adding Gemini MCP server...${NC}"
                claude mcp add gemini -- npx -y gemini-mcp-tool@${GEMINI_MCP_VERSION}
            fi
            ;;

        playwright)
            # Playwright MCP is typically already available via Claude Code
            if ! claude mcp list 2>/dev/null | grep -q "playwright"; then
                echo -e "${YELLOW}Note: Playwright MCP may need manual setup${NC}"
            else
                echo -e "${GREEN}✓${NC} Playwright MCP available"
            fi
            ;;
    esac
}

install_skill() {
    local skill=$1
    local skill_src="$CC_SUITE_DIR/skills/$skill"
    local skill_dest="$SKILLS_DIR/$skill"

    if [ ! -d "$skill_src" ]; then
        echo -e "${RED}Error: Skill '$skill' not found in $skill_src${NC}"
        return 1
    fi

    echo -e "${BLUE}Installing skill: $skill${NC}"

    # Install dependencies
    local deps="${SKILL_DEPS[$skill]}"
    if [ -n "$deps" ]; then
        for dep in $deps; do
            install_mcp_server "$dep"
        done
    fi

    # Copy skill files
    mkdir -p "$skill_dest"
    cp -r "$skill_src"/* "$skill_dest"/

    echo -e "${GREEN}✓${NC} Skill '$skill' installed to $skill_dest"
}

doctor() {
    echo ""
    echo -e "${BLUE}Running system check...${NC}"
    echo ""

    # Check MCP servers
    echo "MCP Server Status:"
    claude mcp list 2>/dev/null || echo "  (Unable to list MCP servers)"

    echo ""
    echo "Installed Skills:"
    for skill in "${!SKILL_DEPS[@]}"; do
        if [ -d "$SKILLS_DIR/$skill" ]; then
            echo -e "  ${GREEN}✓${NC} $skill"
        fi
    done

    echo ""
    echo -e "${YELLOW}Remember to login to external services:${NC}"
    echo "  codex   # Login to OpenAI (if using crosscheck)"
    echo "  gemini  # Login to Google (if using crosscheck)"
    echo ""
    echo -e "${YELLOW}Restart Claude Code to load new skills:${NC}"
    echo "  /exit"
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            SELECTED_SKILLS+=("$1")
            shift
            ;;
    esac
done

# If no skills specified, install all
if [ ${#SELECTED_SKILLS[@]} -eq 0 ]; then
    SELECTED_SKILLS=(crosscheck social-publisher claude-code-setup create-subagent)
fi

# Main installation
print_banner
check_prerequisites

echo ""
echo -e "${BLUE}Installing skills: ${SELECTED_SKILLS[*]}${NC}"
echo ""

# Calculate unique dependencies
declare -A UNIQUE_DEPS
for skill in "${SELECTED_SKILLS[@]}"; do
    deps="${SKILL_DEPS[$skill]}"
    for dep in $deps; do
        UNIQUE_DEPS[$dep]=1
    done
done

# Install each skill
for skill in "${SELECTED_SKILLS[@]}"; do
    install_skill "$skill"
    echo ""
done

# Run doctor
doctor

echo -e "${GREEN}Installation complete!${NC}"
