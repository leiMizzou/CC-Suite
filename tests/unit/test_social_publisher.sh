#!/usr/bin/env bash
# Unit tests for social-publisher skill

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$PROJECT_ROOT/skills/social-publisher"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Social Publisher Unit Tests"
echo "========================================="

PASSED=0
FAILED=0

# Test 1: SKILL.md exists
echo -e "\n${YELLOW}Test 1: SKILL.md Structure${NC}"
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo -e "${GREEN}✓${NC} SKILL.md exists"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} SKILL.md exists"
    FAILED=$((FAILED+1))
fi

# Test 2: Name matches manifest
SKILL_NAME=$(grep -m1 "^name:" "$SKILL_DIR/SKILL.md" 2>/dev/null | sed 's/name: *//' | tr -d ' ' || echo "unknown")
if [ "$SKILL_NAME" = "social-publisher" ]; then
    echo -e "${GREEN}✓${NC} SKILL.md name matches manifest"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} SKILL.md name mismatch: $SKILL_NAME"
    FAILED=$((FAILED+1))
fi

# Test 3: Required scripts exist
echo -e "\n${YELLOW}Test 2: Required Scripts${NC}"
if [ -f "$SKILL_DIR/scripts/content_tracker.py" ]; then
    echo -e "${GREEN}✓${NC} content_tracker.py exists"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} content_tracker.py missing"
    FAILED=$((FAILED+1))
fi

if [ -f "$SKILL_DIR/scripts/check_login.py" ]; then
    echo -e "${GREEN}✓${NC} check_login.py exists"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} check_login.py missing"
    FAILED=$((FAILED+1))
fi

# Test 4: Requirements pinned
echo -e "\n${YELLOW}Test 3: Dependency Pinning${NC}"
if [ -f "$SKILL_DIR/requirements.txt" ] && grep -q "==" "$SKILL_DIR/requirements.txt"; then
    echo -e "${GREEN}✓${NC} Requirements use pinned versions"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Requirements not pinned"
    FAILED=$((FAILED+1))
fi

# Summary
echo ""
echo "========================================="
echo "Test Summary: Passed=$PASSED Failed=$FAILED"
echo "========================================="

if [ $FAILED -gt 0 ]; then
    exit 1
else
    exit 0
fi
