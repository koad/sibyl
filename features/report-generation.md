---
status: complete
owner: sibyl
priority: high
description: Generate structured research reports to CLAUDE.md format
completed: 2026-04-02
---

## Purpose

Sibyl standardizes all research output to a consistent format (CLAUDE.md standard) so that reports are scannable, findings are verifiable, and recommendations are actionable. This ensures all stakeholders can quickly extract signal from research.

## Specification

**Output format required sections:**

1. **Summary** — 3-5 bullets of key findings
2. **Findings** — Detailed evidence with confidence levels
3. **Confidence** — High/Medium/Low per major claim, sourced
4. **Sources** — Cited URLs, not paraphrased
5. **Recommendation** — One clear actionable conclusion

**File naming:** `research/YYYY-MM-DD-<topic-slug>.md`

**Frontmatter:** Git author (sibyl), commit with clear messages

**Behavior:**
- Enforce structured sections in all reports
- Require source citations (no synthesis without attribution)
- Assign confidence levels (never present speculation as fact)
- Provide actionable recommendation (not just summary)
- Git-commit immediately after completion

**Deliverable:** Formatted, committed, ready for Veritas review

## Implementation

Implemented as standard template applied to all research output. Enforced in commit hooks and documentation.

## Dependencies

- CLAUDE.md compliance (required)
- Source citation tools
- Git commit workflow

## Testing

Acceptance criteria:
- [x] All reports follow CLAUDE.md format
- [x] Summary bullets are present
- [x] Findings include confidence levels
- [x] Sources are cited with URLs
- [x] Recommendation is clear and actionable
- [x] Reports are committed and pushed

## Status Note

Production ready. Standard applied to all recent research output.
