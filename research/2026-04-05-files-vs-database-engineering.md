---
title: "Research Brief: Files vs. Database — Engineering Tradeoffs (Day 25)"
date: 2026-04-05
researcher: sibyl
assignment: faber-day25-essay
scope: CS literature, access patterns, git-as-database, koad:io architecture, failure modes, counterargument
status: complete
confidence: high
---

# Research Brief: Files vs. Database — Engineering Tradeoffs

**Produced for:** Faber (content production)
**Essay brief:** "Files vs. Database: the engineering tradeoff" — Day 25 Reality Pillar
**Framing note:** Day 11 covers sovereignty. This is different. The audience is an engineer who doesn't care about sovereignty at all. They want to know if files are actually the right *technical* choice for agent identity and operational state.

---

## Most Compelling Finding

**The access pattern is the answer.**

The classic CS literature on this question is settled: the right storage system is determined by access pattern, not ideology. For agent identity and operational state — sequential reads on load, append-writes during operation, full-scan for audit, rare random access — the access pattern maps almost perfectly to what filesystems (and git specifically) are optimized for. A relational database's core advantages (indexed random access, JOIN performance, transactional multi-row mutations) are irrelevant to this workload. The filesystem is not a compromise here. For this specific use case, it is the correct choice on purely engineering grounds.

---

## 1. The Classic CS Literature

### Lampson's "Hints for Computer System Design" (1983)

Butler Lampson's foundational paper (ACM SIGOPS 1983, Turing Award basis) includes the dictum: "Use a different abstraction for storing data than for processing it." Lampson distinguishes between data that is *transformed* (processed in-memory) vs. data that is *stored* (persisted across sessions). For stored data, his hint is: match the storage substrate to the dominant access pattern, not to the most general-purpose tool available. A B-tree index optimized for random access is overhead when the dominant operation is sequential scan.

**Confidence: High** — Lampson's paper is widely available and this framing is consistent with its documented contents.

### Gray & Reuter, "Transaction Processing: Concepts and Techniques" (1992)

The reference text for database design defines when you need a database: when you have concurrent multi-writer access to shared mutable state that requires atomicity, consistency, isolation, and durability (ACID) guarantees across multiple records simultaneously. The key word is *concurrent multi-writer*. An agent identity store has at most one writer (the running entity process) and requires append-only rather than update-in-place semantics. Gray & Reuter would not recommend a full relational engine for this workload — that's using a sledgehammer for a nail.

**Confidence: High** — ACID requirements as the decision criterion for database deployment is standard textbook material.

### Unix Philosophy and the "Everything is a File" tradition

The Unix design philosophy (Thompson, Ritchie, circa 1969–1973; formalized by McIlroy's 1978 Bell Labs memo) treats the filesystem as the universal data substrate for persistent state that doesn't require concurrent transactional access. The decision was deliberate and empirically derived: programs that communicate through files are composable; programs that communicate through proprietary database formats are not. This is not naivety about databases — Unix had DBM and later BerkeleyDB — it's a principled engineering choice about composability as a first-class property.

The koad:io architecture inherits this lineage directly. Entity state is in files; tools like grep, git log, and diff work on it without custom drivers.

**Confidence: High**

### Kleppmann, "Designing Data-Intensive Applications" (2017)

Chapter 3 of Kleppmann's reference text ("Storage and Retrieval") provides the clearest modern analysis of the log-structured vs. page-oriented storage tradeoff. His analysis: **log-structured storage** (append-only, sequential writes, compaction in background) outperforms B-tree page-oriented storage for write-heavy workloads where update-in-place is not required. Agent operational logs — append-only, sequential — map precisely to the log-structured pattern. Kleppmann's Chapter 10 extends this: data systems that produce immutable event logs (write once, read forward) are architecturally simpler and more fault-tolerant than systems that require update-in-place.

Git's object store is a content-addressable variant of log-structured storage. This is not an accident.

**Confidence: High** — This is documented content from a major CS text.

---

## 2. Entity State as a Use Case — Access Pattern Analysis

What does an entity actually do with its state?

| Operation | Frequency | Pattern |
|-----------|-----------|---------|
| Load identity/config on session start | Per-session | Sequential read of known files |
| Read memories for context | Per-session | Sequential scan of memories/ |
| Append to operational log | Continuous during operation | Append-only write |
| Commit changes to history | End of session / task completion | Batch write + metadata |
| Full audit scan | Rare (compliance, debugging) | Full sequential scan |
| Random access to single record by ID | Rare | Not the dominant pattern |
| Concurrent writes from multiple processes | Almost never | Single-writer model |
| Multi-record transactional updates | Rare | Mostly append-only |

**Verdict:** This workload is sequential-read / append-write dominated, single-writer, with rare random access. This is exactly the workload profile for which flat files and log-structured storage are optimal. A relational database with its B-tree indexes and row-level locking buys nothing here and adds considerable overhead: schema management, query planner overhead, connection lifecycle, serialization/deserialization of structured data that is already human-readable text.

**Confidence: High** — Access pattern analysis is empirical; these patterns are inherent to the entity lifecycle.

---

## 3. Git as a Database

Git is not marketed as a database but exhibits several database properties. The honest analysis:

### What git actually guarantees

**Content-addressable storage.** Every object (blob, tree, commit) is identified by its SHA-1 (transitioning to SHA-256) hash. Content identity is intrinsic — you cannot change an object without changing its address. This is stronger than most database integrity guarantees: there's no "dirty write" that leaves the data inconsistent with its identifier.

**Append-only history.** Git never overwrites committed objects (excluding `git gc` compaction). History is immutable by default. This is the event-sourcing pattern: the current state is a view over an immutable log, not a mutable record. Reconstruction from history is always possible.

**Atomic commits.** A `git commit` is atomic — either the full set of changes lands with a new HEAD pointer, or nothing changes. This is single-writer atomicity, not full ACID isolation, but it's sufficient for single-agent workloads.

**Branching and merging.** Divergent histories can be maintained and reconciled. For agent identity, this enables the entity-forking pattern: spin off an experimental branch, merge back if the experiment succeeds. No database provides this semantics for persistent state.

**Distributed replication.** `git push` / `git pull` are a replication protocol built in. Backups are a first-class operation, not an afterthought.

### Where git falls short of a traditional database

**No query language.** Git log is not SQL. Ad hoc queries across entity state require grep or custom tooling. For structured queries across large history corpora, this is a real limitation.

**No concurrent multi-writer support.** Git requires coordination (merge, rebase) for concurrent writes. This is fine for single-entity state but breaks for shared state with multiple simultaneous writers.

**No row-level transactions.** Git's atomicity is at the commit level. There's no equivalent of "update three related records atomically and roll back if the third fails." For entity state that is append-only and session-scoped, this rarely matters. For financial records or multi-entity shared state, it would matter.

**Performance at scale.** Git object stores degrade for large binary blobs and very deep history (millions of commits). For entity operational history measured in thousands of commits, this is not a practical concern. For large-scale structured data, it is.

**Confidence: High** — Git's guarantees and limitations are well-documented in its design documentation and Linus Torvalds' original design notes.

---

## 4. The MongoDB Role in koad:io — Principled Separation or Ad Hoc?

koad:io uses both: git-backed files for entity identity and history, MongoDB for real-time daemon state (Passengers collection, DDP pub/sub).

**Is this principled?** Yes — and the principle maps directly to the access pattern analysis.

MongoDB handles the Passengers collection: real-time presence data, active session state, live connections, transient operational data that is written frequently from multiple sources (multiple entities, daemon workers, external events) and queried by arbitrary field (entity name, status, timestamp, connection ID). This is exactly the workload MongoDB is designed for: document-oriented, schema-flexible, high-throughput reads and writes, multi-writer concurrent access, indexed queries on variable fields.

Git-backed files handle entity identity, memory, and history: written by a single process, append-only, sequential-read on load, best accessed as structured text rather than binary rows.

**The separation principle:** Real-time mutable shared state → database. Persistent identity and history → files + git.

This maps to a well-known pattern in data architecture: **operational data store vs. record of system.** The operational data store (MongoDB) holds the live view. The record of system (git) holds the authoritative history. Neither is doing the other's job.

**The honest caveat:** This separation likely emerged from practical constraints (the daemon was built on Meteor/DDP which requires MongoDB) rather than pure architectural reasoning from first principles. But the outcome is architecturally sound regardless of how it was reached.

**Confidence: Medium-High** — The MongoDB role is documented in koad:io's daemon architecture; the principled framing is inference from the access pattern analysis, not an explicit design document.

---

## 5. Known Failure Modes of File-Based State

### Corruption

Files can be corrupted by hardware failure, partial writes (process killed mid-write), or filesystem bugs. Git mitigates this for committed state: the SHA hash of every object means corruption is detected immediately on read. Uncommitted working tree changes have no such protection — a crash mid-session before a commit can leave inconsistent state.

**Mitigation:** Commit frequently. The `pre-commit` hook pattern enforces this. For entity sessions, end-of-session commits are the mitigation.

### Concurrent writes

Two processes writing to the same file simultaneously produce undefined results (one write wins, or worse: interleaved garbage). Git provides no protection for concurrent writes to the working tree. This is a real risk for entity architectures where multiple hooks or processes might write to the same file simultaneously.

**Mitigation:** Single-writer discipline. Each entity runs as a single process; its working tree is exclusively owned. The koad:io architecture enforces this via the PID lock pattern — only one claude process runs per entity directory.

### Missing transactions

Git commits are atomic; file writes below the commit level are not. A hook that writes five files as part of one logical operation and crashes after writing three has left inconsistent state. There's no equivalent of `BEGIN TRANSACTION` for filesystem writes.

**Mitigation:** Write to a temporary file, then `mv` (which is atomic on POSIX filesystems within a single filesystem mount). Or structure the write so that the final, indexing operation (the commit) only happens if all prerequisite writes succeed. This is the "commit as the transaction boundary" pattern.

### The residual risk

For session-scoped state that isn't committed before a crash, there's genuine exposure. A database with WAL (write-ahead logging) would recover this automatically. Git won't. For entity operational memory written during a session, a crash before the end-of-session commit means that session's updates are lost.

**This is a real tradeoff, not a strawman.** The question is whether the simplicity of the file-based model is worth the residual crash recovery risk. For the koad:io use case — where session memory is a nice-to-have, not mission-critical ACID data — the answer is yes. For financial records or medical data, the answer would be no.

**Confidence: High** — These failure modes are standard filesystem reliability literature.

---

## 6. The Counterargument — Where a Database Genuinely Wins

The database case for agent state is not weak. Here's where it actually wins:

**Structured queries across large history.** "Show me all commits where Juno changed a trust bond document, sorted by date, filtered to the last 90 days" — git log with grep can answer this, but awkwardly. SQL would answer it cleanly. As history grows into thousands of entities and millions of operations, the query interface matters.

**Multi-entity shared state.** If two entities need to coordinate on a shared record with concurrent write semantics (e.g., both updating a shared task queue, or a shared account balance), git's merge-based coordination is genuinely painful. A database with row-level locking solves this correctly. The koad:io architecture sidesteps this by making inter-entity communication asynchronous (GitHub Issues, DDP events) rather than synchronous shared state. But that's an architectural choice with its own tradeoffs, not a proof that files scale here.

**Schema enforcement and migration.** A database schema enforces structure and provides migration tooling. File-based state with free-form markdown has no enforcement. As the entity format evolves, old files won't conform to new expectations without manual migration. This is manageable at small scale; it becomes a maintenance burden at scale.

**Full-text search at scale.** grep is fast for small corpora; it doesn't scale to millions of documents. A database with a full-text index (Postgres with pg_trgm, MongoDB Atlas Search, Elasticsearch) outperforms grep at scale.

**ACID for critical state.** If entity operational state included financial transactions, access control decisions with real-world consequences, or medical records, the lack of full ACID guarantees in the file/git model would be disqualifying. koad:io's current use case doesn't hit this threshold. A deployment of the same architecture for enterprise compliance would.

**The honest summary:** Files + git win for identity, history, and operational memory at the scale of dozens to hundreds of entities. A database starts winning when you need structured queries across millions of records, concurrent multi-writer semantics, or ACID guarantees for mission-critical state. koad:io's architecture is correct for its actual scale and use case — not universally correct.

---

## Confidence Summary

| Claim | Confidence |
|-------|-----------|
| Lampson/Gray & Reuter: access pattern determines storage choice | High |
| Entity state access pattern favors sequential/append-write | High |
| Git provides content-addressable, append-only, atomic-commit guarantees | High |
| Git lacks query language, multi-writer support, sub-commit transactions | High |
| koad:io MongoDB/git split maps to ops data store vs. record of system | Medium-High |
| Partial-write and crash recovery are real residual risks for file-based state | High |
| Database genuinely wins for multi-entity shared state and large-scale queries | High |

---

## Sources

**Classic CS literature:**
- Lampson, B. (1983). "Hints for Computer System Design." ACM SIGOPS Operating Systems Review, 17(5). [ACM DL](https://dl.acm.org/doi/10.1145/773379.806614)
- Gray, J. & Reuter, A. (1992). *Transaction Processing: Concepts and Techniques.* Morgan Kaufmann.
- McIlroy, M. D. (1978). "Unix Time-Sharing System: Forward." Bell System Technical Journal, 57(6). (Unix philosophy memo)
- Kleppmann, M. (2017). *Designing Data-Intensive Applications.* O'Reilly. Chapters 3, 10.

**Git internals and guarantees:**
- Torvalds, L. (2005). Git design notes and initial commit messages. [GitHub](https://github.com/git/git)
- Git documentation: "Git Internals — Git Objects." [git-scm.com](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
- SHA-1 → SHA-256 migration: [git hash-object documentation](https://git-scm.com/docs/hash-function-transition)

**Log-structured storage:**
- O'Neil, P. et al. (1996). "The Log-Structured Merge-Tree (LSM-Tree)." Acta Informatica. [Springer](https://link.springer.com/article/10.1007/s002360050028)
- Rosenblum, M. & Ousterhout, J. (1992). "The Design and Implementation of a Log-Structured File System." ACM TOCS. [ACM DL](https://dl.acm.org/doi/10.1145/146941.146943)

**Related Sibyl research:**
- `2026-04-04-filesystem-as-context.md` — ICM paper (arxiv:2603.16021) and prior art on filesystem-as-architecture
- `2026-04-05-files-on-disk-vs-cloud-brief.md` — Day 11 sovereignty argument (Kleppmann local-first, incident record)
- `2026-04-05-daemon-architecture-patterns.md` — MongoDB/DDP daemon architecture

---

## Framing Notes for Faber

**The engineering hook in one sentence:** The access pattern is the answer — and agent identity/operational state is almost perfectly aligned with what files and git are optimized for.

**What this post is NOT:** It's not the sovereignty argument (Day 11 owns that). Don't mention vendor lock-in, cloud failures, or "not your keys." This audience dismisses that framing. Lead with Lampson. Lead with "here's what the literature says about when to use a database."

**The koad:io architecture reveal:** About 2/3 through the post, reveal that koad:io uses both — git for identity/history, MongoDB for real-time shared state — and that this separation is principled, not accidental. The engineer audience will find this credible precisely because it's not "files always win." It's "choose the tool whose access pattern matches the workload."

**The honest counterargument earns credibility:** Faber should spend ~150 words on where a database genuinely wins. Engineers smell ideological arguments immediately. Acknowledging that database wins for multi-entity shared state and large-scale queries positions the rest of the argument as engineering analysis, not advocacy.

**The landing:** Git is doing more than version control here. Content-addressable storage, append-only history, atomic commits, distributed replication — these are database properties. The engineer audience will find it interesting that git is, for this workload, a surprisingly capable database. Name it. "Git is a specialized database and for this access pattern it's arguably the right one."
