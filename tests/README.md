# CC-Suite Test Suite

Comprehensive tests for validating CC-Suite functionality and identifying issues.

## Test Structure

```
tests/
├── unit/              # Unit tests for individual components
│   └── test_install_script.sh
├── integration/       # End-to-end workflow tests
│   └── test_crosscheck_flow.sh
└── README.md
```

## Running Tests

### Quick Start

```bash
# Run all tests
./tests/run_all_tests.sh

# Run unit tests only
./tests/unit/test_install_script.sh

# Run integration tests only
./tests/integration/test_crosscheck_flow.sh
```

### Prerequisites

- Bash 3.2+ (macOS compatible)
- Claude Code installed
- Optional: Codex and Gemini MCP servers for full CrossCheck testing

## Test Coverage

### Unit Tests

#### `test_install_script.sh`
Validates install.sh correctness:
- [x] ALL_SKILLS list completeness
- [x] video-producer inclusion (CRITICAL BUG)
- [x] Python virtual environment usage
- [x] Node.js dependency handling
- [x] Playwright browser installation
- [x] Safety options (--dry-run, --safe)

**Expected Failures** (before fixes):
- video-producer missing from ALL_SKILLS
- No Python venv
- No npm install for video-producer
- No Playwright browser install
- No safety options

### Integration Tests

#### `test_crosscheck_flow.sh`
Tests CrossCheck end-to-end workflow:
- [x] Skill installation verification
- [x] MCP server availability (Codex, Gemini)
- [x] Round 1: Independent answers
- [x] Degraded mode handling (2/3 models)
- [x] Logging functionality

## Known Issues (from CrossCheck Analysis)

### P0 (Critical)
1. **video-producer installation missing** - Not in ALL_SKILLS
2. **State file pollution** - .social_publisher/ in version control
3. **Playwright browser not installed** - Missing install step

### P1 (Important)
4. **No dependency isolation** - Global pip/npm install
5. **No test infrastructure** - This test suite addresses that
6. **Local config in repo** - .claude/, .mcp.json committed

### P2 (Enhancement)
7. **Fragile MCP integration** - Hardcoded tool names
8. **No manifest.json** - Skills hardcoded in multiple places
9. **Windows incompatible** - Heavy .sh script dependency
10. **Inconsistent SKILL metadata** - Missing YAML front-matter

## Test Results

Run tests and check output:
- `PASS` (green) - Test passed
- `WARN` (yellow) - Non-critical issue
- `FAIL` (red) - Critical issue

## Contributing

When adding new skills or features:
1. Add unit tests for new scripts
2. Add integration tests for new workflows
3. Run full test suite before committing
4. Update this README with new test coverage

## Fixing Issues

Follow the priority order from CrossCheck analysis:

```bash
# Phase 1: Fix critical install.sh issues
# See tests/unit/test_install_script.sh for validation

# Phase 2: Add dependency isolation
# See logs/ for detailed improvement plans

# Phase 3: Implement manifest.json system
# See CrossCheck recommendations
```

## CI Integration (Future)

```bash
# Add to .github/workflows/test.yml
name: CC-Suite Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: ./tests/run_all_tests.sh
```
