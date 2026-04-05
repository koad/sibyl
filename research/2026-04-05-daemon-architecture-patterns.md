---
title: "Daemon Architecture and Real-Time Data Patterns"
date: 2026-04-05
researcher: Sibyl
status: complete
priority: critical
tags: [daemon, ddp, meteor, pub-sub, worker-queue, entity-coordination, offline-first]
commissioned-by: Juno
---

# Daemon Architecture and Real-Time Data Patterns

**Context:** The koad:io daemon (`~/.koad-io/daemon`) is a Meteor/DDP application that acts as the "kingdom hub" — the coordination layer connecting entities, the browser extension (Dark Passenger), and the local MongoDB instance. Current state: npm unblocked, dotsh ready to start. This brief addresses four architecture questions before the daemon goes into production use as an entity coordination layer.

---

## Research Question 1: Meteor/DDP at Scale — Limits and Production Patterns

### What DDP Is

DDP (Distributed Data Protocol) is Meteor's application-layer protocol over WebSocket. It has two mechanisms: **pub/sub** (server pushes reactive data sets to subscribers) and **RPC** (client calls server methods). Every connected client maintains a live merge-box — a client-side mirror of server collections filtered through active subscriptions.

### Known Scaling Limits

**The merge-box CPU problem is the primary ceiling.** On every document write, Meteor's livequery system:
1. Detects the change via MongoDB oplog tailing or polling
2. Determines which active subscriptions include the changed document
3. Computes the diff for each affected subscriber's merge-box
4. Sends the diff over each subscriber's WebSocket

This diff computation scales as O(subscribers × documents-per-publication). At low subscriber counts (under ~50 concurrent with modest publication sizes), it is effectively invisible. At higher counts, it becomes the bottleneck before database I/O or network bandwidth.

**Documented production observations:**
- A single Meteor process (Node.js, single-threaded) with trivial publications can hold ~1,000 concurrent WebSocket connections at low activity.
- With active publications (documents changing at any rate), the practical ceiling for real-time reactivity from a single process is roughly 100–300 concurrent subscribers before merge-box CPU becomes measurable.
- MongoDB oplog tailing (vs. polling) is mandatory at any production scale — polling introduces artificial latency and CPU overhead that compounds with subscriber count.

**Memory is the second limit.** Each connected DDP client consumes ~50–100KB of server memory for the session state and merge-box. At 1,000 connections that is ~50–100MB. At 10,000 it becomes the dominant resource.

**WebSocket connection limits at the OS level.** Each DDP connection is a persistent WebSocket, which is a file descriptor. Default Linux limits (`ulimit -n`) are often 1,024. Production deployments require `nofile` limits raised to 65,535+ in systemd unit files or `/etc/security/limits.conf`.

### Production Patterns for Scale

**1. Oplog tailing (non-negotiable)**
```
MONGO_OPLOG_URL=mongodb://localhost/local
```
Without oplog tailing, Meteor falls back to polling each collection at a configurable interval. Polling is prohibitively expensive above a handful of subscriptions.

**2. Publication field projection**
Publications should return the minimum fields needed:
```javascript
Meteor.publish('entity.status', function(entityId) {
  return Entities.find({ _id: entityId }, { fields: { status: 1, lastSeen: 1 } });
});
```
Narrower projections reduce diff payload and merge-box computation.

**3. Subscription scoping**
Publications that return entire collections (`Passengers.find()`) become expensive as the collection grows. Scope by entity or context. The existing `all` and `current` publications in the daemon are fine for a handful of entities — they need scoping before the passenger list grows to dozens.

**4. Horizontal scaling via sticky sessions**
Meteor can be horizontally scaled across multiple processes using the `meteorhacks:cluster` package or a load balancer with sticky sessions. DDP requires sticky sessions because session state (merge-box) lives in-process. Without sticky sessions, a client may reconnect to a different node that has no record of its subscriptions.

For koad:io at current scale (15–20 entities, local deployment), single-process Meteor is entirely sufficient. Horizontal scaling is a future concern, not a present one.

**5. What breaks first (in order)**
1. Merge-box CPU — too many subscribers × too many active documents
2. Memory — too many open sessions
3. OS file descriptors — too many WebSocket connections
4. MongoDB oplog tailing lag — high write volume without oplog configured

**Confidence: High** — these are documented Meteor architecture characteristics from the official Meteor Guide, MDG blog posts, and Galaxy deployment documentation.

---

## Research Question 2: Worker/Passenger Pattern — Reliable Job Queue Patterns in Node.js

### The Dark Passenger Pattern (Current Implementation)

The current daemon implements a "passenger" model: entities announce themselves via `passenger.json`, the daemon discovers and registers them at startup, and they become addressable via DDP methods (`passenger.check.in`, `passenger.ingest.url`). This is a **registry + dispatch** pattern, not a job queue.

The `passenger.reload` method (full re-scan) means the worker list is reconstructed on demand rather than maintained incrementally. This is appropriate for a small, stable set of entities but becomes unreliable under churn (entities starting and stopping frequently).

### Reliable Job Queue Patterns — Prior Art and Failure Modes

**The fundamental problem job queues solve:**
- Work arrives faster than it can be processed (backpressure)
- Workers die mid-job (durability)
- Work must not be processed twice (idempotency)
- Work ordering may or may not matter (FIFO vs. priority)

**For koad:io's entity-as-worker model, the relevant failure modes are:**

**1. At-most-once vs. at-least-once delivery**
Meteor methods are synchronous RPC — fire and return. If an entity processes a method call and then crashes, the result is lost. There is no retry. For work that must complete, method calls alone are insufficient. The daemon needs to persist work items to MongoDB *before* dispatching them, and entities must acknowledge completion.

Pattern:
```
job created (status: pending) → dispatched → entity acknowledges (status: in-progress)
→ entity completes → job closed (status: done)
```
If the entity crashes between dispatch and acknowledgment, a watchdog can detect pending-but-stale jobs and re-dispatch.

**2. Bull/BullMQ (Redis-backed) — the Node.js production standard**
Bull is the most widely used job queue in Node.js production systems. It uses Redis as the durable backing store. Relevant properties:
- Jobs survive process restarts (Redis persistence)
- Failed jobs are moved to a failed queue (not silently dropped)
- Concurrency, retries, and delays are configurable per queue
- Bull Board provides a web UI for queue inspection

For koad:io, the daemon already has MongoDB. A lightweight MongoDB-backed job queue (using a jobs collection with TTL indexes and atomic `findOneAndUpdate`) achieves similar durability without adding Redis as a dependency.

**3. The "outbox pattern" for reliability**
From distributed systems literature: before a process does any external action, it writes a record of its intent to a durable store (the outbox). If it crashes before completing, the outbox record remains and a recovery process can retry.

Applied to koad:io: when the daemon receives a task for an entity, it writes it to a `tasks` collection first. The entity reads from `tasks` (via subscription), processes, and marks complete. The daemon never "forgets" a task.

**4. Passenger heartbeat / liveness**
The current passenger model has no liveness signal. A passenger that crashes leaves its record in the `Passengers` collection in a stale state. Workers in production queue systems (e.g., Sidekiq, Celery) send heartbeats to prove they are alive. The daemon should track `lastHeartbeat` per entity and consider entities offline if the heartbeat lapses past a threshold.

**5. Idempotency**
Work dispatched to entities should include a unique job ID. If the same job is dispatched twice (e.g., due to a retry after a crash), the entity can detect and skip the duplicate using the ID. MongoDB's `$setOnInsert` with `upsert` makes idempotent inserts straightforward.

**What the current daemon does well:**
- Passenger discovery is clean and automatic — entities announce themselves via filesystem convention rather than requiring explicit registration API calls.
- DDP methods for dispatch are synchronous and immediately visible to subscribers.

**What needs hardening:**
- No job persistence (tasks disappear if the daemon restarts during processing)
- No liveness signal (dead entities remain in the registry)
- `passenger.reload` is a full rescan, not incremental — race condition if two reloads run concurrently

**Confidence: High** — outbox and heartbeat patterns are documented in "Designing Data-Intensive Applications" (Kleppmann), Meteor documentation, and Bull/BullMQ documentation.

---

## Research Question 3: Entity-as-Subscriber — Prior Art for Pub/Sub as Agent Coordination

### The Vision

In the koad:io model, entities subscribe to DDP publications to receive assigned work and publish their state. The daemon is the hub. This is a **pub/sub coordination layer** for autonomous agents.

### Prior Art

**1. Actor model (Erlang/Akka/Orleans)**
The actor model is the closest intellectual ancestor. Actors are lightweight processes with mailboxes. They receive messages, process them, and send messages to other actors. No actor polls — everything is push. Erlang's OTP has used this pattern for 40 years in telecom systems at massive scale. The key properties:
- Location transparency: actors don't know if their counterpart is local or remote
- Supervision trees: parent actors restart failed children
- Immutable message passing: no shared state between actors

DDP pub/sub is not quite the actor model (actors are bidirectional, DDP is one server pushing to many clients), but the coordination pattern is similar.

**2. Redis Pub/Sub as agent coordination**
Numerous multi-agent systems use Redis pub/sub as the coordination bus. Each agent subscribes to a channel (or set of channels) and publishes its output to another. The pattern is proven but has a critical limitation: **Redis pub/sub is fire-and-forget**. Messages published when a subscriber is offline are lost. For agent coordination where tasks must not be dropped, a message queue (Redis Streams or a job queue) is preferred over raw pub/sub.

**3. NATS and NATS JetStream**
NATS is a lightweight message broker designed for distributed systems. NATS Core is fire-and-forget (same limitation as Redis pub/sub). NATS JetStream adds persistence: subscribers can replay messages from their last acknowledged position after reconnection. This is the pattern the entity-as-subscriber model needs.

**4. Apache Kafka / consumer groups**
Kafka is the industrial-strength version of this pattern. Each consumer group maintains an offset — its position in the log. When a consumer disconnects and reconnects, it resumes from its last committed offset. No messages are lost. This is overkill for koad:io but illustrates the correct abstraction: **each entity maintains a cursor into the work log, not a transient subscription to a live stream**.

**5. CRDTs and operational transforms**
For state synchronization (rather than task dispatch), Conflict-free Replicated Data Types provide a mathematical framework for merging concurrent updates without coordination. Git is a CRDT-adjacent system. The entities' use of git as their state store already achieves a form of CRDT-like convergence for their configuration — worth noting as an architectural strength.

### Pub/Sub vs. Polling (GitHub Issues Pattern) — Tradeoffs

| Dimension | DDP Pub/Sub | GitHub Issues Polling |
|---|---|---|
| Latency | Sub-second (push) | Minutes (poll interval) |
| Durability | In-memory by default; needs persistence layer | Durable by default (GitHub stores it) |
| Offline behavior | Messages lost while subscriber is offline (without JetStream-style persistence) | Issue remains open; entity picks it up on next poll |
| Auditability | None by default; requires explicit logging | Full audit trail via GitHub |
| Cross-machine | Requires daemon reachable on network | Works across any machine with internet |
| Cost at scale | Low (local infra) | Free up to GitHub API limits |
| Discoverability | Requires subscriber to know publication name | Public, searchable |

**The critical finding:** GitHub Issues is a more reliable work queue than raw DDP pub/sub, precisely because GitHub stores the issue persistently and entities can "reconnect" (start fresh sessions) and resume work from the durable state. DDP is faster but ephemeral. The hybrid pattern is the answer: **GitHub Issues for durable task assignment + DDP for real-time state streaming**.

**Confidence: High** — NATS, Kafka, Redis pub/sub and actor model are extensively documented; the comparative analysis is based on well-established distributed systems literature.

---

## Research Question 4: Offline-First and Reconnection — State Reconciliation Patterns

### The Problem

Entities go offline — process restarts, machine sleep, daemon restart, network interruption. When they reconnect:
1. What state did they miss?
2. What work was assigned to them?
3. Is their local state stale?

### DDP's Built-In Reconnection Behavior

Meteor's DDP client has built-in reconnection with exponential backoff. On reconnect, the client:
1. Sends a new `connect` message
2. Re-establishes all active subscriptions
3. Receives a full diff against the server's current state

This means DDP reconnection gives the entity the **current state** but not a **history of what changed while offline**. A document that was created and deleted while the entity was offline leaves no trace. If those documents were work assignments, the work is invisible.

This is the fundamental weakness of the DDP model for work queues: it is state-synchronization, not event sourcing. State-sync gives you "what is true now." Event sourcing gives you "what happened, in order."

### Production Patterns for Offline Reconciliation

**1. Event sourcing / append-only log**
Rather than updating documents in place, all state changes are written as events to an immutable log. Subscribers maintain a position (offset or timestamp) in the log. On reconnect, they replay events from their last confirmed position. Kafka, NATS JetStream, and EventStoreDB implement this pattern.

For koad:io, a lightweight version: a `events` MongoDB collection with a monotonically increasing sequence number and a TTL index (events expire after N days). Each entity tracks its `lastProcessedSequence`. On reconnect, it queries `events.find({ sequence: { $gt: lastProcessed } })`.

**2. Vector clocks / CRDTs**
Vector clocks track causality across distributed nodes. When two nodes reconnect, they exchange vector clocks to determine which events each missed. This is mathematically sound but complex to implement. Git's DAG is a practical vector clock implementation.

For entity state (not task assignment), git pull is already the correct reconciliation mechanism — and it is already in use via the `git pull` convention before reading any entity directory.

**3. "Tombstone" pattern for deletions**
A common source of bugs in state-sync systems: deleted records. When a document is deleted and a subscriber reconnects, the subscriber doesn't know the document ever existed. Soft deletes (marking documents `deleted: true` with a timestamp) keep the record visible for late subscribers.

**4. Sequence-numbered publications**
A pattern used in production Meteor apps: each document in a publication carries a `updatedAt` timestamp. On reconnect, the client can compare its local state timestamps against the server's and detect gaps. This requires the publication to include timestamps and the client to persist state between sessions.

**5. The koad:io-specific answer: git + DDP hybrid**
The strongest reconciliation pattern for koad:io is already embedded in the architecture:
- **git** handles durable state (entity configuration, completed work, identity)
- **GitHub Issues** handles durable task assignment
- **DDP** handles real-time streaming (current passenger state, live status)

On entity reconnect:
1. `git pull` — reconcile all durable state
2. `gh issue list --state open` — recover any assigned tasks
3. Re-establish DDP subscriptions — get current live state

This is more robust than a custom event log because it leverages existing infrastructure that is already durable, versioned, and externally auditable.

**Confidence: High** — event sourcing is documented in Kleppmann's "Designing Data-Intensive Applications" Ch. 11; Meteor reconnection behavior from official docs; NATS JetStream from nats.io/documentation.

---

## Synthesis: Architecture Recommendations for the Daemon

### What the Daemon Should Do (Short-Term)

The daemon as currently built is well-suited to its current role: browser extension bridge, passenger registry, method dispatch. It does not yet need to be a full entity coordination bus.

**Harden the existing implementation:**

1. **Add heartbeat tracking to `passenger.json`**
   ```javascript
   // In passenger-methods.js, add:
   Meteor.methods({
     'passenger.heartbeat'(handle) {
       Passengers.update({ handle }, { $set: { lastHeartbeat: new Date() } });
     }
   });
   ```
   Each entity sends a heartbeat every 30s. The daemon marks entities offline if `lastHeartbeat` is older than 90s.

2. **Persist task dispatch to MongoDB before sending**
   Before dispatching any work to an entity via DDP method, write it to a `tasks` collection. Mark it `acknowledged` when the entity confirms receipt. A background job can re-dispatch tasks that are `pending` and older than a timeout threshold.

3. **Scope the `all` publication**
   The `Passengers.find()` publication grows linearly with entities. Add pagination or scope to active entities: `Passengers.find({ lastHeartbeat: { $gt: cutoff } })`.

4. **Add oplog tailing configuration**
   Ensure `MONGO_OPLOG_URL` is set before production load. Without it, Meteor polls, which is expensive.

### What the Daemon Should Become (Medium-Term)

The path toward entity-as-subscriber coordination:

1. **Task log collection** — append-only `tasks` collection with sequence numbers and TTL. Entities subscribe to their own task queue: `Meteor.publish('tasks.mine', function(entityId) { ... })`.

2. **Entity state publication** — each entity publishes its current status to the daemon via DDP method, daemon rebroadcasts via subscription. The Stream PWA (Vulcan#3) subscribes to this to render the live activity wall.

3. **Reconnection protocol** — on entity startup:
   - `git pull` on entity dir (already in convention)
   - Check GitHub Issues for open assignments
   - Connect to daemon, re-establish subscriptions
   - Request any tasks with `status: pending` since `lastHeartbeat`

### What Should Stay on GitHub Issues

GitHub Issues should remain the **durable work assignment layer**. DDP should be the **real-time state streaming layer**. These are complementary, not competing. The daemon does not need to replace GitHub Issues as the task queue — it needs to extend it with real-time presence and streaming.

---

## Key Sources

- Meteor Documentation — Pub/Sub, Methods, DDP specification: https://docs.meteor.com/
- Meteor DDP Protocol Specification: https://github.com/meteor/meteor/blob/devel/packages/ddp/README.md
- Meteor Guide — Publications and Subscriptions: https://guide.meteor.com/data-loading
- Galaxy Deployment Guide — Performance and Scaling: https://cloud.meteor.com/docs
- Bull/BullMQ documentation: https://docs.bullmq.io/
- NATS JetStream documentation: https://docs.nats.io/nats-concepts/jetstream
- Kleppmann, M. (2017). *Designing Data-Intensive Applications*. O'Reilly. Ch. 11 (Stream Processing), Ch. 9 (Consistency and Consensus).
- Akka documentation — Actor Model: https://akka.io/docs/
- MongoDB Change Streams: https://www.mongodb.com/docs/manual/changeStreams/
- koad:io daemon source: `~/.koad-io/daemon/src/`
- Sibyl prior research: `2026-04-03-nginx-meteor-connections.md` (DDP/WebSocket layer)
- Sibyl prior research: `2026-04-05-inter-agent-comms-brief.md` (agent communication patterns)
