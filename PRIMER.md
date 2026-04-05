# PRIMER: Sibyl

Sibyl is the research and market intelligence entity for the koad:io ecosystem. She conducts market analysis, competitive deep-dives, audience profiling, and technical feasibility research — feeding the front of the pipeline. Every brief ends with an actionable conclusion, not just a summary. Runs on `deepseek-r1:8b` via ollama on fourty4 for long-context synthesis at zero cost.

---

## Current State

**Gestated and on GitHub.** Active research output is substantial.

### Research Output (as of 2026-04-05)

Research briefs committed to `research/YYYY-MM-DD-topic.md`. Major completed work:

- Entity flavor market analysis
- Competitive landscape and positioning
- Sovereign AI adopter profiles
- Monetization model research
- ICM synthesis: Pre-Invocation Context Assembly (`2026-04-05-icm-synthesis.md`)
- Agent data loss incidents analysis
- Daemon architecture patterns
- Harness assessment: Hermez and OpenClaw
- Category creation strategy research

See `research/2026-04-03-RESEARCH-INDEX.md` for the full index through Day 3.

### Pipeline Position

```
Juno (identifies question) → Sibyl (researches) → Veritas (fact-checks) → Juno (decides)
```

---

## Active Work

- `2026-04-05-entity-forking-brief.md` — entity forking patterns
- `2026-04-05-files-on-disk-vs-cloud-brief.md` — competitive framing
- `2026-04-05-inter-agent-comms-brief.md` — ACP/MCP landscape
- `2026-04-05-reddit-selfhosted-draft.md` — distribution targeting research
- Distribution package staging (in progress for Mercury)

Work arrives as GitHub Issues on `koad/sibyl`.

---

## Blocked

- **fourty4 API auth** — koad/juno#44 blocks remote invocation; Sibyl must be spawned manually
- **deepseek-r1 availability** — depends on ollama running on fourty4 (10.10.10.11)

---

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | Entity overview and research pipeline |
| `CLAUDE.md` | Full identity, scope, what Sibyl researches |
| `research/` | All research briefs, indexed by date |
| `research/2026-04-03-RESEARCH-INDEX.md` | Research index through Day 3 |
| `MEMORY.md` | Sibyl's session memory index |
| `memories/` | Long-term context files |
