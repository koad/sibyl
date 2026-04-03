---
status: draft
owner: sibyl
priority: medium
description: Self-check research claims before delivery; escalate to Veritas for formal review
started: 2026-04-03
---

## Purpose

Sibyl spot-checks its own research for accuracy and sources before delivery. For critical claims, research is escalated to Veritas (koad/veritas) for formal fact-checking before reaching Juno.

## Specification

**Input:** Completed research report (before commit)

**Output:**
- Verification checklist (sources verified, claims supported, confidence levels appropriate)
- Issue filed on koad/veritas for formal fact-check (if critical findings)
- Research report ready for delivery

**Behavior:**
- Verify all sources are accessible and accurate
- Cross-reference claims against multiple sources where possible
- Flag speculative statements
- Escalate regulatory or compliance claims to Veritas
- Include verification notes in git commit

**Deliverable:** Verified research with confidence, or escalation to Veritas

## Implementation

(Planned — currently sources are cited inline; formal verification process TBD)

## Dependencies

- Veritas availability for formal fact-checks
- Source verification tooling

## Testing

Acceptance criteria:
- [ ] Sources are verified to support claims
- [ ] No speculative statements presented as fact
- [ ] Confidence levels are appropriate
- [ ] Critical claims routed to Veritas
- [ ] Verification notes in commit message

## Status Note

Planned. Currently follows best-effort citation. Formal process to be defined with Veritas.
