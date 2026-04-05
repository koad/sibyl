# Research: Who Else Has Figured Out What koad:io Figured Out?

**Assigned by:** Juno (via PRIMER.md)
**Date:** 2026-04-04
**Topic:** Prior art on environment-first / pre-invocation context assembly for AI agents

---

## Summary

- The term "context engineering" has swept the field in 2025–2026, but the published work focuses on context managed *during* inference — not assembled *before* invocation from shell state.
- The closest academic prior art is the ICM paper (arxiv:2603.16021, March 2026): filesystem structure as agent orchestration. It validates the filesystem-as-context direction but describes a different mechanism (agent reads files during execution, not pre-loaded at invocation).
- CLAUDE.md / AGENTS.md / GEMINI.md represent industry convergence on the same intuition — project context in a markdown file the agent reads before starting. But these are static project configs, not identity documents assembled from shell environment state.
- **No published work describes the specific koad:io pattern:** shell detects $CWD → reads PRIMER.md → injects as orientation context before model loads. The intelligence-in-the-environment framing, independent of harness or model, appears to be original.
- The closest conceptual ancestor is Unix process environment inheritance (`$ENV` → child inherits parent's context). Nobody seems to have written about this explicitly as an AI design pattern.

---

## Findings

### 1. Context Engineering — Now Mainstream Vocabulary

**Claim:** "Context engineering" is an established, named discipline as of 2025–2026.
**Confidence:** High

Anthropic published ["Effective Context Engineering for AI Agents"](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) treating it as a successor to prompt engineering — the deliberate design of everything that enters the context window. Shopify CEO Tobi Lutke described it as "the art of providing all the context for the task to be plausibly solvable by the LLM." Martin Fowler published ["Context Engineering for Coding Agents"](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html) and ["Harness Engineering"](https://martinfowler.com/articles/harness-engineering.html). The field agrees: getting the right context in front of the model is the core discipline, not prompt phrasing.

**What they mean vs. what koad:io means:** The field mostly describes *what* to put in context (tools, memory, retrieval, history). koad:io's insight is about *when and how* — the shell assembles context before the model starts, from the working directory, as an identity document. That second half is missing from the mainstream definition.

---

### 2. ICM — Closest Academic Prior Art

**Claim:** The Interpretable Context Methodology paper (March 2026) is the closest published work to koad:io's architecture.
**Confidence:** High

[arxiv:2603.16021](https://arxiv.org/abs/2603.16021) — "Interpretable Context Methodology: Folder Structure as Agentic Architecture" — proposes replacing framework orchestration with filesystem structure. Numbered folders represent pipeline stages; plain markdown files carry the prompts and context for each stage. A single orchestrating agent reads the right files at the right moment. No coordination framework needed — the folder hierarchy *is* the workflow.

**Alignment with koad:io:** Same philosophical axis. Filesystem over framework. Plain files over orchestration machinery. The agent's orientation comes from where it is, not from what it was told at build time.

**The gap:** ICM describes the agent reading files *during task execution* to navigate a workflow. koad:io's pattern is a pre-invocation step: the shell reads the entity's PRIMER.md and injects it before the model even starts. The model wakes up already oriented. ICM would call this "preloading the first stage context" but doesn't describe it as an identity/orientation mechanism tied to shell state.

---

### 3. CLAUDE.md / AGENTS.md — Industry Convergence, Wrong Level

**Claim:** Every major AI coding tool has converged on a project-level markdown file read before the model starts.
**Confidence:** High

Claude Code reads `CLAUDE.md`. OpenAI Codex reads `AGENTS.md`. Cursor uses `.cursorrules`. Gemini has `GEMINI.md`. A [GitHub gist by 0xdevalias](https://gist.github.com/0xdevalias/f40bc5a6f84c4c5ad862e314894b2fa6) catalogues the full zoo. The [Augment Code guide](https://www.augmentcode.com/guides/how-to-build-agents-md) and [AddyOsmani's AGENTS.md post](https://addyosmani.com/blog/agents-md/) describe these as "the context file that makes AI coding agents actually work."

**What they got right:** Markdown file in the repo, loaded before inference, tells the agent about project conventions. Same pre-invocation timing as koad:io.

**What they missed:** These are project configs — static, per-repository, about code conventions and tool preferences. They are not identity documents. They don't describe *who the agent is*, what it remembers, who it serves, what pipeline it feeds. koad:io's PRIMER.md is an orientation document for a persistent entity — a different class of artifact. And critically: the file is selected *by the shell based on $CWD*, not discovered by the model. The assembly is outside the model entirely.

---

### 4. Manus and LangChain — Filesystem During Execution

**Claim:** Manus and LangChain Deep Agents treat the filesystem as the primary context layer, but during execution.
**Confidence:** High

Manus's [Context Engineering for AI Agents](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) describes treating the filesystem as "the ultimate context — unlimited in size, persistent by nature, directly operable by the agent itself." Agents write observations and intermediate state to disk; the filesystem *is* working memory.

LangChain's [Deep Agents](https://blog.langchain.com/the-anatomy-of-an-agent-harness/) and their [filesystem context engineering post](https://blog.langchain.com/how-agents-can-use-filesystems-for-context-engineering/) describe agents offloading large context to disk files, writing and reading them as the task evolves.

**The gap:** Both of these describe the agent *using* the filesystem during a task. The filesystem is a tool the running agent reaches for. koad:io's pattern runs before the agent exists — the shell is the reader, not the model. The model never "retrieves" its identity; it *starts with it already in context*.

---

### 5. Harness Engineering — Right Concept, Missing the Pre-Invocation Insight

**Claim:** "Harness engineering" is an emerging discipline, but no published definition captures the $CWD-to-orientation-document pattern.
**Confidence:** Medium

Martin Fowler's ["Harness Engineering for Coding Agent Users"](https://martinfowler.com/articles/harness-engineering.html) defines the harness as "everything except the model" — the code, config, and execution logic that wraps the model and makes it useful. LangChain's ["Anatomy of an Agent Harness"](https://blog.langchain.com/the-anatomy-of-an-agent-harness/) identifies entry paths (CLI, TUI, WebSocket) and describes context preloading at session start. The `AgentBoard` piece ["What Is Harness Engineering?"](https://agentboard.cc/blog/what-is-harness-engineering) summarizes: "the harness gives the agent state, tool execution, feedback loops, and enforceable constraints."

**What they describe:** Harness engineers configure what context the model receives. The pre-session load of CLAUDE.md fits here.

**What they don't describe:** Using the shell working directory as the primary routing signal that determines *which entity's identity file* gets injected. The harness literature assumes a single agent with a configurable system prompt. koad:io's harness routes to different entities based on $CWD — the filesystem path is the entity selector. That's architectural, not just configurational.

---

### 6. No Prior Art: The Specific koad:io Pattern

**Claim:** Shell environment as the context assembly layer — $CWD → read PRIMER.md → inject before invocation — has no published precedent.
**Confidence:** Medium (absence of evidence, not evidence of absence)

The closest intellectual ancestor is **Unix process environment inheritance**: a child process inherits the parent shell's environment, including $PWD, $HOME, and all exported variables. The environment is the process's context, assembled by the shell before the process starts. koad:io is applying this model to AI agent invocation: the shell reads `$CWD/PRIMER.md` and passes it as the agent's startup context.

This has not appeared in the context engineering literature, the ICM paper, the harness engineering discourse, or the CLAUDE.md / AGENTS.md ecosystem. The specific properties that distinguish koad:io's pattern:

1. **Pre-invocation, not in-context retrieval.** The model never "looks up" its identity. It starts with it.
2. **Shell as assembler, not model.** The context read happens outside the inference process entirely.
3. **$CWD as entity selector.** The working directory determines which entity's context is loaded — enabling multi-entity routing from a single harness with no configuration change.
4. **Identity document, not project config.** PRIMER.md describes who the entity is, its team role, its memory, its pipeline position. Not code conventions.
5. **Model-agnostic.** The pattern works with Claude, GPT, Gemini, local models. The intelligence lives in the filesystem, not in the framework.

---

## Confidence Summary

| Claim | Confidence |
|-------|-----------|
| "Context engineering" is established vocabulary | High |
| ICM (2603.16021) is closest academic prior art | High |
| CLAUDE.md/AGENTS.md ecosystem validates pre-invocation loading | High |
| Manus/LangChain treat filesystem as during-execution context | High |
| Harness engineering literature describes pre-load but not $CWD routing | Medium |
| The specific koad:io $CWD→PRIMER.md pattern has no published precedent | Medium |

---

## Sources

- [Interpretable Context Methodology: Folder Structure as Agentic Architecture (arxiv:2603.16021)](https://arxiv.org/abs/2603.16021)
- [Effective Context Engineering for AI Agents — Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Context Engineering for Coding Agents — Martin Fowler](https://martinfowler.com/articles/exploring-gen-ai/context-engineering-coding-agents.html)
- [Harness Engineering for Coding Agent Users — Martin Fowler](https://martinfowler.com/articles/harness-engineering.html)
- [Context Engineering for AI Agents: Lessons from Building Manus](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- [How Agents Can Use Filesystems for Context Engineering — LangChain](https://blog.langchain.com/how-agents-can-use-filesystems-for-context-engineering/)
- [The Anatomy of an Agent Harness — LangChain](https://blog.langchain.com/the-anatomy-of-an-agent-harness/)
- [How to Build Your AGENTS.md — Augment Code](https://www.augmentcode.com/guides/how-to-build-agents-md)
- [Custom Instructions with AGENTS.md — OpenAI Codex](https://developers.openai.com/codex/guides/agents-md)
- [Stop Using /init for AGENTS.md — Addy Osmani](https://addyosmani.com/blog/agents-md/)
- [Notes on AI Agent Rule/Instruction/Context Files — 0xdevalias](https://gist.github.com/0xdevalias/f40bc5a6f84c4c5ad862e314894b2fa6)
- [Building AI Coding Agents for the Terminal — arxiv:2603.05344](https://arxiv.org/abs/2603.05344)
- [Agentic Harness Engineering: LLMs as the New OS — Decoding AI](https://www.decodingai.com/p/agentic-harness-engineering)
- [Context Engineering for AI Agents in Open-Source Software — arxiv:2510.21413](https://arxiv.org/html/2510.21413v1)

---

## Recommendation

**For Juno:** koad:io has a defensible original position. The field has converged on "context engineering" as the vocabulary, and on markdown files as the medium — but no one has described the specific pattern of shell-assembled, $CWD-routed, pre-invocation entity orientation.

Three concrete actions this finding supports:

1. **Write the pattern up publicly.** Name it. "Environment-first agent design" or "pre-invocation context assembly." Publish via Mercury. The ICM paper (March 2026) shows there's academic appetite for filesystem-as-architecture framing. A post from koad narrating the $CWD→PRIMER.md insight in Unix terms would fill a gap in the literature and seed the vocabulary.

2. **Differentiate from CLAUDE.md/AGENTS.md ecosystem.** koad:io's PRIMER.md is not a project config — it's an identity document. The distinction matters for positioning: project configs tell the model how to write code; PRIMER.md tells the model who it is. That's a different product category.

3. **ICM paper is worth a deep read.** It's the closest published framework to koad:io's architectural instincts. Understanding where it diverges (during-execution vs. pre-invocation; workflow orchestration vs. entity identity) sharpens the koad:io story. Route to Veritas for a closer read if needed before publishing.
