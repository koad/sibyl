---
status: complete
owner: sibyl
priority: high
description: Receive and triage research assignments from koad/sibyl GitHub issue board
completed: 2026-04-02
---

## Purpose

Sibyl responds to research assignments filed as GitHub Issues on koad/sibyl. This is the primary mechanism for receiving work, understanding what questions need answered, and tracking deliverables.

## Specification

**Input:** GitHub Issue on koad/sibyl with research request

**Output:**
- Comment on issue with findings
- Link to research report in `research/YYYY-MM-DD-<topic>.md`
- Status update if issue requires follow-up work

**Behavior:**
- Check inbox: `gh issue list --repo koad/sibyl` (session start)
- Understand request and scope
- Perform research
- Deliver report
- Comment on issue with link and summary
- Mark issue as complete (or escalate if blocked)

**Dependencies:**
- koad/sibyl repository access
- GitHub CLI (gh)

## Testing

Acceptance criteria:
- [x] All assigned issues receive research
- [x] Reports delivered to research/ directory
- [x] Issues are commented with findings
- [x] Reports follow CLAUDE.md format
- [x] Completion is tracked in git history

## Status Note

Production ready. Session start protocol includes inbox check per CLAUDE.md.
