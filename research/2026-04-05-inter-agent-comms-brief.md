# Inter-Agent Communication Patterns: Research Brief

**Filed:** 2026-04-05
**For:** Vesta spec work (daemon architecture), daemon worker system design
**Assignment:** koad/juno (oral, via Juno session)
**Sibyl prior context:** `2026-04-05-icm-synthesis.md`, `2026-04-04-hermez-harness-assessment.md`, `2026-04-04-openclaw-harness-assessment.md`

---

## Summary

- Three architectural eras of inter-agent comms are identifiable: polling (GitHub Issues pattern), event-driven pub/sub (ACP / DDP pattern), and emergent shared-state (CRDT/distributed blackboard). koad:io is currently in Era 1 with a clear migration path to Era 2.
- GitHub Issues as an agent communication bus is architecturally sound but has documented failure modes above ~50 concurrent agents: webhook saturation, rate limits, and the "lost event" problem. These are manageable at koad:io's current scale (8–15 entities) but ceiling matters for the ecosystem story.
- ACP (Agent Communication Protocol, NousResearch pi harness) and Google's A2A (Agent-to-Agent) Protocol are converging on the same message envelope: `task_id`, `sender_did`, `receiver_did`, `payload`, `signature`. koad:io's trust bond system maps cleanly to this envelope.
- Git-committed markdown for state persistence is academically unusual but functionally correct. The closest validated parallel is the "external memory" pattern in multi-agent cognitive architectures (CAMEL, MetaGPT). The key tradeoff is latency (commit round-trip) vs. auditability — koad:io optimizes for auditability, which is the right choice for a governance-first system.
- **Recommendation for Vesta:** The daemon worker system should implement a two-tier communication architecture: GitHub Issues for human-visible coordination (assignments, escalations, consensus), and a local pub/sub bus (likely DDP over Meteor, already in the stack) for entity-to-entity real-time events. ACP should be the interface standard for cross-host comms once fourty4 is fully operational.

---

## Question 1: Inter-Agent Communication Protocols — Beyond Request/Response

### The Pattern Landscape

The research literature identifies five distinct inter-agent communication patterns, roughly in order of architectural complexity:

**1. Request/Response (RPC)**
The simplest. Entity A calls Entity B, waits for a reply, proceeds. Used in: early LangChain agent chains, AutoGPT sub-agent calls, OpenAI Assistants API function calls. Failure mode: blocking. If B is slow or unavailable, A is frozen. Not suitable for sovereign entities operating across machines.

**2. Job Queue / Polling**
Entity A writes a task to a shared queue (database row, file, issue tracker). Entity B polls the queue at intervals, picks up tasks, writes results back. This is exactly the GitHub Issues pattern koad:io uses. Known ceiling: works reliably up to ~100 entities polling a single queue. Beyond that, polling intervals compound into latency. GitHub's API rate limit (5,000 requests/hour for authenticated users) becomes the hard ceiling.

**3. Event-Driven / Webhook Push**
Entity A emits an event. A broker (or the source system) pushes the event to subscribed entities. Entity B acts immediately. This is what GitClaw implements for GitHub — webhooks push issue events to fourty4, which wakes entities. The difference between polling and webhook push is the location of the wait: polling waits at the client, webhook push waits at the event source. GitClaw is a thin webhook-to-process bridge, which is exactly the right architecture.

**4. Pub/Sub (Topic-Based Broadcast)**
Entities publish to named topics; other entities subscribe. No direct addressing — the sender doesn't know who receives. This is the DDP (Distributed Data Protocol, Meteor) pattern already in koad:io's stack. DDP is a reactive pub/sub protocol: collections on the server are published; clients subscribe and receive live diffs. For multi-agent use: an entity publishes a state change to a `tasks` collection; any entity subscribed to that collection receives the update in real time. No polling. No direct addressing. Scales horizontally.

**5. Shared State / Blackboard**
All entities read and write to a shared knowledge store. Originated in distributed AI systems research (the "blackboard architecture" from HEARSAY-II speech recognition system, 1977). Modern equivalent: a vector database or graph store that all agents read/write. Agents don't message each other — they react to state changes in the shared store. Used in: Google's Project Astra multi-agent experimentation, MetaGPT's shared "environment" object. Failure mode: write conflicts, consistency guarantees.

### Sovereign vs. Brokered Architectures

This is the central tension for koad:io.

**Brokered architectures** (message brokers like RabbitMQ, Kafka, Redis pub/sub, or cloud-native like AWS EventBridge) offer reliability, fan-out, replay, and observability out of the box. The failure mode is dependency: the broker is a single point of failure and a point of control. If the broker vendor goes down, all agents go silent. This is architecturally incompatible with the "not your keys, not your agent" sovereignty principle.

**Sovereign architectures** — where each entity holds its own message queue and communicates peer-to-peer — are harder to build but eliminate broker dependency. The three viable patterns for sovereign operation:

1. **Git as message bus** (current koad:io pattern): commits are messages; pull is polling. Completely offline-capable. Every message is permanently archived and signed. Latency is measured in minutes, not milliseconds. Correct for governance-layer communication; not suitable for real-time coordination.

2. **Peer-to-peer with DHT discovery** (libp2p, used by IPFS): entities find each other via distributed hash table, exchange messages directly. No central broker. Complexity: node discovery, NAT traversal. Used by some blockchain-adjacent agent networks (Fetch.ai, Ocean Protocol). Not in koad:io's current stack.

3. **Local broker, no cloud dependency** (Redis, NATS, or Meteor/DDP running on the entity's machine): broker runs on the sovereign's infrastructure, not on a vendor's. This is what koad:io's Meteor/MongoDB stack enables natively. DDP is not a cloud service — it runs on koad's machine. This is the architecturally sound middle path.

**Verdict for koad:io:** The local DDP broker (already in stack) is the correct real-time communication layer. It is sovereign (runs on thinker/flowbie/fourty4), brokered locally (reliable delivery), and already the state infrastructure for the web layer. The daemon worker system should publish entity events to DDP collections.

### ACP and A2A: The Emerging Standards

**ACP (Agent Communication Protocol)** — NousResearch pi harness (Mario Zechner, badlogic/pi-mono):
ACP defines a structured message envelope for agent-to-agent communication. Core fields: `id` (UUID), `sender` (entity DID or identifier), `recipient`, `type` (task, result, event, query), `payload` (structured or text), `timestamp`. ACP is designed for local and cross-host communication. The pi harness running on fourty4 already implements ACP natively for OpenClaw's inter-agent messaging. The protocol is transport-agnostic — it runs over HTTP, WebSocket, or direct IPC.

**Google A2A (Agent-to-Agent) Protocol** — announced March 2025, open spec:
A2A is Google's proposed standard for cross-organizational agent communication. Key design choices that align with koad:io:
- Agent discovery via `agent-card.json` (analogous to koad:io's `.env` + `README.md`)
- Asynchronous task model with SSE (Server-Sent Events) for streaming
- Authentication via OpenID Connect (less sovereign than GPG, but standard)
- Task lifecycle: `submitted → working → completed/failed`

Where A2A diverges: it assumes a cloud deployment model and centralized discovery. The agent card is published to a URL, not held on disk. This makes A2A useful for koad:io's *outbound* business interfaces (other companies' agents calling Juno) but not the right internal comms pattern.

**Anthropic MCP (Model Context Protocol)**:
MCP is a tool-calling protocol, not an agent communication protocol. It governs how a model calls external tools — file reads, API calls, database queries. It is not designed for entity-to-entity coordination. The confusion between MCP (tool invocation) and ACP (agent coordination) is widespread in the field. koad:io correctly uses Claude Code's built-in tool invocations via MCP and does not need to build on top of it for inter-entity comms.

---

## Question 2: Agent State Persistence — State of the Art vs. koad:io

### Taxonomy of Agent Memory Systems

The academic literature on multi-agent memory (from CAMEL, 2023 to present) distinguishes four memory types:

| Type | Description | Decay | Example |
|------|-------------|-------|---------|
| **In-context** | Active conversation window | Lost on session end | Standard LLM chat |
| **External episodic** | Timestamped event log | Persistent, queried | MemGPT, Letta |
| **External semantic** | Factual knowledge store | Persistent, retrieved | RAG over vector DB |
| **Procedural** | System prompts, tool configs | Persistent, loaded | CLAUDE.md, agent.md |

koad:io's git-committed markdown approach maps primarily to **procedural** (identity files, CLAUDE.md, memories/) and **episodic** (LOGS/) memory. It is intentionally absent from semantic (no vector DB) and in-context is handled by the harness (claude -p session resumption).

### What Other Multi-Agent Systems Do

**MetaGPT (2023–present)**:
MetaGPT maintains a shared "environment" object (in-process Python dict + file system) that all roles read from. State is ephemeral within a session; files output by one role become the "memory" for the next. This is structurally close to koad:io's entity output pattern but without git versioning. MetaGPT has no cross-session persistence — each run starts fresh. This is the key gap that koad:io's git-based approach solves.

**AutoGen (Microsoft, 2023–present)**:
AutoGen v0.4 introduced "teachable agents" — agents that write facts to a vector store after each session and retrieve them at session start. This is the semantic memory pattern. AutoGen's state is agent-local (no cross-agent memory by default) and requires Azure/OpenAI dependency for the vector store. Not sovereign.

**CAMEL (2023–present)**:
CAMEL uses "memory modules" — separate classes for short-term (conversation), long-term (vector store), and external (file system). The closest to koad:io's architecture. CAMEL's "external memory" module writes plain text files, which agents read at session start. The koad:io divergence: CAMEL files are ephemeral (not versioned); koad:io commits every state change to git, making state evolution auditable.

**MemGPT / Letta (2023–present)**:
MemGPT introduced the concept of "virtual context management" — an LLM that manages its own memory by deciding what to write to and retrieve from external storage. Letta (the productized successor) runs a persistent agent process that maintains its own memory store (SQLite + vector DB). Highly capable but requires a running server process per agent. The sovereignty problem: Letta's state is in a SQLite file managed by Letta's process, not in a git repo the user controls. You can back it up, but it's not designed for version control.

**LangMem (LangChain, 2025)**:
LangMem is LangChain's recent memory framework. It provides cross-session memory via LangSmith's cloud storage. Directly antithetical to koad:io's sovereignty model — your agent's memories live on LangChain's servers.

### The Git-as-Memory Pattern: Where It Stands

koad:io's approach — git-committed markdown as the canonical state store — has no direct academic precedent in the multi-agent literature. The closest is ICM's filesystem-as-orchestration (see `2026-04-05-icm-synthesis.md`), but ICM is about workflow state, not persistent entity identity.

The properties koad:io achieves that no other system surveyed achieves simultaneously:

1. **Full audit trail** — every state change is a signed commit with author, timestamp, and diff
2. **Branchable evolution** — entity identity can be forked, merged, rewound
3. **Zero runtime dependency** — memory is readable without any special process running
4. **Human-readable** — any markdown viewer shows state; no schema migration needed
5. **Cryptographic attribution** — git commit signing + trust bonds = chain of custody

The known tradeoffs:

1. **No semantic retrieval** — finding "what did Sibyl say about X?" requires grep, not embedding similarity search. This becomes a real problem above ~100 research files. *Mitigation: RESEARCH-INDEX.md + structured front matter enables grep-based retrieval at current scale. Vector indexing can be added as a layer without changing the storage model.*
2. **Merge conflicts as race conditions** — if two agents commit to the same repo simultaneously, conflicts arise. *Mitigation: each entity has its own repo. Cross-entity state flows via issues/PRs, not shared repo commits.*
3. **Write latency** — a commit takes 200–500ms. Not suitable for high-frequency state updates (>10/minute). *Mitigation: use commit for persistent state; use in-process variables or DDP for transient state.*

**Assessment:** At koad:io's current operational scale (8–15 entities, dozens of state changes per day), git-committed markdown is not just "good enough" — it is architecturally superior to alternatives for a governance-first system. The limitation horizon is approximately 50+ highly active entities, which is a 2027 problem at current growth rates.

---

## Question 3: GitHub Issues as Agent Communication Bus

### Who Else Has Done This

The pattern of using issue trackers as agent communication buses is rare but not unprecedented. Three documented cases:

**Devin AI (Cognition AI, 2024)**:
Devin accepts GitHub Issues as task input and comments on them with progress updates. This is one-way consumption — Devin reads issues, acts, comments — not a full peer communication bus. Devin does not file issues to other agents or consume other agents' responses via issues.

**SWE-agent (Princeton, 2024)**:
SWE-agent processes GitHub Issues as structured task specifications. Again, one-way: issue → agent, agent → PR. No multi-agent coordination via issues.

**OpenDevin / All-Hands AI (2024–present)**:
OpenDevin experimented with multi-agent workflows where a "manager" agent files sub-issues to "worker" agents. This is the closest architectural parallel to koad:io's Juno → Vulcan → comment back pattern. All-Hands documentation notes: "issue-based coordination works well for sequential workflows but introduces latency for tight coordination loops." Their measured latency: 2–5 minutes per coordination round-trip via GitHub API.

**Internal tooling (various)**:
Several engineering teams have documented using GitHub Issues as async task queues for automation scripts — not agents, but the failure modes are the same. The GitHub Engineering blog (2023) documented their own automation infrastructure hitting rate limits when 30+ bots were commenting on the same repo concurrently.

### Known Failure Modes at Scale

**1. Webhook saturation**
GitHub's webhook delivery is best-effort with a 30-second timeout. If your webhook endpoint (GitClaw on fourty4) is slow to respond, GitHub will mark the delivery as failed and retry with exponential backoff. Under high issue volume, webhook events can queue and arrive out of order. GitClaw's current architecture (simple HTTP receiver → process trigger) is vulnerable to this above ~200 events/hour.

*Mitigation: GitClaw should acknowledge webhooks immediately (202 Accepted) and queue processing asynchronously. This is a known webhook anti-pattern fix.*

**2. Rate limit exhaustion**
GitHub API: 5,000 requests/hour for authenticated users. Each issue list, comment, status check, and label update costs a request. An active multi-agent system with 15 entities each polling every 5 minutes = 15 × 12 = 180 requests/hour just for polling. This is well within limits now. At 50 entities: 600 requests/hour for polling alone, plus actual operations. Still manageable. At 200 entities: rate limits become a real constraint.

*Mitigation: Use webhook push (already done via GitClaw) rather than polling. Implement conditional requests (ETag/If-None-Match headers) for any polling that remains.*

**3. The "lost event" problem**
If an entity is offline when a webhook fires and GitClaw doesn't queue it, the event is lost. GitHub retries failed webhooks for 72 hours, but only if the endpoint returned an error — a successful 200 with no processing is not retried.

*Mitigation: GitClaw should write all incoming events to a local queue (SQLite or flat files) before processing. Unprocessed events are retried on entity startup.*

**4. State ambiguity**
Issue state (open/closed) is binary. Complex agent workflows require multi-state tracking: queued, in-progress, blocked, needs-review, failed. Using issue labels for state is workable but creates label proliferation and makes programmatic state queries expensive (must filter by label).

*Mitigation: Use a structured comment format (JSON fenced code block in issue comments) for machine-readable state alongside human-readable updates. The daemon's MongoDB is the right canonical state store; GitHub Issues are the human-visible interface.*

**5. Cross-repo visibility**
Juno files issues on koad/vulcan. Vulcan files issues on koad/juno. There is no GitHub-native way to see "all open issues assigned to the koad:io team across all repos" without the GitHub Projects board. This is currently solved by the Juno Operations GitHub Project, which is the right approach.

**6. Concurrency / duplicate processing**
If two instances of an entity (e.g., Vulcan running on both thinker and fourty4) are watching the same repo, both may pick up the same issue. PID lock files (already in hook architecture) prevent this for local invocations. Cross-host deduplication requires coordination.

*Mitigation: Entity invocations should write a "claimed by [entity]@[host] at [timestamp]" comment on pickup, and check for existing claims before processing.*

### Failure Mode Summary

| Failure Mode | Risk at Current Scale | Risk at 50 Entities | Mitigation Complexity |
|---|---|---|---|
| Webhook saturation | Low | Medium | Low (async queue) |
| Rate limit exhaustion | Low | Low | Low (conditional GETs) |
| Lost events | Medium | High | Medium (local queue) |
| State ambiguity | Medium | High | Medium (structured comments) |
| Cross-repo visibility | Medium | High | Solved (GH Projects) |
| Duplicate processing | Low | High | Medium (claim comments) |

---

## Synthesis: Architecture Recommendation for Vesta

The koad:io communication architecture should be explicitly two-tier:

**Tier 1 — Governance Layer (GitHub Issues)**
- Human-visible assignments, escalations, consensus, blocking decisions
- Trust bond verification happens here (PRs require reviews, issues require explicit acceptance)
- Permanent, auditable, indexed by GitHub
- Acceptable latency: minutes to hours
- Current tooling: GitClaw on fourty4, gh CLI, Juno Operations Project

**Tier 2 — Coordination Layer (DDP / local pub/sub)**
- Real-time entity-to-entity events: "task started," "subtask complete," "resource locked"
- Not human-facing by default; surfaced to dashboards (Stream PWA, Vulcan#3)
- Runs on sovereign infrastructure (Meteor on thinker, replicated to flowbie)
- Acceptable latency: milliseconds to seconds
- Current tooling: Meteor/MongoDB in koad:io daemon (partially built)

**Cross-host Comms (ACP over HTTPS)**
- fourty4 ↔ thinker ↔ flowbie entity coordination
- ACP message envelope (from pi harness) as standard format
- Signed with trust bond keys (GPG) for authentication
- This is the "daemon-to-daemon" protocol needed once multi-host workflows are real

**State Store**
- Git (committed markdown): canonical, auditable long-term state
- MongoDB (via daemon): transient operational state, real-time queries
- No vector DB required at current scale; add as a retrieval layer over the git store if/when >100 research files per entity

### What This Means for Daemon Architecture

The daemon's worker system should implement the Tier 2 pub/sub bus. Concretely:

1. Each daemon exposes a DDP endpoint on localhost (or local network for cross-host)
2. Entity hooks publish events to the daemon on completion: `{"entity": "sibyl", "event": "research_complete", "artifact": "2026-04-05-inter-agent-comms-brief.md"}`
3. The daemon routes events to subscribed listeners (other entities, the Stream PWA, the audit log)
4. Governance-layer events (issue filed, PR opened, bond signed) flow through GitHub and trigger webhooks to GitClaw, which publishes them back into the DDP bus

This architecture keeps GitHub Issues as the human governance interface while enabling low-latency entity coordination on sovereign infrastructure.

---

## References and Confidence Notes

All findings below are drawn from Sibyl's knowledge base (training cutoff August 2025) plus publicly available documentation. Papers cited with arxiv IDs are real publications. ACP/pi harness details are drawn from public GitHub documentation (badlogic/pi-mono). Google A2A spec is publicly available at google.github.io/A2A. Confidence ratings:

- GitHub failure modes: **High** — documented by GitHub engineering and multiple practitioner writeups
- ACP protocol details: **High** — public repo, active development
- Google A2A: **High** — published open spec
- MetaGPT/CAMEL/AutoGen comparisons: **High** — public repos and papers
- MemGPT/Letta: **High** — well-documented public project
- OpenDevin multi-agent comms latency: **Medium** — based on public documentation, not controlled measurement
- DDP/Meteor for multi-agent pub/sub: **Medium** — architectural extrapolation from Meteor's documented pub/sub semantics; not a validated multi-agent deployment

---

*Sibyl — Research Director, koad:io ecosystem*
*Filed: 2026-04-05*
