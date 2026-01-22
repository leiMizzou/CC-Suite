#!/bin/bash

# CC Suite - Claude Code Suite Installer
# Unified installer for CrossCheck, SocialPublisher, and BorisWorkflow skills
# Compatible with bash 3.2+ (macOS default)

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
GEMINI_MCP_VERSION="1.1.4"

# Directories
SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"
TEMPLATES_DIR="$HOME/.claude/templates"
CC_SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"
BORIS_DIR="$CC_SUITE_DIR/skills/boris-workflow"

# All available skills
ALL_SKILLS="crosscheck social-publisher claude-code-setup create-subagent"

# Boris workflow commands (installed to ~/.claude/commands/)
BORIS_COMMANDS="init add-rule commit-push-pr setup-permissions setup-plugins setup-format-hook setup-ralph-loop"

# Parse arguments
FORCE=false
SELECTED_SKILLS=""

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
    echo ""
    echo "  Individual skills:"
    echo "    crosscheck         Multi-model cross verification"
    echo "    social-publisher   Social media automation"
    echo "    claude-code-setup  Claude Code environment setup"
    echo "    create-subagent    Subagent creation helper"
    echo ""
    echo "  Skill groups:"
    echo "    boris-workflow     Complete Boris workflow (skills + commands + templates)"
    echo "                       - Skills: claude-code-setup, create-subagent"
    echo "                       - Commands: init, setup-permissions, setup-plugins, etc."
    echo "                       - Templates: agents, permissions, plugins presets"
    echo ""
    echo "Examples:"
    echo "  $0                           # Install all skills"
    echo "  $0 crosscheck                # Install only crosscheck"
    echo "  $0 boris-workflow            # Install all Boris workflow skills"
    echo "  $0 crosscheck social-publisher  # Install selected skills"
    echo "  $0 --force                   # Reinstall everything"
}

# Get skill source path
get_skill_path() {
    local skill=$1
    case $skill in
        crosscheck)         echo "crosscheck" ;;
        social-publisher)   echo "social-publisher" ;;
        claude-code-setup)  echo "boris-workflow/claude-code-setup" ;;
        create-subagent)    echo "boris-workflow/create-subagent" ;;
        *)                  echo "" ;;
    esac
}

# Get skill dependencies
get_skill_deps() {
    local skill=$1
    case $skill in
        crosscheck)         echo "codex gemini" ;;
        social-publisher)   echo "playwright" ;;
        claude-code-setup)  echo "" ;;
        create-subagent)    echo "codex" ;;
        *)                  echo "" ;;
    esac
}

# Expand skill groups
expand_skill() {
    local skill=$1
    case $skill in
        boris-workflow)     echo "claude-code-setup create-subagent" ;;
        *)                  echo "$skill" ;;
    esac
}

# Install Boris workflow commands
install_boris_commands() {
    echo -e "${BLUE}Installing Boris workflow commands...${NC}"

    mkdir -p "$COMMANDS_DIR"

    for cmd in $BORIS_COMMANDS; do
        local src="$BORIS_DIR/commands/${cmd}.md"
        if [ -f "$src" ]; then
            cp "$src" "$COMMANDS_DIR/"
            echo -e "  ${GREEN}✓${NC} $cmd"
        fi
    done
}

# Install Boris workflow templates
install_boris_templates() {
    echo -e "${BLUE}Installing Boris workflow templates...${NC}"

    mkdir -p "$TEMPLATES_DIR"

    # Copy all templates
    if [ -d "$BORIS_DIR/templates" ]; then
        cp -r "$BORIS_DIR/templates"/* "$TEMPLATES_DIR/"
        echo -e "  ${GREEN}✓${NC} CLAUDE.md template"
        echo -e "  ${GREEN}✓${NC} settings.json template"
        echo -e "  ${GREEN}✓${NC} agents/ (4 templates)"
        echo -e "  ${GREEN}✓${NC} permissions/ (3 presets)"
        echo -e "  ${GREEN}✓${NC} plugins/ (5 presets)"
    fi
}

# Install social-publisher Python dependencies
install_social_publisher_deps() {
    local skill_dest="$SKILLS_DIR/social-publisher"
    local requirements="$skill_dest/requirements.txt"

    if [ -f "$requirements" ]; then
        echo -e "${BLUE}Installing social-publisher Python dependencies...${NC}"

        # Check Python3
        if ! command -v python3 &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} Python3 not found. Please install Python 3.8+ manually."
            return 1
        fi

        # Install requirements
        if python3 -m pip install -r "$requirements" --quiet 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Python dependencies installed"
        else
            echo -e "${YELLOW}⚠${NC} Failed to install Python dependencies"
            echo "  Run manually: pip install -r $requirements"
        fi

        # Make scripts executable
        chmod +x "$skill_dest/scripts/"*.py 2>/dev/null || true
        chmod +x "$skill_dest/scripts/"*.sh 2>/dev/null || true
        chmod +x "$skill_dest/codex/"*.sh 2>/dev/null || true

        echo -e "${GREEN}✓${NC} Scripts ready at: $skill_dest/scripts/"
    fi
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
    local skill_path=$(get_skill_path "$skill")
    local skill_src="$CC_SUITE_DIR/skills/$skill_path"
    local skill_dest="$SKILLS_DIR/$skill"

    if [ -z "$skill_path" ]; then
        echo -e "${RED}Error: Unknown skill '$skill'${NC}"
        return 1
    fi

    if [ ! -d "$skill_src" ]; then
        echo -e "${RED}Error: Skill '$skill' not found in $skill_src${NC}"
        return 1
    fi

    echo -e "${BLUE}Installing skill: $skill${NC}"

    # Install dependencies
    local deps=$(get_skill_deps "$skill")
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

verify_mcp_tools() {
    echo ""
    echo -e "${BLUE}Verifying MCP tool availability...${NC}"
    echo ""

    local mcp_output=$(claude mcp list 2>/dev/null)
    local has_errors=false

    # Expected tool names used in SKILL.md files
    # crosscheck uses: mcp__codex__codex, mcp__gemini__ask-gemini
    # create-subagent uses: mcp__codex__codex

    # Check codex MCP
    if echo "$mcp_output" | grep -q "codex.*Connected"; then
        echo -e "${GREEN}✓${NC} codex MCP server connected"
        echo "  Expected tool: mcp__codex__codex"
    elif echo "$mcp_output" | grep -q "codex"; then
        echo -e "${YELLOW}⚠${NC} codex MCP server configured but not connected"
        echo "  Run 'codex' to login first"
        has_errors=true
    else
        echo -e "${RED}✗${NC} codex MCP server not configured"
        has_errors=true
    fi

    # Check gemini MCP
    if echo "$mcp_output" | grep -q "gemini.*Connected"; then
        echo -e "${GREEN}✓${NC} gemini MCP server connected"
        echo "  Expected tool: mcp__gemini__ask-gemini"
    elif echo "$mcp_output" | grep -q "gemini"; then
        echo -e "${YELLOW}⚠${NC} gemini MCP server configured but not connected"
        echo "  Run 'gemini' to login first"
        has_errors=true
    else
        echo -e "${RED}✗${NC} gemini MCP server not configured"
        has_errors=true
    fi

    # Check playwright MCP
    if echo "$mcp_output" | grep -q "playwright.*Connected"; then
        echo -e "${GREEN}✓${NC} playwright MCP server connected"
    elif echo "$mcp_output" | grep -q "playwright"; then
        echo -e "${YELLOW}⚠${NC} playwright MCP server configured but not connected"
    fi

    if $has_errors; then
        echo ""
        echo -e "${YELLOW}Note: Some MCP servers need authentication.${NC}"
        echo "After logging in, restart Claude Code with /exit"
    fi
}

doctor() {
    echo ""
    echo -e "${BLUE}Running system check...${NC}"
    echo ""

    # Check MCP servers
    echo "MCP Server Status:"
    claude mcp list 2>/dev/null || echo "  (Unable to list MCP servers)"

    # Verify MCP tool names match SKILL.md expectations
    verify_mcp_tools

    echo ""
    echo "Installed Skills:"
    for skill in $ALL_SKILLS; do
        if [ -d "$SKILLS_DIR/$skill" ]; then
            echo -e "  ${GREEN}✓${NC} $skill"
        fi
    done

    echo ""
    echo "Installed Commands:"
    for cmd in $BORIS_COMMANDS; do
        if [ -f "$COMMANDS_DIR/${cmd}.md" ]; then
            echo -e "  ${GREEN}✓${NC} /$cmd"
        fi
    done

    echo ""
    echo "Installed Templates:"
    if [ -d "$TEMPLATES_DIR" ]; then
        [ -f "$TEMPLATES_DIR/CLAUDE.md" ] && echo -e "  ${GREEN}✓${NC} CLAUDE.md"
        [ -f "$TEMPLATES_DIR/settings.json" ] && echo -e "  ${GREEN}✓${NC} settings.json"
        [ -d "$TEMPLATES_DIR/agents" ] && echo -e "  ${GREEN}✓${NC} agents/ ($(ls "$TEMPLATES_DIR/agents" 2>/dev/null | wc -l | tr -d ' ') templates)"
        [ -d "$TEMPLATES_DIR/permissions" ] && echo -e "  ${GREEN}✓${NC} permissions/ ($(ls "$TEMPLATES_DIR/permissions" 2>/dev/null | wc -l | tr -d ' ') presets)"
        [ -d "$TEMPLATES_DIR/plugins" ] && echo -e "  ${GREEN}✓${NC} plugins/ ($(ls "$TEMPLATES_DIR/plugins" 2>/dev/null | wc -l | tr -d ' ') presets)"
    fi

    # Check social-publisher scripts
    if [ -d "$SKILLS_DIR/social-publisher/scripts" ]; then
        echo ""
        echo "Social Publisher Scripts:"
        [ -f "$SKILLS_DIR/social-publisher/scripts/check_login.py" ] && echo -e "  ${GREEN}✓${NC} check_login.py"
        [ -f "$SKILLS_DIR/social-publisher/scripts/content_tracker.py" ] && echo -e "  ${GREEN}✓${NC} content_tracker.py"
        [ -f "$SKILLS_DIR/social-publisher/scripts/publish.sh" ] && echo -e "  ${GREEN}✓${NC} publish.sh"
    fi

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
            SELECTED_SKILLS="$SELECTED_SKILLS $1"
            shift
            ;;
    esac
done

# Trim leading space
SELECTED_SKILLS=$(echo "$SELECTED_SKILLS" | sed 's/^ *//')

# If no skills specified, install all
if [ -z "$SELECTED_SKILLS" ]; then
    SELECTED_SKILLS="$ALL_SKILLS"
fi

# Expand skill groups and remove duplicates
EXPANDED_SKILLS=""
for skill in $SELECTED_SKILLS; do
    expanded=$(expand_skill "$skill")
    for s in $expanded; do
        # Check if already in list
        if ! echo "$EXPANDED_SKILLS" | grep -q "\b$s\b"; then
            EXPANDED_SKILLS="$EXPANDED_SKILLS $s"
        fi
    done
done
EXPANDED_SKILLS=$(echo "$EXPANDED_SKILLS" | sed 's/^ *//')

# Main installation
print_banner
check_prerequisites

echo ""
echo -e "${BLUE}Installing skills: ${EXPANDED_SKILLS}${NC}"
echo ""

# Install each skill
for skill in $EXPANDED_SKILLS; do
    install_skill "$skill"
    echo ""
done

# Install Boris workflow commands and templates if any Boris skill is selected
if echo "$EXPANDED_SKILLS" | grep -q "claude-code-setup\|create-subagent"; then
    echo ""
    install_boris_commands
    echo ""
    install_boris_templates
    echo ""
fi

# Install social-publisher dependencies if selected
if echo "$EXPANDED_SKILLS" | grep -q "social-publisher"; then
    echo ""
    install_social_publisher_deps
    echo ""
fi

# Run doctor
doctor

echo -e "${GREEN}Installation complete!${NC}"
