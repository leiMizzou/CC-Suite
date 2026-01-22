# Feature Coverage Checker Agent

## Goal
Verify that CC Suite covers all functionality from the original three projects:
- CrossCheck
- SocialPublisher
- BorisWorkflow

## Verification Checklist

### CrossCheck Features
| Feature | CC Suite Location | Status |
|---------|------------------|--------|
| Multi-model verification (Claude+Codex+Gemini) | skills/crosscheck/SKILL.md | Check |
| 3-round verification process | skills/crosscheck/SKILL.md | Check |
| Smart short-circuit (fast consensus) | skills/crosscheck/SKILL.md | Check |
| Fault tolerance (degraded mode) | skills/crosscheck/SKILL.md | Check |
| Auto logging | skills/crosscheck/SKILL.md | Check |

### SocialPublisher Features
| Feature | CC Suite Location | Status |
|---------|------------------|--------|
| Multi-platform publishing | skills/social-publisher/SKILL.md | Check |
| Content adaptation per platform | skills/social-publisher/SKILL.md | Check |
| Cookie persistence | skills/social-publisher/SKILL.md | Check |
| Twitter/X support | skills/social-publisher/SKILL.md | Check |
| WeChat support | skills/social-publisher/SKILL.md | Check |
| Xiaohongshu support | skills/social-publisher/SKILL.md | Check |

### BorisWorkflow Features
| Feature | CC Suite Location | Status |
|---------|------------------|--------|
| Environment initialization | skills/boris-workflow/claude-code-setup/SKILL.md | Check |
| CLAUDE.md generation | skills/boris-workflow/claude-code-setup/SKILL.md | Check |
| settings.json generation | skills/boris-workflow/claude-code-setup/SKILL.md | Check |
| Subagent creation | skills/boris-workflow/create-subagent/SKILL.md | Check |
| Agent templates (code-reviewer, etc.) | skills/boris-workflow/create-subagent/SKILL.md | Check |

## Verification Commands
```bash
# Check all skill files exist
echo "=== Feature Coverage Check ==="
for skill_path in \
  "skills/crosscheck/SKILL.md" \
  "skills/social-publisher/SKILL.md" \
  "skills/boris-workflow/claude-code-setup/SKILL.md" \
  "skills/boris-workflow/create-subagent/SKILL.md"; do
  if [ -f "$skill_path" ]; then
    echo "✓ $skill_path exists"
  else
    echo "✗ $skill_path MISSING"
  fi
done
```

## Output Format
```markdown
## Feature Coverage Report

### Summary
- Total features checked: X
- Features covered: Y
- Coverage: Z%

### Details
[Per-project breakdown]
```
