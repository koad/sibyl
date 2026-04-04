# Hermez as Agent Harness — Assessment for koad:io Entities

**Date:** 2026-04-04
**Assigned by:** koad (direct session)
**Researcher:** Sibyl
**Status:** Complete

---

## Summary

- Hermes Agent (NousResearch, v0.6.0, released 2026-03-30) is a legitimate open-source agent harness with persistent identity, file-based memory, model-agnostic LLM routing, and per-entity profile isolation — all properties that map well to the koad:io entity model.
- The **profiles mechanism** (via `HERMES_HOME` env var) is architecturally equivalent to the current `~/.sibyl/`, `~/.juno/`, etc. pattern — one harness, many isolated entities on the same machine.
- **SOUL.md** replaces `CLAUDE.md` as the identity anchor; `MEMORY.md` and `USER.md` mirror the existing memory pattern; skills are auto-generated and stored locally.
- **GPG trust bonds are not native** — Hermes has no concept of signed trust chains. This is the most significant gap versus the current Claude Code + SSH hook pattern.
- Recommendation: **Hermes is viable as a parallel harness** for entities that don't require live GPG trust enforcement. Full replacement of Claude Code requires custom GPG hook work — doable but not out-of-the-box.

---

## Findings

### 1. What Hermes Is and How It Works

Hermes Agent is an open-source autonomous agent harness by NousResearch. It wraps any OpenAI-compatible LLM (cloud or local) with a persistent runtime: memory, skill library, scheduled cron jobs, terminal backends, and a plugin/hook architecture.

**Current release:** v0.6.0 (v2026.3.30) — actively maintained, weekly releases.

**Core runtime loop** (`run_agent.py`): provider selection → prompt construction (SOUL.md + context files + memory snapshot) → tool execution → compression → persistence. Synchronous orchestration engine.

**Terminal backends available:**
| Backend | Notes |
|---------|-------|
| local | Default, runs on host shell |
| Docker | Container-isolated execution |
| SSH | Remote server execution directly |
| Daytona | Dev environment cloud |
| Singularity | HPC workloads |
| Modal | Serverless GPU workloads |

The SSH backend is directly relevant — GitClaw on fourty4 could invoke Hermes over SSH with no bespoke hook plumbing.

**Tool library (40+ built-in):** web search, terminal, filesystem, browser automation, vision, image gen, TTS, code execution, subagent delegation, memory tools, task planning, cron scheduling, multi-model reasoning.

---

### 2. How Agents Are Defined and Invoked

**Identity:** `SOUL.md` — placed in `$HERMES_HOME/`, injected verbatim as slot #1 of every system prompt. Scanned for prompt injection before use. This is the direct analogue to `CLAUDE.md` in the current setup. To define "Sibyl" as a Hermes entity: write a SOUL.md with Sibyl's identity, role, behavioral constraints, and commit it.

**Configuration:** `~/.hermes/config.yaml` + `.env` (API keys). Model, terminal backend, compression, TTS, memory limits all set here.

**Context files auto-discovered:** Hermes walks the working directory and loads `AGENTS.md`, `CLAUDE.md`, `.hermes.md`, `SOUL.md`, `.cursorrules` — meaning existing `~/.sibyl/CLAUDE.md` would be picked up without changes.

**Directory layout per entity:**
```
$HERMES_HOME/
├── config.yaml
├── .env
├── SOUL.md          ← entity identity
├── memories/
│   ├── MEMORY.md    ← bounded persistent memory (~2,200 chars)
│   └── USER.md      ← model of the operator (~1,375 chars)
├── skills/          ← auto-generated Python skills
├── hooks/           ← event hooks (pre/post LLM call, session start/end)
├── plugins/         ← Python plugin files
├── cron/            ← scheduled jobs
├── sessions/        ← gateway sessions
└── logs/
```

**Invocation:** `hermes` CLI, or via profile wrapper: `HERMES_HOME=~/.hermes/profiles/sibyl hermes`.

**Plugin lifecycle hooks:** `pre_llm_call`, `post_llm_call`, `on_session_start`, `on_session_end` — Python files dropped into `~/.hermes/plugins/`. This is where custom behavior (e.g., GPG verification, pipeline handoffs) would be wired.

---

### 3. Persistent Identity, File-Based Memory, and GPG Trust Bonds

**Identity survival: YES**
SOUL.md is loaded first at every session start. The entity's character, constraints, and role survive across sessions exactly as with CLAUDE.md. One file, fully sovereign, on-disk.

**File-based memory survival: YES**
`MEMORY.md` and `USER.md` in `$HERMES_HOME/memories/` are injected as frozen snapshots at session start — same pattern as the current `~/.sibyl/memory/` directory. Hermes also maintains a SQLite FTS5 database for deep cross-session recall (searched on-demand, not bulk-injected). Existing `.md` memory files could be migrated with a one-time conversion.

**Memory management:** The agent self-manages MEMORY.md — adds, replaces, and consolidates entries autonomously. This is more aggressive than the current manual memory pattern; may require SOUL.md instructions to constrain behavior.

**GPG trust bonds: NOT NATIVE — significant gap**

No evidence of GPG-aware trust chain, signed-bond verification, or any cryptographic attestation in Hermes's architecture. The current koad:io model uses GPG-signed trust bonds in `~/.sibyl/trust/bonds/` to enforce the `koad → Juno → Sibyl` chain. Hermes has no equivalent.

What Hermes *does* have:
- SOUL.md prompt injection scanning (shallow content filter)
- Profile-level isolation (prevents cross-entity memory contamination)
- Token lock (prevents two profiles sharing the same messaging bot token)

What would need custom work:
- A `pre_llm_call` plugin that reads `$HERMES_HOME/trust/bonds/*.asc`, verifies GPG signatures against the koad trust ring, and halts the session if trust cannot be established
- A session-start hook that logs the trust verification result

This is implementable — roughly 50–80 lines of Python in a plugin file — but it is not provided.

---

### 4. Advantages and Limitations vs Claude Code Harness

#### Advantages

| Capability | Claude Code + SSH hooks | Hermes |
|---|---|---|
| Model agnosticism | Locked to Claude API | Any OpenAI-compatible endpoint, including local Ollama |
| Local LLM routing | Not supported | Ollama, vLLM, llama.cpp, SGLang — single config line |
| Multi-entity on one machine | Manual HERMES_HOME + git repos | Native profiles — first-class, fully isolated |
| SSH execution backend | Via hooks | Native SSH backend, no custom plumbing |
| Skill self-improvement | Not supported | Auto-generates reusable Python skills from experience |
| Cron scheduling | External cron + scripts | Built-in, per-entity, stored in entity home |
| Plugin/hook API | settings.json hooks (shell) | Python plugin API with lifecycle events |
| Context file interop | CLAUDE.md | Reads CLAUDE.md natively — backward compatible |
| Messaging gateway | Not applicable | Optional SMS/Telegram/Discord gateway per entity |

**fourty4 alignment:** Hermes's local LLM support is a direct fit. Pointing entities at `deepseek-r1:8b` on `10.10.10.11` via Ollama is a config change, not an architecture change. Deep research tasks that currently require manual routing could be automated.

#### Limitations

| Gap | Severity | Mitigation |
|---|---|---|
| No native GPG trust | High (architectural) | Custom `pre_llm_call` plugin — 50–80 lines Python |
| Multi-agent cooperation (true inter-agent messaging) | Medium | Currently subagent delegation only; true multi-agent is on roadmap (issue #344), not shipped |
| HERMES_HOME path bug | Low (known, partially fixed) | Issue #892 — some hardcoded paths bypass override; patched in v0.6.0 but monitor |
| Coding agent delegation cloud-locked | Low for Sibyl | Coding delegation (OpenHands/Codex-style) requires Claude/OpenAI; Sibyl doesn't do code execution |
| Early-stage maturity | Medium | v0.6.0, small community, docs have gaps; Claude Code is more battle-tested |
| Self-improving skills can mutate behavior | Medium | Skills auto-generated may drift from intended entity behavior; SOUL.md constraints needed |
| Memory auto-management may clobber entries | Low | Agent rewrites MEMORY.md; important context could be displaced without explicit retention instructions |

---

### 5. Integration Complexity

**Estimated integration path for koad:io entities:**

**Low complexity (1–2 hours each):**
- Create one Hermes profile per entity: `HERMES_HOME=~/.hermes/profiles/sibyl`
- Migrate `~/.sibyl/CLAUDE.md` → `$HERMES_HOME/SOUL.md` (copy + reformat)
- Copy existing memory `.md` files into `$HERMES_HOME/memories/`
- Configure `config.yaml` with Anthropic or Ollama endpoint

**Medium complexity (half-day):**
- Wire GPG trust verification as a `pre_llm_call` plugin
- Map existing Claude Code hooks (session start, commit, pipeline handoff) to Hermes plugin events
- Test HERMES_HOME isolation — confirm no cross-profile memory bleed

**High complexity (multi-day, deferred):**
- True inter-agent messaging between Hermes entities (Juno → Sibyl task delegation via Hermes inter-agent bridge) — depends on roadmap issue #344 shipping
- GitClaw integration: adapt wakeup triggers to invoke `HERMES_HOME=... hermes --task "..."` instead of Claude Code

**Migration risk:** Low for Sibyl specifically. Sibyl does not execute code, does not require coding agent delegation, and primarily reads/writes files + makes web requests — all well-covered by Hermes's tool set.

---

## Confidence

| Claim | Confidence | Source |
|---|---|---|
| Profiles mechanism isolates entities via HERMES_HOME | High | NousResearch docs, issue #892 |
| SOUL.md is primary identity, loaded every session | High | NousResearch docs: personality/SOUL.md page |
| MEMORY.md + USER.md are file-based, locally stored | High | NousResearch docs: persistent memory page |
| GPG trust not native | High | No mention in docs, GitHub issues, or community; absent from architecture |
| Ollama/local LLM supported | High | Multiple guides, config docs |
| True inter-agent messaging not yet shipped | High | GitHub issue #344 explicitly states it's a planned feature |
| Plugin lifecycle hooks (pre/post LLM call) available | High | v0.5.0 release notes, features overview |
| HERMES_HOME path bug partially fixed | Medium | Issue #892 open with fix committed; verify on latest |

---

## Sources

- [Hermes Agent Homepage — NousResearch](https://hermes-agent.nousresearch.com/)
- [GitHub — NousResearch/hermes-agent](https://github.com/nousresearch/hermes-agent)
- [Hermes Docs: Personality & SOUL.md](https://hermes-agent.nousresearch.com/docs/user-guide/features/personality/)
- [Hermes Docs: Persistent Memory](https://hermes-agent.nousresearch.com/docs/user-guide/features/memory/)
- [Hermes Docs: Profiles — Running Multiple Agents](https://hermes-agent.nousresearch.com/docs/user-guide/profiles/)
- [Hermes Docs: Configuration](https://hermes-agent.nousresearch.com/docs/user-guide/configuration/)
- [Hermes Docs: Features Overview](https://hermes-agent.nousresearch.com/docs/user-guide/features/overview/)
- [Hermes Docs: Memory Provider Plugins](https://hermes-agent.nousresearch.com/docs/developer-guide/memory-provider-plugin/)
- [Hermes Docs: Webhooks](https://hermes-agent.nousresearch.com/docs/user-guide/messaging/webhooks/)
- [GitHub Issue #344: Multi-Agent Architecture](https://github.com/NousResearch/hermes-agent/issues/344)
- [GitHub Issue #892: HERMES_HOME Path Override Bug](https://github.com/NousResearch/hermes-agent/issues/892)
- [GitHub Issue #879: Local model routing for auxiliary tasks](https://github.com/NousResearch/hermes-agent/issues/879)
- [Release v0.6.0 (v2026.3.30)](https://github.com/NousResearch/hermes-agent/releases/tag/v2026.3.30)
- [Hermes Agent + Ollama Guide](https://medium.com/data-science-collective/hermes-agent-ollama-fastest-way-to-install-locally-f2b13d958e32)
- [OpenClaw vs Hermes: Persistent AI Agents Compared — The New Stack](https://thenewstack.io/persistent-ai-agents-compared/)
- [Claude Cowork vs Hermes Agent Comparison — Eigent](https://www.eigent.ai/blog/claude-cowork-vs-hermes-agent)
- [The Quiet Shift: Why Hermes Is Gaining Ground — Medium](https://medium.com/@kunwarmahen/the-quiet-shift-in-ai-agents-why-hermes-is-gaining-ground-beyond-openclaw-6364df765d3a)

---

## Recommendation

**Juno should run a bounded pilot, not a full replacement.**

Deploy Hermes for Sibyl specifically, in parallel with the current Claude Code harness:

1. Create `~/.hermes/profiles/sibyl` with Sibyl's SOUL.md (migrated from CLAUDE.md) and point the model at Ollama/deepseek-r1 on fourty4 for long-context research tasks.
2. Build the GPG trust verification plugin (single Python file, `pre_llm_call` hook) before any entity that touches trust-sensitive operations is migrated.
3. Do not migrate Juno or Veritas until inter-agent messaging (issue #344) ships — the current subagent delegation model is throwaway children with no shared state, which would break the Juno→Sibyl→Veritas pipeline structure.
4. Hermes profiles give us per-entity isolation with zero infrastructure overhead — this alone is worth the migration for any entity that doesn't depend on GPG trust enforcement.

**The sovereign identity principle survives Hermes.** Files on disk, keys in `~/.hermes/profiles/<entity>/`, no vendor kill switch. That is the right foundation.
