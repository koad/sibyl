# Sibyl — Research & Market Intelligence

**Entity:** sibyl  
**Role:** Research and market intelligence for the koad:io ecosystem  
**Repository:** https://github.com/koad/sibyl

## What Sibyl Does

Sibyl conducts market research, competitive analysis, technical deep-dives, and audience intelligence for the koad:io ecosystem. Sibyl feeds the front of the pipeline — every brief ends with an actionable conclusion, not just a summary. The hard part is knowing what to ignore.

**Infrastructure:** Runs on `deepseek-r1:8b` (128k context) via ollama — long-context synthesis at $0/query on local inference.

## Two-Layer Architecture

```
~/.koad-io/    ← Framework layer (CLI tools, templates, daemon)
~/.sibyl/      ← Entity layer (this repo: identity, skills, research output)
```

## Research Pipeline

```
Juno (identifies question or opportunity)
    ↓
Sibyl (researches: market, competitors, technical landscape, audience)
    ↓
Veritas (fact-checks claims in the brief)
    ↓
Juno (decides and assigns work)
    ↓
[Vulcan / Muse / Mercury / Iris act on the intelligence]
```

Research assignments arrive as GitHub Issues on `koad/sibyl`. Deliverables are committed to `~/.sibyl/research/YYYY-MM-DD-topic.md` and linked back on the issue.

## What Sibyl Researches

| Research Type | Detail |
|---------------|--------|
| Market opportunities | Where the sovereign identity model has traction |
| Competitive landscape | Who else is building here, how koad:io differs |
| Technical landscape | Tools, protocols, standards that matter |
| Audience intelligence | Who sponsors and adopters are, what they care about |
| Strategic questions | Anything Juno needs answered before deciding |

**Every brief includes:**
- Summary — 3–5 bullets, what was found
- Confidence — per-claim: high / medium / low
- Sources — cited, not paraphrased
- Recommendation — what to do with this

## Team Position

```
koad (root)
  └── Juno (orchestrator)
        ├── Sibyl (research) ← this entity
        └── [findings feed Iris, Faber, Vulcan, Mercury]
```

## How to Reach Sibyl

- **Research assignments:** File a GitHub Issue on [koad/sibyl](https://github.com/koad/sibyl)
- **Research output:** `~/.sibyl/research/`

## More Information

See `CLAUDE.md` in this directory for Sibyl's complete runtime instructions and operational constraints.
