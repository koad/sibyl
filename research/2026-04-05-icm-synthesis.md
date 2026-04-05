# ICM Synthesis: Interpretable Context Methodology vs. koad:io Filesystem-as-Context

**Assigned by:** Juno (koad/juno#54)
**Date:** 2026-04-05
**Paper:** Interpretable Context Methodology — arxiv:2603.16021
**Authors:** Jake Van Clief (Eduba), David McDermott (University of Edinburgh)
**Prior context:** `~/.sibyl/research/2026-04-04-filesystem-as-context.md`

---

## Summary

- ICM is the closest published academic work to koad:io's architectural instincts: filesystem structure over orchestration frameworks, plain markdown as the interface, Unix composability as philosophical grounding.
- The overlap is real and validates the direction — ICM demonstrates adoption at three institutions and a practitioner study of 33 users.
- The divergence is architectural and significant: ICM describes an agent reading files *during* task execution to navigate a staged pipeline. koad:io assembles context *before the model loads*, from shell state ($CWD), and the assembled context is an identity document, not a workflow specification.
- ICM introduces a five-layer context hierarchy; koad:io implicitly does something similar but the critical layer — Layer 0 entity identity — is handled outside the model entirely, by the shell.
- **Recommendation:** Cite ICM in the PRIMER.md post. Engage publicly. Name the divergence precisely. The "pre-invocation, shell-assembled entity identity" pattern is koad:io's to claim — ICM makes that clearer, not less clear.

---

## 1. ICM Core Claims

**Thesis:** For sequential, human-reviewed workflows, filesystem-based orchestration eliminates framework overhead without sacrificing capability.

### The Five-Layer Hierarchy

ICM proposes replacing agent orchestration frameworks with structured folder organization:

| Layer | Content | Role |
|-------|---------|------|
| **0** | `CLAUDE.md` (workspace root) | Global workspace identity |
| **1** | Root `CONTEXT.md` | Task sequencing / routing |
| **2** | Stage `CONTEXT.md` | Stage contract: inputs, process, outputs |
| **3** | Reference materials | Stable constraints, design systems, voice guides |
| **4** | Working artifacts | Per-run content; previous stage outputs |

The folder hierarchy *is* the workflow. No orchestration code needed. A single primary agent reads Layer 0–2 to understand where it is in the pipeline, then loads only the Layer 3–4 content relevant to the current stage.

### Key Innovations ICM Claims

1. **Prevention over compression.** Rather than loading everything into context and compressing, ICM prevents irrelevant content from loading at all. Typical stage context: 2,000–8,000 focused tokens vs. 30,000–50,000 in monolithic approaches. This directly addresses "lost in the middle" degradation.

2. **Inputs table as explicit contract.** Each stage's `CONTEXT.md` declares exactly which files to load — explicit, editable, auditable. No implicit retrieval.

3. **Observability by design.** Every intermediate output is an inspectable file. Interpretability is structural, not retrofitted.

4. **Non-technical practitioner access.** Plain text markdown means non-developers can modify pipelines without engineering support. Validated: 33 practitioners, deployed at University of Edinburgh, ICR Research, Academy of International Affairs (Bonn).

### Philosophical Grounding

ICM explicitly cites Unix pipelines (McIlroy, 1978), multi-pass compilation (Aho et al.), literate programming (Knuth), and mixed-initiative systems (Horvitz). The authors are aware they are extending Unix composition philosophy into AI agent design.

---

## 2. Where ICM and koad:io Align

The convergence is substantial. Both systems arrived at the same philosophical position:

| Principle | ICM | koad:io |
|-----------|-----|---------|
| Filesystem over framework | Yes — folder structure *is* the pipeline | Yes — $CWD routes to entity, filesystem holds identity |
| Plain markdown as interface | Yes — all context, contracts, outputs | Yes — PRIMER.md, CLAUDE.md, research/ |
| Unix composability | Explicitly cited (McIlroy 1978) | Implicitly applied; $CWD→context mirrors process environment inheritance |
| Context loaded at stage boundary | Yes — agent loads appropriate CONTEXT.md | Yes — PRIMER.md loaded at invocation, not retrieved |
| No proprietary framework required | Yes — Claude Code is the harness | Yes — model-agnostic, harness-agnostic |
| Intermediate outputs as edit surface | Yes — every output/ folder is inspectable | Yes — research/, memories/ are human-readable |

The fact that two independent teams reached the same architectural axis (filesystem-first, markdown-native, framework-free) is meaningful signal. ICM's practitioner study and institutional deployments validate that this direction is not just theoretically coherent — it works in production.

---

## 3. The Key Divergence

**This is the part that matters for positioning.**

### ICM: Agent Reads Files During Execution

In ICM, the agent is already running when it reads context. The execution loop is:

```
model invoked → reads CLAUDE.md (Layer 0) → reads CONTEXT.md (Layer 1)
→ reads stage CONTEXT.md (Layer 2) → loads reference materials (Layer 3)
→ processes working artifacts (Layer 4) → produces output → human reviews
```

The agent is the reader. The model performs the file reads as part of task execution. This is explicit in ICM's design: the Inputs table specifies what the model should load, and the model loads it.

Even Layer 0 — `CLAUDE.md`, the global workspace identity — is read by the model *after* invocation. The model starts, reads CLAUDE.md to understand what workspace it's in, then proceeds. The shell is not involved.

### koad:io: Shell Assembles Before Model Loads

koad:io's pattern runs before the model exists:

```
cd ~/.sibyl/ → shell hook reads $CWD/PRIMER.md
→ injects as orientation context → model invoked with identity already loaded
```

The shell is the reader. The model never performs a "read my identity file" action. It starts with the identity already in context — as if it had always known who it was. This is the Unix process environment inheritance model applied to AI invocation: `$PWD/PRIMER.md` is to the agent what `$HOME/.bashrc` is to a shell process.

### The Precise Distinction

| Dimension | ICM | koad:io |
|-----------|-----|---------|
| **When context loads** | During task execution | Before model invocation |
| **Who reads the file** | The model (tool call or read action) | The shell (hook, outside inference) |
| **What Layer 0 contains** | Workspace identity (what project is this?) | Entity identity (who am I, what team do I serve?) |
| **Routing mechanism** | Single workspace, one pipeline | $CWD selects which entity's PRIMER.md loads |
| **Multi-entity support** | Not described | Yes — `cd ~/.sibyl/` vs `cd ~/.juno/` routes to different entities from the same harness |
| **Model awareness of mechanism** | Model knows it is reading context files | Model has no awareness of pre-invocation assembly |

### Why the Distinction Is Not Trivial

The koad:io pattern has a property ICM's doesn't: **the model cannot be confused about who it is by the context it reads during execution.** In ICM, a model that reads the wrong CONTEXT.md (a bug in the workflow, a misconfigured Inputs table) will proceed with incorrect context. In koad:io's pattern, entity identity is injected by the shell before inference begins — it is structurally prior to anything the model does. The model's identity is not a retrieval artifact; it is a precondition.

A second property: **$CWD as entity selector.** ICM has no equivalent. In koad:io, `cd ~/.sibyl/` and `cd ~/.juno/` invoke different entities — Sibyl the research agent vs. Juno the decision agent — from the same harness, with no configuration change. The filesystem path is the entity selector. ICM assumes a single agent working within one workspace. koad:io is a fleet of entities routed by working directory.

### What ICM Does Not Describe

1. Pre-invocation context assembly (the shell doing the read, not the model)
2. $CWD as entity routing signal
3. Identity documents (who am I, what pipeline role do I serve) vs. workspace/project configs (what is this project)
4. Multi-entity harness routing from a single binary

These absences are not oversights — they are scope differences. ICM is focused on workflow orchestration within a workspace. koad:io is focused on agent identity and fleet coordination. The two problems overlap but are not the same problem.

---

## 4. ICM's Layer 0 vs. koad:io's PRIMER.md — The Artifact Comparison

ICM's `CLAUDE.md` at Layer 0 is the closest artifact to koad:io's PRIMER.md. Worth comparing directly:

**ICM Layer 0 (`CLAUDE.md`):**
- Workspace-scoped (this folder, this project)
- Describes the workspace's purpose, tools available, conventions
- Read by the model during execution
- Static across entities — one workspace, one CLAUDE.md

**koad:io PRIMER.md:**
- Entity-scoped (this agent, this identity)
- Describes who the entity is: name, role, team position, memory, pipeline function, trust chain
- Injected by the shell before model invocation
- Dynamic across $CWD — different PRIMER.md for each entity directory

ICM's Layer 0 answers: "What is this workspace?"
koad:io's PRIMER.md answers: "Who am I?"

These are categorically different questions. ICM's answer is environmental; koad:io's is existential. That distinction produces a different class of agent behavior: an agent that knows *who it is* before it knows *what to do* is structurally different from one that figures out its context from the workspace it finds itself in.

---

## Confidence Assessment

| Claim | Confidence |
|-------|-----------|
| ICM's core claims accurately summarized from paper | High |
| ICM describes agent-reads-during-execution (not pre-invocation) | High — explicit in paper's execution model |
| koad:io's pre-invocation shell assembly has no equivalent in ICM | High |
| $CWD-based multi-entity routing is not in ICM | High |
| The distinction "shell as assembler, model as reader" is meaningful | High |
| This distinction is novel in the published literature | Medium (absence of evidence) |

---

## Sources

- [Interpretable Context Methodology: Folder Structure as Agentic Architecture — arxiv:2603.16021](https://arxiv.org/abs/2603.16021)
- [Prior art research — ~/.sibyl/research/2026-04-04-filesystem-as-context.md](../2026-04-04-filesystem-as-context.md)
- [koad:io PRIMER.md pattern — multiple entities, ~/.*/PRIMER.md](../../)

---

## Recommendation

**Engage publicly. Cite ICM. Name the divergence.**

Three specific actions:

### 1. Cite ICM in the PRIMER.md post
When Mercury publishes the PRIMER.md pattern writeup, cite ICM as the closest peer work. The citation should be generous and specific — ICM is doing serious work. The framing: "ICM and koad:io arrived at the same philosophical axis from different directions. ICM solved workflow orchestration; koad:io solved agent identity. The pre-invocation layer is where they diverge."

This positions koad:io as in conversation with the literature, not isolated from it. It's also accurate.

### 2. Articulate the three-part distinction in the post
Name it precisely. The koad:io pattern has three properties ICM doesn't:
- **Pre-invocation assembly** — the shell reads PRIMER.md before the model loads
- **Shell as assembler** — context assembly happens outside inference entirely
- **$CWD as entity selector** — working directory routes to different entities from the same harness

These three properties together constitute the specific koad:io insight. ICM's paper makes this easier to articulate, not harder — the contrast is clarifying.

### 3. Consider contacting the ICM authors
Van Clief and McDermott are working in the same conceptual space. The MWP (Model Workspace Protocol) they introduce is a generalization that koad:io's pattern could inform. They may not be aware that the pre-invocation layer is a distinct architectural choice with different properties. A note to them — pointing at the paper, acknowledging the convergence, noting the divergence — is a reasonable outreach. Route to Juno to decide.

**Do not wait on verification.** ICM's claims are directly readable from the paper. The overlap and divergence are both high-confidence. The recommendation stands without a Veritas pass.
