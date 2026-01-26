#!/usr/bin/env bash
# Sandbox test for CC Suite issues identified by CrossCheck
# Simplified version for reliable execution

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "========================================="
echo "   CC Suite CrossCheck Issue Validator  "
echo "========================================="
echo -e "${NC}"

PASSED=0
FAILED=0

echo -e "\n${YELLOW}=== P0 Issue Tests ===${NC}\n"

# Test 1: Skill naming consistency
echo -e "${BLUE}Test 1: Skill Naming Consistency${NC}"
SKILL_NAME=$(grep -m1 "^name:" "$PROJECT_ROOT/skills/social-publisher/SKILL.md" 2>/dev/null | sed 's/name: *//' | tr -d ' ' || echo "unknown")
if [ "$SKILL_NAME" = "social-publisher" ]; then
    echo -e "${GREEN}✓${NC} Skill naming matches manifest (social-publisher)"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Skill naming mismatch: $SKILL_NAME"
    FAILED=$((FAILED+1))
fi

# Test 2: CrossCheck security documented
echo -e "\n${BLUE}Test 2: CrossCheck Security${NC}"
if grep -q "SECURITY WARNING" "$PROJECT_ROOT/skills/crosscheck/SKILL.md" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Security warning present in CrossCheck SKILL.md"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Security warning missing"
    FAILED=$((FAILED+1))
fi

if grep -q "\-\-safe" "$PROJECT_ROOT/skills/crosscheck/SKILL.md" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Safe mode documented"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Safe mode not documented"
    FAILED=$((FAILED+1))
fi

# Test 3: Manifest valid
echo -e "\n${BLUE}Test 3: Manifest Validation${NC}"
if python3 -c "import json; json.load(open('$PROJECT_ROOT/skills/manifest.json'))" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} manifest.json is valid JSON"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} manifest.json invalid"
    FAILED=$((FAILED+1))
fi

echo -e "\n${YELLOW}=== P1 Issue Tests ===${NC}\n"

# Test 4: Dependency lockfiles
echo -e "${BLUE}Test 4: Dependency Lockfiles${NC}"
if [ -f "$PROJECT_ROOT/skills/video-producer/package-lock.json" ]; then
    echo -e "${GREEN}✓${NC} video-producer has package-lock.json"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} video-producer missing lockfile"
    FAILED=$((FAILED+1))
fi

if grep -q "==" "$PROJECT_ROOT/skills/social-publisher/requirements.txt" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} social-publisher has pinned requirements"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} social-publisher requirements not pinned"
    FAILED=$((FAILED+1))
fi

# Test 5: Skill tests exist
echo -e "\n${BLUE}Test 5: Test Coverage${NC}"
if [ -f "$PROJECT_ROOT/tests/unit/test_social_publisher.sh" ]; then
    echo -e "${GREEN}✓${NC} social-publisher has unit tests"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} social-publisher missing tests"
    FAILED=$((FAILED+1))
fi

if [ -f "$PROJECT_ROOT/tests/unit/test_video_producer.sh" ]; then
    echo -e "${GREEN}✓${NC} video-producer has unit tests"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} video-producer missing tests"
    FAILED=$((FAILED+1))
fi

# Summary
echo ""
echo -e "${BLUE}========================================="
echo "           Test Summary                  "
echo -e "=========================================${NC}"
echo "Total: $((PASSED+FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"

if [ $FAILED -gt 0 ]; then
    echo -e "\n${RED}Some issues remain. Review and fix.${NC}"
    exit 1
else
    echo -e "\n${GREEN}All CrossCheck issues resolved!${NC}"
    exit 0
fi
