---
title: "OpenClaw Harness Assessment: pi by Mario Zechner"
date: 2026-04-04
status: completed
confidence: high
issue: koad/sibyl#13
tags: [openclaw, pi, harness, hooks, entities, hermez, architecture]
---

## Summary

- The harness is called **pi** (not "pie") — `@mariozechner/pi-coding-agent` by Mario Zechner, repo: `github.com/badlogic/pi-mono`, site: `pi.dev`
- OpenClaw bundles four pi packages as dependencies: `pi-ai`, `pi-agent-core`, `pi-coding-agent`, `pi-tui`
- Hooks are TypeScript extensions loaded via `jiti` (no compile step), hot-reloadable, subscribing to named lifecycle events via `pi.on("event_name", handler)`
- The SDK mode (`createAgentSession()`) allows any Node.js process to embed pi — OpenClaw already uses this pattern to route I/O through 20+ messaging platforms
- For koad:io entities (Hermez, Claude Code), pi's SDK is a viable harness: clean API, typed events, parallel tool execution, mid-stream steering, and the ACP protocol for inter-agent messaging

---

## Findings

### 1. What It Is Called

The harness is **pi** by Mario Zechner (creator of libGDX). The name koad remembered as "pie" is almost certainly "pi."

**NPM packages (all at version 0.63.1 in OpenClaw 2026.3.28):**

| Package | Role |
|---------|------|
| `@mariozechner/pi-ai` | Unified LLM API — 20+ providers, tool-calling, thinking, cost tracking |
| `@mariozechner/pi-agent-core` | Stateful agent loop — event streaming, tool execution, steering |
| `@mariozechner/pi-coding-agent` | Full coding harness — extensions, skills, sessions, TUI, SDK |
| `@mariozechner/pi-tui` | Terminal UI components |

**Repository:** `github.com/badlogic/pi-mono` (monorepo)
**Website:** `pi.dev` (formerly shittycodingagent.ai)

OpenClaw's own description: "See openclaw/openclaw for a real-world SDK integration." — pi's README explicitly cites OpenClaw as the reference integration.

---

### 2. Architecture

pi is a three-layer stack:

```
pi-coding-agent (sessions, extensions, skills, SDK)
        │
pi-agent-core (Agent class, tool execution, event streaming)
        │
pi-ai (multi-provider LLM API with unified streaming)
```

**pi-ai** handles the raw LLM layer: provider detection, streaming, tool call parsing, thinking/reasoning tokens, cost tracking. Supports Anthropic, OpenAI, Google, Ollama (and any OpenAI-compatible), Bedrock, Vertex, and more.

**pi-agent-core** wraps the LLM loop into a stateful `Agent` object:
- Maintains conversation messages
- Executes tool calls (`parallel` mode by default: preflight sequential, execute concurrent)
- Emits typed events: `agent_start`, `turn_start/end`, `message_start/update/end`, `tool_execution_start/update/end`
- Exposes `beforeToolCall` and `afterToolCall` hooks at the core level
- Supports steering (mid-stream message injection) and follow-up queuing

**pi-coding-agent** adds the full application harness:
- Sessions — persistent, forking, tree navigation, compaction
- Extensions — TypeScript modules with `pi.on()` event hooks (see section 3)
- Skills — Markdown + command capability packages, auto-loaded or manually invoked
- Prompt templates — reusable prompts
- SDK mode — `createAgentSession()` for embedding in any Node.js app
- CLI mode — interactive terminal (`pi`)

**OpenClaw's usage pattern:** OpenClaw uses `pi-coding-agent` in SDK mode, calling `createAgentSession()` and routing I/O from messaging platforms (Discord, Slack, WhatsApp, Telegram, iMessage, etc.) through `session.prompt()`. The workspace `.md` files (`SOUL.md`, `AGENTS.md`, `MEMORY.md`) are pi context files — OpenClaw reads these at startup just as pi's `AGENTS.md` / `CLAUDE.md` system works.

---

### 3. How Hooks Are Defined and Triggered

pi's hook system is its **extensions API** — TypeScript modules loaded at startup (and hot-reloadable via `/reload`).

**Definition:** Create a `.ts` file, export a default function receiving `ExtensionAPI`:

```typescript
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("tool_call", async (event, ctx) => {
    if (event.toolName === "bash" && event.input.command.includes("rm -rf")) {
      return { block: true, reason: "Blocked: destructive command" };
    }
  });

  pi.on("before_agent_start", async (event, ctx) => {
    return {
      systemPrompt: event.systemPrompt + "\n\nAdditional context...",
      message: { customType: "context-inject", content: "...", display: false },
    };
  });
}
```

Extensions are loaded via `jiti` — TypeScript works without a build step.

**Auto-discovery locations:**

| Path | Scope |
|------|-------|
| `~/.pi/agent/extensions/*.ts` | Global |
| `~/.pi/agent/extensions/*/index.ts` | Global (subdirectory) |
| `.pi/extensions/*.ts` | Project-local |
| `.pi/extensions/*/index.ts` | Project-local |
| `settings.json` `extensions` array | Explicit paths |

**Full event lifecycle:**

```
session_directory → session_start
  ↓
user input
  → input (intercept/transform)
  → before_agent_start (inject context, modify system prompt)
  → agent_start
  → turn_start
    → context (modify messages before LLM call — prune, inject)
    → before_provider_request (inspect/replace raw provider payload)
    → [LLM responds]
    → tool_execution_start
    → tool_call ← CAN BLOCK, CAN MUTATE INPUT
    → tool_execution_update
    → tool_result ← CAN MODIFY RESULT
    → tool_execution_end
  → turn_end
  → agent_end
  ↓
session_shutdown
```

**Blocking a tool call:**
```typescript
pi.on("tool_call", async (event, ctx) => {
  if (event.toolName === "write" && event.input.path.includes(".env")) {
    return { block: true, reason: "Protected path" };
  }
  // Mutate input instead:
  event.input.command = `source ~/.profile\n${event.input.command}`;
});
```

**Modifying a tool result:**
```typescript
pi.on("tool_result", async (event, ctx) => {
  return { content: [...event.content, { type: "text", text: "[audited]" }] };
});
```

**Injecting context before each LLM call:**
```typescript
pi.on("context", async (event, ctx) => {
  const filtered = event.messages.filter(m => !isStale(m));
  return { messages: filtered };
});
```

**At the `pi-agent-core` level**, `beforeToolCall` and `afterToolCall` are lower-level equivalents passed directly to `createAgentSession()` or `new Agent()` — useful for OpenClaw's platform-level controls rather than per-project extension hooks.

---

### 4. Could It Serve as a Harness for koad:io Entities?

**Short answer: Yes — with caveats per entity.**

#### For Hermez (messaging bridge replacement / agent)

Hermez is already conceptually similar to OpenClaw's model. OpenClaw demonstrates exactly how to use pi's SDK for a messaging bridge — the pattern is proven on fourty4 today.

A Hermez-as-pi-session would:
1. Call `createAgentSession()` with koad:io entity workspace (CLAUDE.md as pi context file)
2. Route inbound messages as `session.prompt()` calls
3. Subscribe to agent events to stream output back to channels
4. Use extensions for koad:io-specific hooks (trust checks, routing to other entities, etc.)

**Confidence: High.** This is exactly what OpenClaw does.

#### For Claude Code (as a subordinate/peer agent)

Claude Code and pi are architecturally similar but not identical:
- Claude Code hooks are **shell commands** in `settings.json`, executed by the harness
- pi hooks are **TypeScript extensions** with full Node.js access
- Claude Code's `PreToolUse` / `PostToolUse` maps to pi's `tool_call` / `tool_result`
- Claude Code's `Stop` / `SubagentStop` maps loosely to `agent_end`

They are **not directly compatible runtimes**, but pi could *coordinate* Claude Code as:
1. A **tool** registered in pi (pi calls Claude Code via its API/CLI)
2. A **peer agent** via the ACP protocol (`@agentclientprotocol/sdk` is already in OpenClaw's dependencies — this is the Agent Client Protocol)
3. A **separate session** that pi's extension dispatches work to

**Confidence: Medium.** Pi is not a drop-in replacement for Claude Code's harness, but the SDK makes it straightforward to use pi as a coordinator that spawns/orchestrates Claude Code instances.

#### For deepseek-r1 on fourty4

pi-ai explicitly supports "Any OpenAI-compatible API: Ollama, vLLM, LM Studio, etc." — deepseek-r1 via Ollama on fourty4 is natively supported. No bridging needed.

---

### 5. Notable Advantages for the Hook-Heavy koad:io Architecture

**1. TypeScript extensions, no build step**
Extensions load via `jiti` — write TypeScript directly, hot-reload with `/reload`. No compilation, no restart. Claude Code hooks are shell commands; pi hooks are full Node.js with npm packages.

**2. Hot reload**
`/reload` reloads extensions in a live session. Critical for iterating on hook logic without losing conversation context.

**3. Two-layer hook system**
- **Extension level** (`pi.on("tool_call")`) — per-project, per-agent, composable
- **Core level** (`beforeToolCall`/`afterToolCall` in `createAgentSession()`) — platform-wide, runs before extensions

**4. Parallel tool execution with ordered results**
Default `parallel` mode: tools preflight sequentially (so `tool_call` hooks run in order), execute concurrently, results emitted in source order. Correct for audit logging while still fast.

**5. Steering and follow-up queuing**
`session.steer()` — inject a message mid-turn, after current tool calls finish
`session.followUp()` — queue work for after agent completes current prompt
This maps cleanly to Juno interrupting a running Sibyl session.

**6. `sendHookMessage()`**
Inject messages from *outside* the session — useful for external triggers (GitClaw waking Sibyl, a cron firing a heartbeat, Juno delegating a sub-task). This is the external hook integration point.

**7. ACP protocol already integrated**
`@agentclientprotocol/sdk` at version `0.17.0` is in OpenClaw's dependencies. This is the Agent Client Protocol — a standard for inter-agent messaging. If koad:io entities adopt ACP, they can communicate through a shared protocol rather than ad-hoc GitHub issues.

**8. `context` event for memory management**
The `context` hook fires before every LLM call and can prune/rewrite the message list. This is where entity-specific compaction, memory injection (from `~/.sibyl/memory/`), and context routing would live — without touching the agent core.

**9. Multi-provider routing**
A single pi session can hand off mid-conversation to a different model: `agent.setModel()` changes provider on the fly. Sibyl could start a session on Claude Sonnet and switch to deepseek-r1 for the heavy reasoning pass.

**10. Session tree navigation**
pi's `/tree` / `fork` system creates branching conversation trees. Useful for Sibyl running parallel research paths on the same question without losing context.

---

## Confidence

| Claim | Confidence | Source |
|-------|-----------|--------|
| Harness is pi by Mario Zechner | **High** | Inspected `package.json` dependencies directly |
| Extension hook system documented above | **High** | Read `docs/extensions.md` in installed package |
| OpenClaw uses pi SDK mode | **High** | pi README cites OpenClaw; package structure confirms |
| Hermez could use pi SDK | **High** | Architectural match is direct |
| Claude Code integration via ACP | **Medium** | ACP SDK present, no direct integration code found |
| deepseek-r1 supported | **High** | pi-ai README explicitly lists Ollama support |

---

## Sources

1. Installed package: `/Users/koad/.nvm/versions/node/v24.14.0/lib/node_modules/openclaw/package.json` — version 2026.3.28, lists `@mariozechner/pi-*` dependencies
2. `@mariozechner/pi-agent-core` README — `node_modules/@mariozechner/pi-agent-core/README.md`
3. `@mariozechner/pi-coding-agent` README — confirms "See openclaw/openclaw for a real-world SDK integration"
4. `@mariozechner/pi-ai` README — provider list, unified API docs
5. `@mariozechner/pi-coding-agent/docs/extensions.md` — full hook/event reference
6. `@mariozechner/pi-coding-agent/docs/sdk.md` — SDK mode docs
7. `@mariozechner/pi-coding-agent` package.json — repo: `github.com/badlogic/pi-mono`
8. OpenClaw `openclaw.json` — confirms `opencode/claude-opus-4-6` as model, gateway at 18789
9. Prior research: `/Users/koad/.sibyl/research/2026-04-02-openclaw-datadir.md`

---

## Recommendation

**Juno should assess pi as the standard agent harness for koad:io entities that need hook-heavy orchestration.**

Immediate actions:
1. **Hermez pilot**: The OpenClaw model is proven. Stand up a Hermez instance using pi SDK (`createAgentSession()`) with entity workspace files as context. Route inbound messages to `session.prompt()`.
2. **Extensions for koad:io trust/routing**: Write a single pi extension that enforces trust chain checks (`tool_call` block), routes research output to Sibyl's `research/` directory, and calls Veritas via `sendHookMessage()`.
3. **ACP investigation**: Determine whether the Agent Client Protocol (`@agentclientprotocol/sdk` at 0.17.0) is the right inter-entity communication layer. OpenClaw already has it — if the other entities adopt ACP, the protocol is free.
4. **deepseek-r1 routing**: Configure the `context` hook to route long-context research tasks to `ollama/deepseek-r1:8b` on fourty4 automatically when token count exceeds threshold.

Pi's design philosophy ("Adapt pi to your workflows, not the other way around") aligns well with koad:io's sovereign, non-vendor-locked stance.
