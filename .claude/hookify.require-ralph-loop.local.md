---
name: require-ralph-loop
enabled: true
event: prompt
pattern: (workflow\s*5|Phase\s*3|DEVELOP.*阶段|自主开发|开始开发|实现功能)
action: warn
---

## Ralph Loop Reminder

You are about to enter Phase 3 (DEVELOP) of the Ultimate Workflow.

**STOP! Before writing any code, you MUST:**

1. Check Ralph Loop status:
   ```bash
   # Check if ralph-loop plugin is enabled
   cat ~/.claude/settings.json | grep ralph
   ```

2. If not enabled, enable it:
   ```bash
   /setup-ralph-loop --enable
   ```

3. Start development with Ralph Loop:
   ```bash
   /ralph-loop "
   ## Task
   {Task description based on CrossCheck conclusions}

   ## Requirements
   1. {Requirement 1}
   2. {Requirement 2}

   ## Acceptance Criteria
   - Tests pass
   - Type check passes
   - {Other criteria}

   Output <promise>DONE</promise> when complete
   " --completion-promise "DONE" --max-iterations 30
   ```

**DO NOT manually write code without Ralph Loop in Phase 3!**

Ralph Loop provides:
- TDD-driven development
- Autonomous iteration until completion
- Self-correcting on test failures
