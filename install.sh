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

# Directories
SKILLS_DIR="$HOME/.claude/skills"
COMMANDS_DIR="$HOME/.claude/commands"
TEMPLATES_DIR="$HOME/.claude/templates"
CC_SUITE_DIR="$(cd "$(dirname "$0")" && pwd)"
BORIS_DIR="$CC_SUITE_DIR/skills/boris-workflow"
MANIFEST_PARSER="$CC_SUITE_DIR/scripts/parse-manifest.py"

# ============================================================================
# Manifest-driven configuration (Single Source of Truth)
# ============================================================================

# Helper function to call manifest parser
parse_manifest() {
    if [ -f "$MANIFEST_PARSER" ] && command -v python3 &> /dev/null; then
        python3 "$MANIFEST_PARSER" "$@"
    else
        echo ""
    fi
}

# Get all skills from manifest (fallback to hardcoded if parser unavailable)
get_all_skills() {
    local skills
    skills=$(parse_manifest list-skills 2>/dev/null)
    if [ -n "$skills" ]; then
        echo "$skills"
    else
        # Fallback for environments without Python3
        echo "crosscheck social-publisher video-producer claude-code-setup create-subagent"
    fi
}

# Get all commands from manifest
get_all_commands() {
    local commands
    commands=$(parse_manifest list-commands 2>/dev/null)
    if [ -n "$commands" ]; then
        echo "$commands"
    else
        # Fallback
        echo "init add-rule commit-push-pr setup-permissions setup-plugins setup-format-hook setup-ralph-loop"
    fi
}

# Dynamic skill and command lists from manifest
ALL_SKILLS=$(get_all_skills)
BORIS_COMMANDS=$(get_all_commands)

# Version pinning from manifest (with fallbacks)
CODEX_VERSION="0.1"
GEMINI_CLI_VERSION="0.25.1"
GEMINI_MCP_VERSION="1.1.4"

# Try to load versions from manifest
if [ -f "$MANIFEST_PARSER" ] && command -v python3 &> /dev/null; then
    eval "$(parse_manifest get-versions 2>/dev/null)" 2>/dev/null || true
fi

# Global flags
FORCE=false
DRY_RUN=false
SAFE_MODE=false
SKIP_DEPS=false
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
    echo "  --force         Force reinstall CLIs even if already installed"
    echo "  --dry-run       Preview what would be installed without making changes"
    echo "  --safe          Safe mode: skip external dependencies (MCP, npm, pip)"
    echo "  --skip-deps     Skip dependency installation (MCP servers, packages)"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Skills (if none specified, installs all):"
    echo ""
    echo "  Individual skills:"
    echo "    crosscheck         Multi-model cross verification"
    echo "    social-publisher   Social media automation"
    echo "    video-producer     Remotion video generation"
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
    echo "  $0                              # Install all skills"
    echo "  $0 --dry-run                    # Preview installation"
    echo "  $0 --safe                       # Install without dependencies"
    echo "  $0 crosscheck                   # Install only crosscheck"
    echo "  $0 boris-workflow               # Install all Boris workflow skills"
    echo "  $0 crosscheck social-publisher  # Install selected skills"
    echo "  $0 --force                      # Reinstall everything"
}

# Get skill source path (manifest-driven with fallback)
get_skill_path() {
    local skill=$1
    local path

    # Try manifest first
    path=$(parse_manifest get-path "$skill" 2>/dev/null)
    if [ -n "$path" ]; then
        echo "$path"
        return
    fi

    # Fallback for environments without Python3
    case $skill in
        crosscheck)         echo "crosscheck" ;;
        social-publisher)   echo "social-publisher" ;;
        video-producer)     echo "video-producer" ;;
        claude-code-setup)  echo "boris-workflow/claude-code-setup" ;;
        create-subagent)    echo "boris-workflow/create-subagent" ;;
        *)                  echo "" ;;
    esac
}

# Get skill dependencies (manifest-driven with fallback)
get_skill_deps() {
    local skill=$1
    local deps

    # Try manifest first
    deps=$(parse_manifest get-deps "$skill" 2>/dev/null)
    if [ -n "$deps" ] || [ $? -eq 0 ]; then
        echo "$deps"
        return
    fi

    # Fallback for environments without Python3
    case $skill in
        crosscheck)         echo "codex gemini" ;;
        social-publisher)   echo "playwright" ;;
        video-producer)     echo "" ;;
        claude-code-setup)  echo "" ;;
        create-subagent)    echo "codex" ;;
        *)                  echo "" ;;
    esac
}

# Expand skill groups (manifest-driven with fallback)
expand_skill() {
    local skill=$1
    local expanded

    # Try manifest first
    expanded=$(parse_manifest expand-group "$skill" 2>/dev/null)
    if [ -n "$expanded" ]; then
        echo "$expanded"
        return
    fi

    # Fallback for environments without Python3
    case $skill in
        boris-workflow)     echo "claude-code-setup create-subagent" ;;
        *)                  echo "$skill" ;;
    esac
}

# Install Boris workflow commands
install_boris_commands() {
    echo -e "${BLUE}Installing Boris workflow commands...${NC}"

    if $DRY_RUN; then
        for cmd in $BORIS_COMMANDS; do
            local src="$BORIS_DIR/commands/${cmd}.md"
            if [ -f "$src" ]; then
                echo -e "  ${YELLOW}[DRY RUN] Would install: /$cmd${NC}"
            fi
        done
        return 0
    fi

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

    if $DRY_RUN; then
        echo -e "  ${YELLOW}[DRY RUN] Would install: CLAUDE.md template${NC}"
        echo -e "  ${YELLOW}[DRY RUN] Would install: settings.json template${NC}"
        echo -e "  ${YELLOW}[DRY RUN] Would install: agents/ (4 templates)${NC}"
        echo -e "  ${YELLOW}[DRY RUN] Would install: permissions/ (3 presets)${NC}"
        echo -e "  ${YELLOW}[DRY RUN] Would install: plugins/ (5 presets)${NC}"
        return 0
    fi

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
    local venv_dir="$skill_dest/venv"

    if [ -f "$requirements" ]; then
        echo -e "${BLUE}Installing social-publisher Python dependencies...${NC}"

        if $DRY_RUN; then
            echo -e "${YELLOW}  [DRY RUN] Would create venv at: $venv_dir${NC}"
            echo -e "${YELLOW}  [DRY RUN] Would install: $requirements${NC}"
            echo -e "${YELLOW}  [DRY RUN] Would install Playwright chromium browser${NC}"
            return 0
        fi

        if $SKIP_DEPS; then
            echo -e "${YELLOW}  Skipping Python dependencies (--skip-deps or --safe mode)${NC}"
            return 0
        fi

        # Check Python3
        if ! command -v python3 &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} Python3 not found. Please install Python 3.8+ manually."
            return 1
        fi

        # Create virtual environment
        if [ ! -d "$venv_dir" ]; then
            echo -e "${BLUE}Creating Python virtual environment...${NC}"
            if python3 -m venv "$venv_dir" 2>/dev/null; then
                echo -e "${GREEN}✓${NC} Virtual environment created at: $venv_dir"
            else
                echo -e "${YELLOW}⚠${NC} Failed to create venv, using global pip"
                venv_dir=""
            fi
        else
            echo -e "${GREEN}✓${NC} Virtual environment already exists"
        fi

        # Determine pip command
        local pip_cmd="python3 -m pip"
        if [ -n "$venv_dir" ]; then
            pip_cmd="$venv_dir/bin/pip"
        fi

        # Install requirements
        if $pip_cmd install -r "$requirements" --quiet 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Python dependencies installed"
        else
            echo -e "${YELLOW}⚠${NC} Failed to install Python dependencies"
            echo "  Run manually: $pip_cmd install -r $requirements"
        fi

        # Install Playwright browsers
        echo -e "${BLUE}Installing Playwright browsers...${NC}"
        local playwright_cmd="python3 -m playwright"
        if [ -n "$venv_dir" ]; then
            playwright_cmd="$venv_dir/bin/python -m playwright"
        fi

        if $playwright_cmd install chromium 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Playwright chromium browser installed"
        else
            echo -e "${YELLOW}⚠${NC} Failed to install Playwright browsers"
            echo "  Run manually: $playwright_cmd install chromium"
        fi

        # Create activation helper script
        if [ -n "$venv_dir" ]; then
            cat > "$skill_dest/activate.sh" <<'EOF'
#!/bin/bash
# Activate social-publisher virtual environment
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/venv/bin/activate"
echo "✓ social-publisher venv activated"
echo "  Python: $(which python)"
echo "  To deactivate: deactivate"
EOF
            chmod +x "$skill_dest/activate.sh"
            echo -e "${GREEN}✓${NC} Activation script: $skill_dest/activate.sh"
        fi

        # Make scripts executable
        chmod +x "$skill_dest/scripts/"*.py 2>/dev/null || true
        chmod +x "$skill_dest/scripts/"*.sh 2>/dev/null || true
        chmod +x "$skill_dest/codex/"*.sh 2>/dev/null || true

        echo -e "${GREEN}✓${NC} Scripts ready at: $skill_dest/scripts/"
        if [ -n "$venv_dir" ]; then
            echo -e "${BLUE}Note:${NC} To use scripts, activate venv first:"
            echo "  source $skill_dest/activate.sh"
        fi
    fi
}

# Install video-producer Node.js dependencies
install_video_producer_deps() {
    local skill_dest="$SKILLS_DIR/video-producer"
    local package_json="$skill_dest/package.json"

    if [ -f "$package_json" ]; then
        echo -e "${BLUE}Installing video-producer Node.js dependencies...${NC}"

        if $DRY_RUN; then
            echo -e "${YELLOW}  [DRY RUN] Would run: npm install in $skill_dest${NC}"
            return 0
        fi

        if $SKIP_DEPS; then
            echo -e "${YELLOW}  Skipping Node.js dependencies (--skip-deps or --safe mode)${NC}"
            return 0
        fi

        # Check npm
        if ! command -v npm &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} npm not found. Please install Node.js manually."
            return 1
        fi

        # Install dependencies
        cd "$skill_dest"
        if npm install --silent 2>/dev/null; then
            echo -e "${GREEN}✓${NC} Node.js dependencies installed"
        else
            echo -e "${YELLOW}⚠${NC} Failed to install Node.js dependencies"
            echo "  Run manually: cd $skill_dest && npm install"
        fi
        cd - > /dev/null

        echo -e "${GREEN}✓${NC} video-producer ready at: $skill_dest"
    fi
}

check_prerequisites() {
    echo -e "${BLUE}Checking prerequisites...${NC}"

    # Check Claude Code CLI (also check common install paths if not in PATH)
    if ! command -v claude &> /dev/null; then
        # Try common installation paths
        local claude_paths=(
            "$HOME/.local/bin/claude"
            "$HOME/.claude/bin/claude"
            "/usr/local/bin/claude"
        )
        local found_claude=""
        for path in "${claude_paths[@]}"; do
            if [ -x "$path" ]; then
                found_claude="$path"
                export PATH="$(dirname "$path"):$PATH"
                echo -e "${YELLOW}Note: Added $(dirname "$path") to PATH${NC}"
                break
            fi
        done

        if [ -z "$found_claude" ]; then
            echo -e "${RED}Error: Claude Code CLI is required but not installed.${NC}"
            echo "Install it from: https://claude.ai/code"
            exit 1
        fi
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

    if $DRY_RUN; then
        echo -e "${YELLOW}  [DRY RUN] Would install MCP server: $server${NC}"
        return 0
    fi

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
    if ! $SKIP_DEPS; then
        local deps=$(get_skill_deps "$skill")
        if [ -n "$deps" ]; then
            for dep in $deps; do
                install_mcp_server "$dep"
            done
        fi
    else
        echo -e "${YELLOW}  Skipping dependencies (--skip-deps or --safe mode)${NC}"
    fi

    # Copy skill files
    if $DRY_RUN; then
        echo -e "${YELLOW}  [DRY RUN] Would copy: $skill_src -> $skill_dest${NC}"
    else
        mkdir -p "$skill_dest"
        cp -r "$skill_src"/* "$skill_dest"/
        echo -e "${GREEN}✓${NC} Skill '$skill' installed to $skill_dest"
    fi
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

        # Check venv
        if [ -d "$SKILLS_DIR/social-publisher/venv" ]; then
            echo -e "  ${GREEN}✓${NC} Python venv (isolated environment)"
            echo "    Activate: source $SKILLS_DIR/social-publisher/activate.sh"
        else
            echo -e "  ${YELLOW}⚠${NC} No venv (using global Python)"
        fi
    fi

    # Check video-producer
    if [ -d "$SKILLS_DIR/video-producer" ]; then
        echo ""
        echo "Video Producer Status:"
        if [ -d "$SKILLS_DIR/video-producer/node_modules" ]; then
            echo -e "  ${GREEN}✓${NC} Node.js dependencies installed"
        else
            echo -e "  ${YELLOW}⚠${NC} Node.js dependencies not installed"
        fi
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
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --safe)
            SAFE_MODE=true
            SKIP_DEPS=true
            shift
            ;;
        --skip-deps)
            SKIP_DEPS=true
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

# Show mode information
if $DRY_RUN; then
    echo -e "${YELLOW}"
    echo "========================================"
    echo "         DRY RUN MODE (Preview)"
    echo "========================================"
    echo "No changes will be made to your system"
    echo -e "${NC}"
fi

if $SAFE_MODE; then
    echo -e "${YELLOW}"
    echo "========================================"
    echo "         SAFE MODE (No Dependencies)"
    echo "========================================"
    echo "Skills will be installed without:"
    echo "  - MCP server installation"
    echo "  - npm package installation"
    echo "  - pip package installation"
    echo -e "${NC}"
elif $SKIP_DEPS; then
    echo -e "${YELLOW}"
    echo "Skipping all dependency installation"
    echo -e "${NC}"
fi

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

# Install video-producer dependencies if selected
if echo "$EXPANDED_SKILLS" | grep -q "video-producer"; then
    echo ""
    install_video_producer_deps
    echo ""
fi

# Run doctor
if ! $DRY_RUN; then
    doctor
fi

if $DRY_RUN; then
    echo ""
    echo -e "${YELLOW}========================================"
    echo "         DRY RUN COMPLETE"
    echo "========================================${NC}"
    echo "No changes were made."
    echo "Run without --dry-run to actually install."
else
    echo -e "${GREEN}Installation complete!${NC}"
fi
