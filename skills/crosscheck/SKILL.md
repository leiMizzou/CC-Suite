---
name: crosscheck
description: Cross-check answers from Claude, Codex, and Gemini through a 3-round verification process. Use when you need reliable answers for complex questions, code review, or technical decisions.
argument-hint: <question> [--safe]
---

# /crosscheck - Multi-Model Cross Verification

Cross-check answers from Claude, Codex, and Gemini through a 3-round verification process to get more reliable conclusions.

## Security Modes

CrossCheck supports two security modes for Codex MCP calls:

> **SECURITY WARNING**: Default mode grants full code execution access to Codex.
> For production code review or untrusted environments, always use `--safe` flag.

### Default Mode (Full Access)
- **sandbox**: `danger-full-access` - Codex can execute any code
- **approval-policy**: `never` - No manual approval required
- **Use case**: Trusted environments, personal projects, speed-critical tasks
- **Risk level**: HIGH - Use only in trusted, isolated environments

### Safe Mode (`--safe` flag) - RECOMMENDED for production
When the user includes `--safe` in the command, use restricted settings:
- **sandbox**: `read-only` - Codex can only read files, no writes
- **approval-policy**: `on-failure` - Require approval if commands fail
- **Use case**: Shared environments, production code review, security-sensitive tasks
- **Risk level**: LOW - Recommended for most use cases

**Detection**: If the question/command contains `--safe`, strip it from the question and enable safe mode for all Codex calls.

## Execution Process

Execute the following 3-round verification process:

### Round 1: Independent Answers

Simultaneously query three models with the same question:

1. **Claude Code** (main model): Think and answer independently
2. **Codex MCP**: Call with appropriate security mode
   ```javascript
   // Default mode (no --safe flag)
   mcp__codex__codex({
     prompt: "<question>\n\nPlease analyze from technical and business perspectives, provide your view with specific examples.",
     "approval-policy": "never",
     sandbox: "danger-full-access"
   })

   // Safe mode (when --safe flag is present)
   mcp__codex__codex({
     prompt: "<question>\n\nPlease analyze from technical and business perspectives, provide your view with specific examples.",
     "approval-policy": "on-failure",
     sandbox: "read-only"
   })
   ```
3. **Gemini MCP**: Call with ask-gemini
   ```javascript
   mcp__gemini__ask-gemini({
     prompt: "<question>\n\nPlease analyze from technical and business perspectives, provide your view with specific examples."
   })
   ```

**IMPORTANT**: Call Codex and Gemini in parallel (single message with both tool calls).

**Error Handling**: If a model fails to respond (timeout, error, or unavailable):
- Mark that model as "[UNAVAILABLE]" in the results
- Continue with remaining models (minimum 2 models required)
- Note the degraded mode in the final output
- If only 1 model available, abort and inform the user

Collect all available answers before proceeding to Round 2.

### Smart Short-Circuit (Optional Optimization)

After Round 1, evaluate if all models substantially agree:
- If all three answers convey the same core conclusion with no contradictions
- And the question is factual (not opinion-based)
- Then skip Round 2 and Round 3, directly output the consensus answer

Mark the output as "**Mode: Fast Consensus**" when short-circuiting.

Only proceed to Round 2 when:
- Models disagree on key points
- The question is complex/subjective
- Any model expresses uncertainty

### Round 2: Cross Review

Each model reviews the other two models' answers. Execute these two calls in parallel:

**IMPORTANT - Degraded Mode Adjustments**:
If a model was unavailable in Round 1, dynamically adjust Round 2:
- If **Codex** unavailable: Skip "Codex reviews" step; Gemini reviews only Claude's answer
- If **Gemini** unavailable: Skip "Gemini reviews" step; Codex reviews only Claude's answer
- Adjust the prompt to say "Below is one answer..." instead of "two answers" when applicable
- Only include available answers in the review prompt

1. **Codex reviews Claude + Gemini** (skip if Codex unavailable):
   ```javascript
   mcp__codex__codex({
     prompt: `You are a strict reviewer. Below are two answers about "<question>".

Please review and identify:
1. Points you agree with
2. Points you disagree with or find problematic
3. Important points they missed
4. Any factual errors

---
【Claude's Answer】
<claude_answer>
---
【Gemini's Answer】
<gemini_answer>
---

Please provide your detailed review.`,
     // Use same security mode as Round 1 (default or safe)
     "approval-policy": "never",  // or "on-failure" in safe mode
     sandbox: "danger-full-access"  // or "read-only" in safe mode
   })
   ```

2. **Gemini reviews Claude + Codex** (skip if Gemini unavailable):
   ```javascript
   mcp__gemini__ask-gemini({
     prompt: `You are a strict reviewer. Below are two answers about "<question>".

Please review and identify:
1. Points you agree with
2. Points you disagree with or find problematic
3. Important points they missed
4. Any factual errors

---
【Claude's Answer】
<claude_answer>
---
【Codex's Answer】
<codex_answer>
---

Please provide your detailed review.`
   })
   ```

3. **Claude reviews Codex + Gemini**: Claude (main model) also reviews the other two answers.

**Error Handling for Round 2**:
- If a reviewer model fails, skip that review and continue
- Claude's review is always performed (as main model)
- Note any missing reviews in the output

### Round 3: Synthesize Conclusion

Based on all reviews, produce:

1. **Consensus points**: What all three models agree on
2. **Disputed points**: Where models disagree and why
3. **Corrections**: Revisions to original answers based on reviews
4. **Final conclusion**: Synthesized, more accurate and nuanced conclusion

## Output Format

Display results in this structure:

```markdown
## Cross-Check Results: <question>

**Mode**: Full Verification | Fast Consensus | Degraded (N models)

### Round 1: Independent Answers

| Model | Status | Core View | Key Points |
|-------|--------|-----------|------------|
| Claude | OK | ... | ... |
| Codex | OK/UNAVAILABLE | ... | ... |
| Gemini | OK/UNAVAILABLE | ... | ... |

### Round 2: Cross Review

<!-- In degraded mode, only show reviews from available models -->

#### Codex's Review of Claude + Gemini
<!-- Skip this section if Codex unavailable -->
- **Agrees**: ...
- **Disagrees**: ...
- **Missing**: ...
- **Errors**: ...

#### Gemini's Review of Claude + Codex
<!-- Skip this section if Gemini unavailable -->
- **Agrees**: ...
- **Disagrees**: ...
- **Missing**: ...
- **Errors**: ...

#### Claude's Review of Codex + Gemini
<!-- Always present; adjust title based on available models -->
- **Agrees**: ...
- **Disagrees**: ...
- **Missing**: ...
- **Errors**: ...

### Round 3: Final Conclusion

#### Consensus (All Agree)
- ...

#### Corrections Made
| Original Statement | Corrected To |
|-------------------|--------------|
| ... | ... |

#### Final Answer
...
```

## Logging

After completing the verification, save all intermediate results to:
```
logs/{date}_{topic-slug}.md
```

The log file must include:
- Metadata (date, question ID, consistency rating)
- Model configurations used
- All original answers with thread IDs
- All review comments with thread IDs
- Final synthesized conclusion

## Example Usage

### Default Mode (Full Access)
```
/crosscheck In the era of large models, do we still need to train vertical/domain-specific models?
```

```
/crosscheck What's the best approach for implementing real-time collaboration in a web app?
```

### Safe Mode (Restricted Access)
```
/crosscheck --safe Review this production code - are there any security vulnerabilities?
```

```
/crosscheck --safe Analyze this authentication flow for potential issues
```

### Code Architecture Review
```
/crosscheck Review this code architecture - is microservices the right choice here?
```
