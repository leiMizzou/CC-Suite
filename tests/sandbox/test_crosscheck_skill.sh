#!/usr/bin/env bash
# Sandbox test for CrossCheck skill issues identified by multi-model analysis
# Tests P0/P1 issues in the CrossCheck skill itself

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "========================================="
echo "   CrossCheck Skill Issue Validator     "
echo "========================================="
echo -e "${NC}"

PASSED=0
FAILED=0
ISSUES=()

SKILL_SOURCE="$PROJECT_ROOT/skills/crosscheck/SKILL.md"
SKILL_INSTALLED="$HOME/.claude/skills/crosscheck/SKILL.md"

echo -e "\n${YELLOW}=== P0: Version Sync ===${NC}\n"

# Test 1: Check if installed version matches source
echo -e "${BLUE}Test 1: Version Sync Check${NC}"
if [ -f "$SKILL_INSTALLED" ]; then
    DIFF_COUNT=$(diff "$SKILL_INSTALLED" "$SKILL_SOURCE" 2>/dev/null | wc -l)
    if [ "$DIFF_COUNT" -eq 0 ]; then
        echo -e "${GREEN}✓${NC} Installed version matches source"
        PASSED=$((PASSED+1))
    else
        echo -e "${RED}✗${NC} Installed version differs from source ($DIFF_COUNT lines)"
        ISSUES+=("Version out of sync - run install.sh to update")
        FAILED=$((FAILED+1))
    fi
else
    echo -e "${YELLOW}⚠${NC} Skill not installed at $SKILL_INSTALLED"
    PASSED=$((PASSED+1))  # Not a failure if not installed
fi

echo -e "\n${YELLOW}=== P0: Security Defaults ===${NC}\n"

# Test 2: Security warning present in source
echo -e "${BLUE}Test 2: Security Warning in Source${NC}"
if grep -q "SECURITY WARNING" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Security warning present in source"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Security warning missing in source"
    ISSUES+=("Add SECURITY WARNING to SKILL.md")
    FAILED=$((FAILED+1))
fi

# Test 3: Risk level documented
echo -e "${BLUE}Test 3: Risk Level Documentation${NC}"
if grep -q "Risk level.*HIGH" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Risk level HIGH documented for default mode"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Risk level not documented"
    ISSUES+=("Add risk level documentation")
    FAILED=$((FAILED+1))
fi

# Test 4: Safe mode recommended
echo -e "${BLUE}Test 4: Safe Mode Recommendation${NC}"
if grep -q "RECOMMENDED.*production\|Recommended for most" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Safe mode recommended for production"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Safe mode not explicitly recommended"
    ISSUES+=("Add recommendation for safe mode in production")
    FAILED=$((FAILED+1))
fi

echo -e "\n${YELLOW}=== P0: Consensus Detection ===${NC}\n"

# Test 5: Smart short-circuit has criteria
echo -e "${BLUE}Test 5: Short-Circuit Criteria${NC}"
if grep -q "substantially agree\|same core conclusion" "$SKILL_SOURCE" 2>/dev/null; then
    # Check if there are objective criteria
    if grep -q "factual.*not opinion\|no contradictions" "$SKILL_SOURCE" 2>/dev/null; then
        echo -e "${GREEN}✓${NC} Short-circuit has some criteria defined"
        PASSED=$((PASSED+1))
    else
        echo -e "${YELLOW}⚠${NC} Short-circuit criteria could be more objective"
        PASSED=$((PASSED+1))  # Partial pass
    fi
else
    echo -e "${RED}✗${NC} No short-circuit criteria found"
    ISSUES+=("Define objective short-circuit criteria")
    FAILED=$((FAILED+1))
fi

echo -e "\n${YELLOW}=== P1: Logging Safety ===${NC}\n"

# Test 6: Logging path documented
echo -e "${BLUE}Test 6: Logging Configuration${NC}"
if grep -q "logs/.*\.md" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Logging path documented"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Logging path not documented"
    ISSUES+=("Document logging path")
    FAILED=$((FAILED+1))
fi

# Test 7: Check for --no-log option (P1 enhancement)
echo -e "${BLUE}Test 7: No-Log Option (Enhancement)${NC}"
if grep -q "\-\-no-log\|disable.*log" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} --no-log option available"
    PASSED=$((PASSED+1))
else
    echo -e "${YELLOW}⚠${NC} No --no-log option (P1 enhancement)"
    # Not a failure, just enhancement
    PASSED=$((PASSED+1))
fi

echo -e "\n${YELLOW}=== P1: Parallel Execution ===${NC}\n"

# Test 8: Parallel execution instruction
echo -e "${BLUE}Test 8: Parallel Execution Documented${NC}"
if grep -q "parallel\|single message with both" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Parallel execution instruction present"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Parallel execution not documented"
    ISSUES+=("Add parallel execution instruction")
    FAILED=$((FAILED+1))
fi

echo -e "\n${YELLOW}=== P1: Error Handling ===${NC}\n"

# Test 9: Degraded mode documented
echo -e "${BLUE}Test 9: Degraded Mode Handling${NC}"
if grep -q "UNAVAILABLE\|minimum 2 models" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Degraded mode handling documented"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Degraded mode not documented"
    ISSUES+=("Document degraded mode handling")
    FAILED=$((FAILED+1))
fi

# Test 10: Abort condition
echo -e "${BLUE}Test 10: Abort Condition${NC}"
if grep -q "only 1 model.*abort\|abort.*inform" "$SKILL_SOURCE" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Abort condition documented"
    PASSED=$((PASSED+1))
else
    echo -e "${RED}✗${NC} Abort condition not documented"
    ISSUES+=("Document abort condition")
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

if [ ${#ISSUES[@]} -gt 0 ]; then
    echo -e "\n${YELLOW}Issues to Fix:${NC}"
    for issue in "${ISSUES[@]}"; do
        echo "  - $issue"
    done
fi

if [ $FAILED -gt 0 ]; then
    echo -e "\n${RED}Some tests failed. Fixes needed.${NC}"
    exit 1
else
    echo -e "\n${GREEN}All CrossCheck skill tests passed!${NC}"
    exit 0
fi
