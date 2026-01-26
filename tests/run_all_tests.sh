#!/usr/bin/env bash
# Master test runner for CC-Suite
# Runs all unit and integration tests

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "========================================="
echo "       CC-Suite Test Suite Runner       "
echo "========================================="
echo -e "${NC}"

TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Run unit tests
echo -e "\n${YELLOW}Running Unit Tests...${NC}\n"

# Test 1: Install script
echo -e "${BLUE}[1/3] Install Script Tests${NC}"
if bash "$SCRIPT_DIR/unit/test_install_script.sh"; then
    echo -e "${GREEN}Install script tests: PASSED${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}Install script tests: FAILED${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Test 2: Social Publisher
echo -e "\n${BLUE}[2/3] Social Publisher Tests${NC}"
if bash "$SCRIPT_DIR/unit/test_social_publisher.sh"; then
    echo -e "${GREEN}Social publisher tests: PASSED${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}Social publisher tests: FAILED${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Test 3: Video Producer
echo -e "\n${BLUE}[3/3] Video Producer Tests${NC}"
if bash "$SCRIPT_DIR/unit/test_video_producer.sh"; then
    echo -e "${GREEN}Video producer tests: PASSED${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}Video producer tests: FAILED${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Run integration tests
echo -e "\n${YELLOW}Running Integration Tests...${NC}\n"

if bash "$SCRIPT_DIR/integration/test_crosscheck_flow.sh"; then
    echo -e "${GREEN}Integration tests: PASSED${NC}"
    ((PASSED_TESTS++))
else
    echo -e "${RED}Integration tests: FAILED${NC}"
    ((FAILED_TESTS++))
fi
((TOTAL_TESTS++))

# Summary
echo -e "\n${BLUE}"
echo "========================================="
echo "           Test Summary                  "
echo "========================================="
echo -e "${NC}"
echo "Total test suites: $TOTAL_TESTS"
echo -e "${GREEN}Passed: $PASSED_TESTS${NC}"
echo -e "${RED}Failed: $FAILED_TESTS${NC}"

if [ $FAILED_TESTS -gt 0 ]; then
    echo -e "\n${RED}Some tests failed. See output above for details.${NC}"
    echo "Review logs/ directory for CrossCheck analysis and fixes."
    exit 1
else
    echo -e "\n${GREEN}All test suites passed!${NC}"
    exit 0
fi
