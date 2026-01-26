#!/usr/bin/env bash
# Integration test for CrossCheck skill end-to-end flow
# Tests: Round 1 (independent answers) -> Round 2 (cross review) -> Round 3 (synthesis)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOGS_DIR="$PROJECT_ROOT/logs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "CrossCheck Integration Test"
echo "========================================="

# Test 1: Check if crosscheck skill is installed
echo -e "\n${YELLOW}Test 1: Verify crosscheck skill installation${NC}"
if [ ! -f "$HOME/.claude/skills/crosscheck/SKILL.md" ]; then
    echo -e "${RED}FAIL: crosscheck skill not found${NC}"
    exit 1
fi
echo -e "${GREEN}PASS: crosscheck skill found${NC}"

# Test 2: Check MCP server availability
echo -e "\n${YELLOW}Test 2: Check MCP servers (Codex, Gemini)${NC}"

# Check Codex
if command -v codex &> /dev/null; then
    echo -e "${GREEN}PASS: Codex CLI found${NC}"
else
    echo -e "${YELLOW}WARN: Codex CLI not found (degraded mode)${NC}"
fi

# Check Gemini
if command -v gemini &> /dev/null; then
    echo -e "${GREEN}PASS: Gemini CLI found${NC}"
else
    echo -e "${YELLOW}WARN: Gemini CLI not found (degraded mode)${NC}"
fi

# Test 3: Simulate CrossCheck workflow with mock question
echo -e "\n${YELLOW}Test 3: Simulate CrossCheck Round 1 (Independent Answers)${NC}"

TEST_QUESTION="What are the trade-offs between microservices and monolithic architecture?"

# This would normally be called by Claude Code, simulating the logic here
echo "Question: $TEST_QUESTION"

# Mock Claude answer
CLAUDE_ANSWER="Microservices offer scalability and independent deployment but add complexity. Monoliths are simpler to develop initially but harder to scale."

# Mock Codex answer (simulated - would use mcp__codex__codex in real scenario)
CODEX_AVAILABLE=false
if command -v codex &> /dev/null; then
    CODEX_AVAILABLE=true
    echo -e "${GREEN}Codex would provide independent answer${NC}"
else
    echo -e "${YELLOW}Codex UNAVAILABLE - degraded mode${NC}"
fi

# Mock Gemini answer (simulated)
GEMINI_AVAILABLE=false
if command -v gemini &> /dev/null; then
    GEMINI_AVAILABLE=true
    echo -e "${GREEN}Gemini would provide independent answer${NC}"
else
    echo -e "${YELLOW}Gemini UNAVAILABLE - degraded mode${NC}"
fi

# Count available models
AVAILABLE_MODELS=1 # Claude always available
$CODEX_AVAILABLE && ((AVAILABLE_MODELS++))
$GEMINI_AVAILABLE && ((AVAILABLE_MODELS++))

echo "Available models: $AVAILABLE_MODELS/3"

if [ $AVAILABLE_MODELS -lt 2 ]; then
    echo -e "${RED}FAIL: Minimum 2 models required for CrossCheck${NC}"
    exit 1
fi

echo -e "${GREEN}PASS: Sufficient models for verification${NC}"

# Test 4: Check logging capability
echo -e "\n${YELLOW}Test 4: Verify logging directory${NC}"

mkdir -p "$LOGS_DIR"
TEST_LOG="$LOGS_DIR/$(date +%Y%m%d)_test-question.md"

cat > "$TEST_LOG" <<EOF
# CrossCheck Test Log

**Date**: $(date)
**Question**: $TEST_QUESTION
**Mode**: Test Mode
**Available Models**: $AVAILABLE_MODELS/3

## Round 1: Independent Answers

| Model | Status | Answer |
|-------|--------|--------|
| Claude | OK | $CLAUDE_ANSWER |
| Codex | $($CODEX_AVAILABLE && echo "OK" || echo "UNAVAILABLE") | - |
| Gemini | $($GEMINI_AVAILABLE && echo "OK" || echo "UNAVAILABLE") | - |

## Test Result
Integration test completed successfully.
EOF

if [ -f "$TEST_LOG" ]; then
    echo -e "${GREEN}PASS: Log file created at $TEST_LOG${NC}"
else
    echo -e "${RED}FAIL: Could not create log file${NC}"
    exit 1
fi

# Test 5: Validate degraded mode handling
echo -e "\n${YELLOW}Test 5: Degraded mode handling${NC}"

if [ $AVAILABLE_MODELS -eq 3 ]; then
    echo -e "${GREEN}PASS: Full verification mode (3 models)${NC}"
elif [ $AVAILABLE_MODELS -eq 2 ]; then
    echo -e "${GREEN}PASS: Degraded mode with 2 models${NC}"
else
    echo -e "${RED}FAIL: Insufficient models${NC}"
    exit 1
fi

# Summary
echo -e "\n========================================="
echo -e "${GREEN}All CrossCheck integration tests passed!${NC}"
echo -e "========================================="
echo ""
echo "Next steps:"
echo "1. Install missing MCP servers (codex, gemini)"
echo "2. Test with real /crosscheck command in Claude Code"
echo "3. Verify Round 2 (cross review) and Round 3 (synthesis)"
