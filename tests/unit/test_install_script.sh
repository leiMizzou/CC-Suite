#!/usr/bin/env bash
# Unit tests for install.sh script
# Tests: skill listing, dependency detection, error handling

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INSTALL_SCRIPT="$PROJECT_ROOT/install.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Install Script Unit Tests"
echo "========================================="

# Test 1: Check if install.sh exists and is executable
echo -e "\n${YELLOW}Test 1: Verify install.sh exists${NC}"
if [ ! -f "$INSTALL_SCRIPT" ]; then
    echo -e "${RED}FAIL: install.sh not found${NC}"
    exit 1
fi
echo -e "${GREEN}PASS: install.sh found${NC}"

# Test 2: Check ALL_SKILLS definition
echo -e "\n${YELLOW}Test 2: Check ALL_SKILLS list completeness${NC}"

# Extract ALL_SKILLS from install.sh
ALL_SKILLS=$(grep '^ALL_SKILLS=' "$INSTALL_SCRIPT" | sed 's/ALL_SKILLS="//' | sed 's/"//')
echo "Found ALL_SKILLS: $ALL_SKILLS"

# Check for actual skills in directory
ACTUAL_SKILLS=$(find "$PROJECT_ROOT/skills" -maxdepth 1 -type d ! -name skills ! -name boris-workflow -exec basename {} \; 2>/dev/null | sort)

echo "Actual skills in skills/ directory:"
echo "$ACTUAL_SKILLS"

# Check if video-producer is missing from ALL_SKILLS
if echo "$ALL_SKILLS" | grep -q "video-producer"; then
    echo -e "${GREEN}PASS: video-producer in ALL_SKILLS${NC}"
else
    echo -e "${RED}FAIL: video-producer missing from ALL_SKILLS${NC}"
    echo "This is the critical bug identified in CrossCheck analysis!"
    VIDEO_PRODUCER_MISSING=true
fi

# Test 3: Check boris-workflow expansion
echo -e "\n${YELLOW}Test 3: Check boris-workflow skill group${NC}"

if echo "$ALL_SKILLS" | grep -q "claude-code-setup"; then
    echo -e "${GREEN}PASS: claude-code-setup found${NC}"
else
    echo -e "${RED}FAIL: claude-code-setup missing${NC}"
fi

if echo "$ALL_SKILLS" | grep -q "create-subagent"; then
    echo -e "${GREEN}PASS: create-subagent found${NC}"
else
    echo -e "${RED}FAIL: create-subagent missing${NC}"
fi

# Test 4: Check Python dependency handling
echo -e "\n${YELLOW}Test 4: Check Python dependency installation${NC}"

if grep -q "python3 -m venv" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS: Uses virtual environment${NC}"
else
    echo -e "${YELLOW}WARN: No virtual environment detected (uses global pip)${NC}"
    VENV_MISSING=true
fi

# Test 5: Check Node.js dependency handling
echo -e "\n${YELLOW}Test 5: Check Node.js dependency installation${NC}"

if grep -q "npm install" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS: Node.js dependencies handled${NC}"
else
    echo -e "${YELLOW}WARN: No npm install found (video-producer won't build)${NC}"
    NPM_MISSING=true
fi

# Test 6: Check Playwright browser installation
echo -e "\n${YELLOW}Test 6: Check Playwright browser installation${NC}"

if grep -q "playwright.*install chromium\|playwright install" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS: Playwright browser installation included${NC}"
else
    echo -e "${RED}FAIL: Playwright browser installation missing${NC}"
    PLAYWRIGHT_MISSING=true
fi

# Test 7: Check for security options (--safe-mode, etc.)
echo -e "\n${YELLOW}Test 7: Check for safety options${NC}"

if grep -q "\-\-safe" "$INSTALL_SCRIPT" || grep -q "\-\-dry-run" "$INSTALL_SCRIPT"; then
    echo -e "${GREEN}PASS: Safety options available${NC}"
else
    echo -e "${YELLOW}WARN: No --safe or --dry-run options${NC}"
    SAFETY_OPTIONS_MISSING=true
fi

# Summary
echo -e "\n========================================="
echo "Test Summary"
echo "========================================="

CRITICAL_ISSUES=0
WARNINGS=0

if [ "$VIDEO_PRODUCER_MISSING" = true ]; then
    echo -e "${RED}CRITICAL: video-producer not in ALL_SKILLS${NC}"
    ((CRITICAL_ISSUES++))
fi

if [ "$VENV_MISSING" = true ]; then
    echo -e "${YELLOW}WARNING: No Python virtual environment${NC}"
    ((WARNINGS++))
fi

if [ "$NPM_MISSING" = true ]; then
    echo -e "${YELLOW}WARNING: No npm install for video-producer${NC}"
    ((WARNINGS++))
fi

if [ "$PLAYWRIGHT_MISSING" = true ]; then
    echo -e "${RED}CRITICAL: Playwright browser not installed${NC}"
    ((CRITICAL_ISSUES++))
fi

if [ "$SAFETY_OPTIONS_MISSING" = true ]; then
    echo -e "${YELLOW}WARNING: No safety options (--dry-run, --safe)${NC}"
    ((WARNINGS++))
fi

echo ""
echo "Critical issues: $CRITICAL_ISSUES"
echo "Warnings: $WARNINGS"

if [ $CRITICAL_ISSUES -gt 0 ]; then
    echo -e "\n${RED}P0 critical issues found - tests failed${NC}"
    echo "See CrossCheck analysis for detailed fixes"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "\n${YELLOW}P0 issues resolved! Remaining warnings are P1/P2 priority${NC}"
    echo "See CrossCheck analysis for improvement roadmap"
    exit 0
else
    echo -e "\n${GREEN}All tests passed!${NC}"
    exit 0
fi
