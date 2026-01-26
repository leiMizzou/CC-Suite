#!/usr/bin/env bash
# Unit tests for video-producer skill

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILL_DIR="$PROJECT_ROOT/skills/video-producer"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Video Producer Unit Tests"
echo "========================================="

PASSED=0
FAILED=0

# Test 1: SKILL.md exists
echo -e "\n${YELLOW}Test 1: SKILL.md Structure${NC}"
if [ -f "$SKILL_DIR/SKILL.md" ]; then
    echo -e "${GREEN}✓${NC} SKILL.md exists"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} SKILL.md missing"
    FAILED=$((FAILED+1))
fi

# Test 2: package.json exists
echo -e "\n${YELLOW}Test 2: Package Configuration${NC}"
if [ -f "$SKILL_DIR/package.json" ]; then
    echo -e "${GREEN}✓${NC} package.json exists"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} package.json missing"
    FAILED=$((FAILED+1))
fi

# Test 3: package-lock.json for reproducibility
if [ -f "$SKILL_DIR/package-lock.json" ]; then
    echo -e "${GREEN}✓${NC} package-lock.json exists"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} package-lock.json missing"
    FAILED=$((FAILED+1))
fi

# Test 4: Remotion dependency
if [ -f "$SKILL_DIR/package.json" ] && grep -q "remotion" "$SKILL_DIR/package.json"; then
    echo -e "${GREEN}✓${NC} Remotion dependency present"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Remotion dependency missing"
    FAILED=$((FAILED+1))
fi

# Test 5: In manifest
echo -e "\n${YELLOW}Test 3: Manifest Registration${NC}"
if [ -f "$PROJECT_ROOT/skills/manifest.json" ] && grep -q '"video-producer"' "$PROJECT_ROOT/skills/manifest.json"; then
    echo -e "${GREEN}✓${NC} video-producer in manifest.json"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} video-producer not in manifest.json"
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
