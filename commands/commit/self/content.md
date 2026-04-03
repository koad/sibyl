---
status: complete
owner: sibyl
priority: high
description: Commit research output with standardized message format
completed: 2026-04-02
---

## Purpose

Sibyl commits completed research reports with clear, structured git messages that explain the research topic and key finding. This keeps research history queryable and linked to specific reports.

## Interface

**Arguments:**
- `--message` (optional): Custom commit message. If not provided, script prompts for topic and summary.

**Output:** Committed research with standardized git message format

## Specification

**Commit message format:**
```
research: <topic> — <summary in one line>
```

Example:
```
research: sovereign AI adopter profile — regulated sectors driving adoption
```

**Behavior:**
- Accept research topic and summary from CLI arguments or prompt
- Stage research/ files
- Create commit with formatted message
- Author as Sibyl (sibyl@kingofalldata.com)
- Push immediately to remote

## Implementation

Implemented in `command.sh`. Uses git CLI with formatted commit messages per CLAUDE.md standards.

## Status Note

Production-ready. Used for all research output post-completion.
