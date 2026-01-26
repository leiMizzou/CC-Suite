#!/usr/bin/env bash
# Pre-commit validation script
# Validates code quality before allowing commits

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo -e "${GREEN}Running pre-commit checks...${NC}\n"

CHECKS_PASSED=0
CHECKS_FAILED=0

# Check 1: Validate manifest.json
echo -e "${YELLOW}Check 1: Validating manifest.json...${NC}"
if python3 -m json.tool "$PROJECT_ROOT/skills/manifest.json" > /dev/null 2>&1; then
    echo -e "${GREEN}✓ manifest.json is valid JSON${NC}\n"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ manifest.json has invalid JSON syntax${NC}\n"
    ((CHECKS_FAILED++))
fi

# Check 2: No sensitive files
echo -e "${YELLOW}Check 2: Checking for sensitive files...${NC}"
SENSITIVE_FILES=$(git diff --cached --name-only | grep -E '\.(env|local)$|\.mcp\.json$|cookies/|sessions/|\.social_publisher/' || true)
if [ -z "$SENSITIVE_FILES" ]; then
    echo -e "${GREEN}✓ No sensitive files in staged changes${NC}\n"
    ((CHECKS_PASSED++))
else
    echo -e "${RED}✗ Sensitive files found:${NC}"
    echo "$SENSITIVE_FILES"
    echo -e "${YELLOW}Add these to .gitignore and unstage them${NC}\n"
    ((CHECKS_FAILED++))
fi

# Check 3: Shell script syntax (if shellcheck available)
if command -v shellcheck &> /dev/null; then
    echo -e "${YELLOW}Check 3: Validating shell scripts...${NC}"
    SHELL_FILES=$(git diff --cached --name-only | grep '\.sh$' || true)

    if [ -n "$SHELL_FILES" ]; then
        SHELLCHECK_FAILED=false
        for file in $SHELL_FILES; do
            if [ -f "$PROJECT_ROOT/$file" ]; then
                if shellcheck "$PROJECT_ROOT/$file" > /dev/null 2>&1; then
                    echo -e "  ${GREEN}✓${NC} $file"
                else
                    echo -e "  ${RED}✗${NC} $file (shellcheck warnings)"
                    SHELLCHECK_FAILED=true
                fi
            fi
        done

        if $SHELLCHECK_FAILED; then
            echo -e "${YELLOW}Note: Shellcheck warnings found (not blocking)${NC}\n"
            ((CHECKS_PASSED++))
        else
            echo -e "${GREEN}✓ All shell scripts passed shellcheck${NC}\n"
            ((CHECKS_PASSED++))
        fi
    else
        echo -e "${GREEN}✓ No shell scripts to check${NC}\n"
        ((CHECKS_PASSED++))
    fi
else
    echo -e "${YELLOW}⚠ shellcheck not installed, skipping shell validation${NC}\n"
    ((CHECKS_PASSED++))
fi

# Check 4: Run quick tests if test files changed
echo -e "${YELLOW}Check 4: Checking if tests need to run...${NC}"
TEST_FILES=$(git diff --cached --name-only | grep -E 'install\.sh|tests/|SKILL\.md' || true)

if [ -n "$TEST_FILES" ]; then
    echo -e "${YELLOW}Test-related files changed, running quick tests...${NC}"

    if [ -x "$PROJECT_ROOT/tests/run_all_tests.sh" ]; then
        if "$PROJECT_ROOT/tests/run_all_tests.sh" > /dev/null 2>&1; then
            echo -e "${GREEN}✓ All tests passed${NC}\n"
            ((CHECKS_PASSED++))
        else
            echo -e "${RED}✗ Tests failed - fix before committing${NC}"
            echo -e "${YELLOW}Run: ./tests/run_all_tests.sh for details${NC}\n"
            ((CHECKS_FAILED++))
        fi
    else
        echo -e "${YELLOW}⚠ Test runner not executable, skipping${NC}\n"
        ((CHECKS_PASSED++))
    fi
else
    echo -e "${GREEN}✓ No test-related changes${NC}\n"
    ((CHECKS_PASSED++))
fi

# Summary
echo -e "========================================="
echo -e "Pre-commit Check Summary"
echo -e "========================================="
echo -e "${GREEN}Passed: $CHECKS_PASSED${NC}"
echo -e "${RED}Failed: $CHECKS_FAILED${NC}"
echo ""

if [ $CHECKS_FAILED -gt 0 ]; then
    echo -e "${RED}Pre-commit checks failed. Fix issues before committing.${NC}"
    exit 1
else
    echo -e "${GREEN}All pre-commit checks passed!${NC}"
    exit 0
fi
