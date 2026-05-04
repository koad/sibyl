# PRIMER: Sibyl

Sibyl is the research and market intelligence entity for the koad:io ecosystem. She conducts market analysis, competitive deep-dives, audience profiling, viral pattern research, and technical feasibility scanning — feeding the front of the pipeline. Every brief ends with an actionable conclusion, not just a summary.

---

## Current State

**Active and producing.** Substantial research output from 2026-04-01 onward. Feed signed and live (Phase 2 signed, 21/21 signatures valid). Wednesday research scan protocol encoded. Daily recon protocol added 2026-04-26.

### Research Output (as of 2026-04-24)

Research briefs committed to `research/YYYY-MM-DD-topic.md`. Key completed work:

- Entity flavor market analysis, competitive landscape and positioning
- Sovereign AI adopter profiles, monetization model research
- ICM synthesis: Pre-Invocation Context Assembly
- Viral sprint keystone briefs (2026-04-21/22): competitive landscape + viral patterns — Blue Board, Devin lesson, Pixel Agents precedents that framed Iris's "operational transparency is uncontested" declaration
- Sigchain tip divergence resolution protocol
- PNG/io file format technical assessment
- LLM landscape for entity evaluation (April 2026)
- Voice synthesis, animated portrait landscape
- Developer feedback loop tooling, Kadira APM history
- Opencode telemetry surfaces

### Feed

`feed.atom` — Phase 2 signed (Ed25519, per VESTA-SPEC-101). 21/21 signatures valid as of 2026-04-24.
Verify: `bash bin/verify-feed.sh`. Regenerate: `bash bin/build-feed.sh`.

### Daily Recon Protocol

Daily sweep (~0600 ET / 1000 UTC, cron): influencer signals, AI advancements, adjacent builders, hot engagement windows.
Output: `~/.sibyl/briefs/signals/YYYY-MM-DD-daily-recon.md`. Feeds daily round table on kingofalldata.com.
First real recon: 2026-04-27. Lane rule: Sibyl surfaces. Mercury engages. Faber prioritizes. Iris positions.

### Wednesday Protocol

Weekly external behavior scan: arXiv cs.AI/cs.MA, GitHub Trending, HN, researcher blogs, Fediverse.
Output: `~/.sibyl/briefs/research-scans/YYYY-MM-DD-wednesday-scan.md`. First scan: 2026-04-29.

### Pipeline Position

```
Juno (identifies question) → Sibyl (researches) → Veritas (fact-checks) → Juno (decides)
Sibyl → Iris (brand/positioning implications)
Sibyl → Mercury (research for external communications)
```

---

## How Work Arrives

- **Internal:** Briefs filed to `~/.sibyl/briefs/`; flight plans dispatched by Juno
- **External:** GitHub Issues on `koad/sibyl` (public users and sponsors)
- GitHub Issues as internal intake path deprecated as of 2026-04-17

---

## Blocked / Open

- **fourty4 deepseek-r1 availability** — depends on ollama running on fourty4 (10.10.10.11). Feed-heavy synthesis blocked when not available; Juno harness on Claude covers most research.

---

## Key Files

| File | Purpose |
|------|---------|
| `ENTITY.md` | Stable identity, role, scope, behavioral constraints |
| `research/` | All research briefs, indexed by date |
| `briefs/` | Incoming commissions and Juno-filed briefs |
| `briefs/signals/` | Daily recon briefs (YYYY-MM-DD-daily-recon.md) |
| `briefs/research-scans/INDEX.md` | Wednesday scan index |
| `feed.atom` | Signed Atom feed (Phase 2) |
| `bin/verify-feed.sh` | Feed signature verifier |
| `MEMORY.md` | Entity memory index |
| `memories/` | Long-term entity memory files |
