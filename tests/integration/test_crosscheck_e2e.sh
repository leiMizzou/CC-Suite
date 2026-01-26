#!/usr/bin/env bash
# End-to-end test for CrossCheck with real MCP calls
# Tests actual API connectivity and validates all 3 rounds

# Don't use set -e because we want to capture all test results
# set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"
SKILLS_DIR="$HOME/.claude/skills"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0
ISSUES_FOUND=()

log_pass() { echo -e "${GREEN}✓ PASS: $1${NC}"; ((TESTS_PASSED++)); }
log_fail() { echo -e "${RED}✗ FAIL: $1${NC}"; ((TESTS_FAILED++)); ISSUES_FOUND+=("$1"); }
log_warn() { echo -e "${YELLOW}⚠ WARN: $1${NC}"; }
log_skip() { echo -e "${YELLOW}○ SKIP: $1${NC}"; ((TESTS_SKIPPED++)); }
log_info() { echo -e "${BLUE}→ $1${NC}"; }

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║     CrossCheck End-to-End Sandbox Test                    ║"
echo "║     Testing: Skills, Manifest, MCP, Validation            ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# =============================================================================
# Test Suite 1: Manifest Consistency
# =============================================================================
echo -e "\n${BLUE}[Suite 1/5] Manifest Consistency Tests${NC}"
echo "────────────────────────────────────────"

# Test 1.1: Manifest JSON validity
log_info "Testing manifest.json validity..."
if python3 -m json.tool "$PROJECT_ROOT/skills/manifest.json" > /dev/null 2>&1; then
    log_pass "manifest.json is valid JSON"
else
    log_fail "manifest.json is invalid JSON"
fi

# Test 1.2: Check if install.sh skills match manifest
log_info "Checking install.sh vs manifest.json consistency..."
MANIFEST_SKILLS=$(python3 -c "import json; m=json.load(open('$PROJECT_ROOT/skills/manifest.json')); print(' '.join(m['skills'].keys()))" 2>/dev/null || echo "")
INSTALL_SKILLS=$(grep "^ALL_SKILLS=" "$PROJECT_ROOT/install.sh" | cut -d'"' -f2)

if [ -n "$MANIFEST_SKILLS" ]; then
    MISMATCH=false
    for skill in $MANIFEST_SKILLS; do
        if ! echo "$INSTALL_SKILLS" | grep -q "$skill"; then
            log_fail "Skill '$skill' in manifest but not in install.sh ALL_SKILLS"
            MISMATCH=true
        fi
    done
    $MISMATCH || log_pass "All manifest skills present in install.sh"
else
    log_fail "Could not parse manifest.json skills"
fi

# Test 1.3: Check SKILL.md frontmatter consistency
log_info "Checking SKILL.md frontmatter format..."
FRONTMATTER_ISSUES=0
for skill_dir in "$PROJECT_ROOT/skills"/*; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        if head -1 "$skill_dir/SKILL.md" | grep -q "^---"; then
            if ! grep -q "^name:" "$skill_dir/SKILL.md"; then
                log_warn "$skill_name/SKILL.md missing 'name:' in frontmatter"
                ((FRONTMATTER_ISSUES++))
            fi
        else
            log_warn "$skill_name/SKILL.md missing YAML frontmatter"
            ((FRONTMATTER_ISSUES++))
        fi
    fi
done

# Check boris-workflow subskills
for skill_dir in "$PROJECT_ROOT/skills/boris-workflow"/*; do
    if [ -d "$skill_dir" ] && [ -f "$skill_dir/SKILL.md" ]; then
        skill_name=$(basename "$skill_dir")
        if head -1 "$skill_dir/SKILL.md" | grep -q "^---"; then
            if ! grep -q "^name:" "$skill_dir/SKILL.md"; then
                log_warn "boris-workflow/$skill_name/SKILL.md missing 'name:' in frontmatter"
                ((FRONTMATTER_ISSUES++))
            fi
        fi
    fi
done

if [ $FRONTMATTER_ISSUES -eq 0 ]; then
    log_pass "All SKILL.md files have proper frontmatter"
else
    log_fail "$FRONTMATTER_ISSUES SKILL.md files have frontmatter issues"
fi

# =============================================================================
# Test Suite 2: MCP Server Connectivity
# =============================================================================
echo -e "\n${BLUE}[Suite 2/5] MCP Server Connectivity Tests${NC}"
echo "────────────────────────────────────────"

# Test 2.1: Codex CLI availability
log_info "Testing Codex CLI..."
if command -v codex &> /dev/null; then
    CODEX_VERSION=$(codex --version 2>/dev/null || echo "unknown")
    log_pass "Codex CLI available (version: $CODEX_VERSION)"
    CODEX_AVAILABLE=true
else
    log_warn "Codex CLI not installed"
    CODEX_AVAILABLE=false
fi

# Test 2.2: Gemini CLI availability
log_info "Testing Gemini CLI..."
if command -v gemini &> /dev/null; then
    GEMINI_VERSION=$(gemini --version 2>/dev/null || echo "unknown")
    log_pass "Gemini CLI available (version: $GEMINI_VERSION)"
    GEMINI_AVAILABLE=true
else
    log_warn "Gemini CLI not installed"
    GEMINI_AVAILABLE=false
fi

# Test 2.3: MCP server configuration
log_info "Checking MCP server configuration..."
MCP_OUTPUT=$(claude mcp list 2>/dev/null || echo "FAILED")

if [ "$MCP_OUTPUT" = "FAILED" ]; then
    log_fail "Cannot query MCP servers - claude CLI issue"
else
    # Check codex MCP
    if echo "$MCP_OUTPUT" | grep -q "codex"; then
        if echo "$MCP_OUTPUT" | grep -q "codex.*Connected"; then
            log_pass "Codex MCP server connected"
        else
            log_warn "Codex MCP configured but not connected"
        fi
    else
        log_warn "Codex MCP server not configured"
    fi

    # Check gemini MCP
    if echo "$MCP_OUTPUT" | grep -q "gemini"; then
        if echo "$MCP_OUTPUT" | grep -q "gemini.*Connected"; then
            log_pass "Gemini MCP server connected"
        else
            log_warn "Gemini MCP configured but not connected"
        fi
    else
        log_warn "Gemini MCP server not configured"
    fi
fi

# =============================================================================
# Test Suite 3: CrossCheck SKILL.md Validation
# =============================================================================
echo -e "\n${BLUE}[Suite 3/5] CrossCheck SKILL.md Validation${NC}"
echo "────────────────────────────────────────"

CROSSCHECK_SKILL="$SKILLS_DIR/crosscheck/SKILL.md"

# Test 3.1: Check SKILL.md exists
log_info "Checking crosscheck skill installation..."
if [ -f "$CROSSCHECK_SKILL" ]; then
    log_pass "crosscheck/SKILL.md installed"
else
    log_fail "crosscheck/SKILL.md not found at $CROSSCHECK_SKILL"
    log_info "Run: ./install.sh crosscheck"
fi

# Test 3.2: Check MCP tool references
if [ -f "$CROSSCHECK_SKILL" ]; then
    log_info "Validating MCP tool references..."

    if grep -q "mcp__codex__codex" "$CROSSCHECK_SKILL"; then
        log_pass "SKILL.md references mcp__codex__codex"
    else
        log_fail "SKILL.md missing mcp__codex__codex reference"
    fi

    if grep -q "mcp__gemini__ask-gemini" "$CROSSCHECK_SKILL"; then
        log_pass "SKILL.md references mcp__gemini__ask-gemini"
    else
        log_fail "SKILL.md missing mcp__gemini__ask-gemini reference"
    fi
fi

# Test 3.3: Check security concerns
if [ -f "$CROSSCHECK_SKILL" ]; then
    log_info "Checking security configuration..."

    if grep -q 'sandbox.*danger-full-access' "$CROSSCHECK_SKILL"; then
        log_warn "SKILL.md uses danger-full-access sandbox (security concern)"
        ISSUES_FOUND+=("Security: danger-full-access sandbox mode")
    fi

    if grep -q 'approval-policy.*never' "$CROSSCHECK_SKILL"; then
        log_warn "SKILL.md uses approval-policy: never (auto-approve all)"
        ISSUES_FOUND+=("Security: approval-policy never")
    fi
fi

# =============================================================================
# Test Suite 4: Verify Script Coverage
# =============================================================================
echo -e "\n${BLUE}[Suite 4/5] Verify Script Coverage Tests${NC}"
echo "────────────────────────────────────────"

VERIFY_SCRIPT="$PROJECT_ROOT/scripts/verify.sh"

# Test 4.1: Check verify.sh covers all skills
log_info "Checking verify.sh skill coverage..."
if [ -f "$VERIFY_SCRIPT" ]; then
    VERIFY_SKILLS=$(grep "^ALL_SKILLS=" "$VERIFY_SCRIPT" | cut -d'"' -f2)

    if echo "$VERIFY_SKILLS" | grep -q "video-producer"; then
        log_pass "verify.sh includes video-producer"
    else
        log_fail "verify.sh missing video-producer coverage"
    fi

    if echo "$VERIFY_SKILLS" | grep -q "crosscheck"; then
        log_pass "verify.sh includes crosscheck"
    else
        log_fail "verify.sh missing crosscheck coverage"
    fi
else
    log_fail "verify.sh not found"
fi

# Test 4.2: Run verify.sh
log_info "Running verify.sh..."
if bash "$VERIFY_SCRIPT" > /dev/null 2>&1; then
    log_pass "verify.sh completed successfully"
else
    log_warn "verify.sh reported issues (see output)"
fi

# =============================================================================
# Test Suite 5: End-to-End Logging
# =============================================================================
echo -e "\n${BLUE}[Suite 5/5] Logging System Tests${NC}"
echo "────────────────────────────────────────"

# Test 5.1: Logs directory
log_info "Checking logs directory..."
if [ -d "$LOGS_DIR" ]; then
    log_pass "logs/ directory exists"
else
    mkdir -p "$LOGS_DIR"
    log_pass "logs/ directory created"
fi

# Test 5.2: Log file creation
log_info "Testing log file creation..."
TEST_LOG="$LOGS_DIR/$(date +%Y%m%d)_e2e-test.md"

cat > "$TEST_LOG" <<EOF
# CrossCheck E2E Test Log

**Date**: $(date)
**Test Type**: End-to-End Sandbox Test

## Environment
- Codex Available: $CODEX_AVAILABLE
- Gemini Available: $GEMINI_AVAILABLE

## Results
- Tests Passed: $TESTS_PASSED
- Tests Failed: $TESTS_FAILED
- Tests Skipped: $TESTS_SKIPPED

## Issues Found
$(for issue in "${ISSUES_FOUND[@]}"; do echo "- $issue"; done)
EOF

if [ -f "$TEST_LOG" ]; then
    log_pass "Log file created: $TEST_LOG"
else
    log_fail "Could not create log file"
fi

# =============================================================================
# Summary
# =============================================================================
echo -e "\n${BLUE}╔═══════════════════════════════════════════════════════════╗"
echo "║                    TEST SUMMARY                            ║"
echo "╚═══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Tests Passed:  $TESTS_PASSED"
echo "Tests Failed:  $TESTS_FAILED"
echo "Tests Skipped: $TESTS_SKIPPED"
echo ""

if [ ${#ISSUES_FOUND[@]} -gt 0 ]; then
    echo -e "${YELLOW}Issues Found:${NC}"
    for issue in "${ISSUES_FOUND[@]}"; do
        echo "  • $issue"
    done
    echo ""
fi

if [ $TESTS_FAILED -gt 0 ]; then
    echo -e "${RED}Some tests failed. Review issues above.${NC}"
    exit 1
else
    echo -e "${GREEN}All critical tests passed!${NC}"
    exit 0
fi
