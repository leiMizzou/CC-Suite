#!/usr/bin/env bash
# Install Git hooks for CC-Suite

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "Installing Git hooks..."
echo ""

# Check if .git directory exists
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "Error: Not a git repository"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p "$HOOKS_DIR"

# Install pre-commit hook
cat > "$HOOKS_DIR/pre-commit" <<'EOF'
#!/usr/bin/env bash
# Pre-commit hook for CC-Suite
# Runs validation checks before allowing commit

SCRIPT_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

if [ -x "$SCRIPT_DIR/scripts/pre-commit-check.sh" ]; then
    "$SCRIPT_DIR/scripts/pre-commit-check.sh"
else
    echo "Warning: pre-commit-check.sh not found or not executable"
    exit 0
fi
EOF

chmod +x "$HOOKS_DIR/pre-commit"
echo -e "${GREEN}✓ Installed pre-commit hook${NC}"

# Install commit-msg hook (validates commit message format)
cat > "$HOOKS_DIR/commit-msg" <<'EOF'
#!/usr/bin/env bash
# Commit message validation hook

COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Check if commit message follows conventional commits format
# Pattern: type(scope): message
# Examples:
#   feat: Add new feature
#   fix: Fix bug
#   docs: Update documentation
#   test: Add tests

if echo "$COMMIT_MSG" | grep -qE '^(feat|fix|docs|style|refactor|test|chore|perf|ci|build|revert)(\(.+\))?: .+'; then
    exit 0
fi

# Allow merge commits
if echo "$COMMIT_MSG" | grep -qE '^Merge '; then
    exit 0
fi

# Allow revert commits
if echo "$COMMIT_MSG" | grep -qE '^Revert '; then
    exit 0
fi

echo "Error: Commit message does not follow conventional commits format"
echo ""
echo "Format: <type>(<scope>): <message>"
echo ""
echo "Types: feat, fix, docs, style, refactor, test, chore, perf, ci, build, revert"
echo ""
echo "Examples:"
echo "  feat: Add new crosscheck feature"
echo "  fix: Resolve installation bug"
echo "  docs: Update README"
echo "  test: Add integration tests"
echo ""
echo "Your message:"
echo "$COMMIT_MSG"

exit 1
EOF

chmod +x "$HOOKS_DIR/commit-msg"
echo -e "${GREEN}✓ Installed commit-msg hook${NC}"

echo ""
echo "Git hooks installed successfully!"
echo ""
echo -e "${YELLOW}Hooks installed:${NC}"
echo "  - pre-commit: Validates code before commit"
echo "  - commit-msg: Validates commit message format"
echo ""
echo "To skip hooks (not recommended):"
echo "  git commit --no-verify"
