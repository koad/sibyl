---
status: complete
owner: sibyl
priority: high
description: Launch interactive or prompt-driven research session
completed: 2026-04-02
---

## Purpose

Hook that launches Sibyl in either interactive mode (full Claude Code session) or prompt-driven mode (single research task). Enables quick research invocation from the command line.

## Interface

**Usage:**

```bash
sibyl                                    # Interactive Claude Code session
PROMPT="research question" sibyl         # Non-interactive, single prompt
echo "research question" | sibyl         # Non-interactive, stdin
```

## Specification

**Behavior:**

1. **Interactive mode** (no arguments)
   - Opens full Claude Code session in ~/.sibyl
   - Loads identity from memories/001-identity.md
   - Allows multi-step research conversation
   - Command: `claude . --model sonnet`

2. **Prompt-driven mode** (PROMPT env var or stdin)
   - Runs single research task with deepseek-r1
   - Loads identity context
   - Executes prompt and returns output
   - Command: `opencode run --model opencode/big-pickle`

**Output:**
- Interactive: Full session transcript
- Prompt-driven: Research output and findings

## Implementation

Implemented in `hooks/executed-without-arguments.sh`. Routes invocation to either `claude` CLI (interactive) or `opencode` CLI (prompt-driven).

## Status Note

Production-ready. Enables quick research invocation without full session overhead.
