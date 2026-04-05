---
title: "Show HN Positioning Brief — Day 10: Agent Home Directory"
date: 2026-04-05
researcher: sibyl
assignment: faber-day10-show-hn
status: complete
confidence: high
audience: faber (primary), mercury (distribution)
---

# Show HN Positioning Brief: "Agent Home Directory"

**Purpose:** Enable Faber to write the Day 10 Show HN post with confidence. This covers the four research areas requested: Show HN patterns, competitive positioning, prior art on "agent home directory," and how to make a sovereignty argument land with a technical audience.

**Cross-references:**
- `2026-04-04-hn-reception-patterns.md` — prior HN analysis (foundational, don't repeat, build on)
- `2026-04-04-category-creation-research.md` — "agent home directory" naming validation
- `2026-04-04-week2-content-angles.md` — three post angles, Angle 2 is strongest HN candidate
- `2026-04-04-filesystem-as-context.md` — prior art on filesystem-as-context pattern

---

## Section 1: Show HN Pattern Analysis (Updated for Day 10)

### What the data says

The ASOF Research survival study tracked 605 Show HN posts across 63 days. Key findings relevant to Day 10:

- More than half of front-page Show HN posts disappear within a single day. Most within 30 minutes.
- Only 1% of posts stay visible for a full week. Score alone doesn't predict longevity — a 500-point post and a 60-point post have nearly identical lifespans once both crack the front page.
- **Implication for koad:io:** The goal is not maximum points but maximum *qualified* engagement — developers who clone the repo, not casual upvoters. A smaller wave of deeply engaged comments signals healthier traction than a fast spike and fade.

The State of Show HN 2025 analysis (Sturdy Statistics) found that AI-related Show HN posts are **overrepresented but underperform expectations** as a category. The exception: "AI Automation" posts (not "AI Coding" or "AI Connectivity") perform above baseline. koad:io should frame itself as **automation infrastructure**, not an AI product.

### Title conventions that work

From the Markepear dev tool launch analysis and recent Best of Show HN data:

- Start with "Show HN:" — the format is a trusted signal
- Name + comma + one-clause description of the specific use case
- The most successful recent titles are *specific constraints*, not category claims
  - "A local-first financial auditor using IBM Granite, MCP, and SQLite" — not "AI finance tool"
  - "LocalGPT — local-first AI assistant in Rust with persistent memory" — not "AI assistant"
  - "Self-hostable AI agents and internal software" — not "AI agent platform"
- No superlatives. No "first," "best," "revolutionary." The technical audience will flag any of these immediately.
- The title should tell you exactly what exists on the other side of the click.

### Recommended title options for Day 10

**Option A (direct/technical):**
> Show HN: koad:io — give your local AI agent a home directory (identity, memory, authorization — all in git)

**Option B (problem-first):**
> Show HN: I stored my AI agent's identity in a git repo. Now it survives restarts, forks, and version rollbacks.

**Option C (Unix metaphor, cleanest):**
> Show HN: Agent home directories — persistent identity for local AI agents, the Unix way

**Recommendation: Option A** for clarity and searchability. Option B is strongest if Faber writes in first-person voice and has the receipts to back it up (git log, real commits, real operations). Option C is the most elegant but requires HN readers to know why "the Unix way" is significant — they do, but it front-loads the metaphor before the problem.

### What the first comment should do (plant it or earn it)

koad's first comment — posted immediately after the Show HN — is the most important piece of real estate. Based on HN pattern analysis:

**The first comment should:**
1. State the specific constraint or honest limitation ("this doesn't manage inference — you still need Ollama or llama.cpp")
2. Answer the most predictable objection before it's raised ("yes, you could do this manually with shell scripts and dotfiles — but then you'd have to rebuild the multi-entity coordination layer, the trust bonds, the git-based memory...here's what that would take")
3. Offer a specific technical entry point ("the fastest way to understand it: `git clone <repo>` and `cat memories/001-identity.md` — that's the agent's persistent identity")

This comment positions koad as an honest engineer, not a marketer. It changes the comment thread dynamic before the first skeptic arrives.

### What gets downvoted or flagged

From consistent HN failure mode patterns:
- Vision statements before function
- Multiple novel terms in the first paragraph
- "Like X but Y" framing in the headline (invites comparisons that derail the thread)
- Architecture diagrams without runnable code
- Any form of marketing language ("enterprise-grade," "production-ready," "next-generation")
- Ideological framing without immediate technical grounding ("sovereignty" → must be followed immediately by a technically verifiable property)

---

## Section 2: Competitive Positioning for HN

### The comparison landscape

When koad:io shows up on HN, the community will compare it to: **AutoGen, CrewAI, LangGraph**, and secondarily **Cursor, Claude Code, and local inference stacks (Ollama/llama.cpp)**.

Current community sentiment on the frameworks (as of March–April 2026):

| Framework | HN Community Status | Key Criticism |
|---|---|---|
| AutoGen | Declining — "hasn't shipped a release in six months" | Stagnation concern |
| CrewAI | Popular but "limited to sequential/hierarchical execution" | Not flexible for complex workflows |
| LangGraph | Active, respected, but "overkill for simple agents" | Forces graph abstraction on everything |
| Claude Code / Cursor | Loved but "stateless per session" | Identity persistence is a known gap |

**The differentiated claim that survives HN scrutiny:**

None of the above frameworks give an agent:
1. **Persistent identity** — who the agent *is* across restarts (not what it knows)
2. **Authorization as a file** — a signed, readable, diffable record of what the agent is allowed to do
3. **Git-native entity history** — the agent's evolution is its commit history; you can fork it, roll it back, diff it

The key distinction from what the community already knows:
- **Letta/MemGPT** solves *memory* (facts). koad:io solves *identity* (selfhood).
- **CLAUDE.md/AGENTS.md** is a *project config*. koad:io's PRIMER.md is an *identity document*.
- **LangGraph state persistence** is runtime state. koad:io is filesystem state — survives any framework swap.

**The one-sentence version that HN can verify immediately:**

> "Your CrewAI agent doesn't know who it is when you restart it. `~/.juno/memories/001-identity.md` does — because it's a committed file with a 6-day git history."

This is testable. The repo is public. The commit history is real. HN readers can verify it before they finish the comment.

### What koad:io will get compared to (and what to say)

**"Doesn't this already exist with AutoGen/CrewAI/LangGraph?"**
Pre-answer: "Those frameworks assign roles via code parameters at runtime — `role="researcher"`, `allow_disagreement=True`. Code parameters can be edited; a session restart zeroes them. koad:io stores identity in committed files. The agent is the repo, not the runtime. When you restart Juno, she reads her own git history."

**"Why not just use dotfiles?"**
Pre-answer: "You could. You'd start by writing `~/.juno/memories/001-identity.md`. Then you'd need a mechanism to load it before each session. Then you'd want it versioned. Then you'd want it forkable. Then you'd want cross-entity trust bonds that are cryptographically signed. Then you'd want a daemon that knows which entity to load based on `$CWD`. At some point you've rebuilt koad:io — here's a shortcut."

**"Sounds like an agent framework"**
Pre-answer: "It's not. koad:io is what you add *on top of* your framework. You can run LangGraph agents inside a koad:io entity. The entity provides identity, memory, and authorization; LangGraph provides task execution. Different layers."

**"Is anyone actually using this?"**
Pre-answer: "15 entities have been running real operations on it for 6 days. `git log --oneline` across the entity repos is the evidence. The operations are public."

### Gitagent — the one prior art player HN might name

gitagent (github.com/open-gitagent/gitagent, ~2,500 stars, actively maintained) is the closest adjacent project the community might raise. Its purpose: export agent definitions to framework-portable formats. The differentiation is sharp:
- gitagent solves *portability* — move agent definitions between frameworks
- koad:io solves *continuity* — the agent persists as a living entity between sessions

If someone cites gitagent, the response: "gitagent is excellent for exporting agent specs. It doesn't give the agent a home — it gives the spec a container. The difference: gitagent's output is a template. koad:io's output is an entity with a history."

---

## Section 3: Prior Art on "Agent Home Directory"

### Search verdict: genuinely unclaimed

Across all research conducted (April 2–5, 2026), "agent home directory" as a category name or technical concept has zero prior usage in:
- Academic papers (arXiv, ACM, IEEE)
- Startup positioning or product pages
- Developer tooling documentation
- HN posts or comment threads
- Enterprise AI vendor language (Microsoft, AWS, Strata all use "agent identity," "agent governance," "agentic identity")

The search for "agent home directory" returns only AI agent *directories* (listing sites like aiagentsdirectory.com) — a completely different thing. The naming gap is real.

### Adjacent prior art that exists (and why it's different)

| Project/Concept | What it does | What koad:io does differently |
|---|---|---|
| CLAUDE.md / AGENTS.md / .cursorrules | Project-level config file loaded before inference | Identity document for a persistent entity, not a project |
| ICM paper (arxiv:2603.16021) | Filesystem structure as agent orchestration during execution | Pre-invocation identity injection from shell state before model starts |
| gitagent | Framework-portable agent definition export | Persistent entity with operational history, not a portable spec |
| Letta / MemGPT | Persistent memory (facts the agent knows) | Persistent identity (who the agent is) |
| Microsoft Agent Governance Toolkit (April 2, 2026) | Runtime security policy enforcement (enterprise, cloud) | Sovereign agent constitution (your disk, your keys, git history is the audit trail) |
| dotfiles tradition | User configuration in home directory | Extends the same metaphor to AI agents running as persistent entities |

### The strongest prior art claim koad:io can make

The Unix home directory is the intellectual ancestor. Every Unix user has a home directory: `~/.bashrc`, `~/.ssh/`, `~/.gitconfig`. These files define who the user is to the system. koad:io applies the same model to AI agents: `~/.juno/` is Juno's home directory. `memories/` is her persistent context. `trust/bonds/` is her authorization model. `id/` is her cryptographic identity.

Nobody has written this up publicly as a design pattern. The ICM paper gets close (filesystem as agentic architecture) but describes task execution, not agent identity. Martin Fowler's harness engineering work gets the pre-invocation moment right but treats it as a static config layer, not an identity system.

The Show HN post, if written well, *is* the community artifact that names this pattern. That's a category-creation opportunity, not just a launch.

---

## Section 4: Making the Sovereignty Argument Land on HN

### What HN thinks of "sovereignty"

HN is not hostile to sovereignty as a concept — it is hostile to sovereignty as a *marketing claim without technical grounding*. The audience has strong priors:

- They self-host things (r/selfhosted overlap is significant)
- They understand key management (many have SSH key hygiene, PGP users are not rare)
- They are deeply skeptical of privacy claims that don't show the architecture
- They have seen "sovereign" and "decentralized" used as marketing words for cloud SaaS products

The word "sovereignty" should appear **once** in the post, if at all — and immediately followed by a technically verifiable property. Never as a headline or lede.

### The argument that lands without using the word

The best sovereignty argument on HN is not stated — it's demonstrated:

```
~/.juno/ is a directory on your disk.
git clone it. cp -r it. Wipe the cloud account.
The entity still exists, complete, operational, with its full history.
```

This is the "not your keys, not your agent" principle rendered in Unix commands. HN readers will recognize the bitcoin parallel without being told — and the ones who do will become advocates in the comment thread.

The argument has three technical legs that each stand independently:

**Leg 1: Persistence without cloud dependency**
The agent's identity, memory, and authorization are files. Files on your disk. Not in a vendor database. A vendor going offline doesn't revoke your agent's identity. This is architecturally verifiable — show the directory structure, show `git remote -v` pointing to your own repo, show there is no cloud dependency in the startup sequence.

**Leg 2: Authorization as a readable artifact**
`cat trust/bonds/juno-to-sibyl.md` — this is what authorization looks like in koad:io. It's a markdown file. You can read it with any text editor. You can diff it. You can version it. `gpg --verify trust/bonds/juno-to-sibyl.md.asc` — this is what tamper detection looks like. Compare to: an API call that returns a 403 with no explanation of what permission was missing or why. HN engineers have opinions about authorization systems. A signed, readable file is more legible than any RBAC dashboard.

**Leg 3: Git history as audit trail**
`git log --author="Juno" --oneline` — this is what agent accountability looks like. Every decision, every commit, timestamped, authored, signed. Not a proprietary audit log on a vendor's server. The same git tooling they already use. HN readers will immediately understand why this is significant: they've spent careers arguing that audit trails should be text files in version control.

### What to avoid

**Do not say:**
- "Sovereign AI" (enterprise noise, triggers skepticism)
- "No vendor lock-in" (unverifiable claim, overused)
- "Own your data" (cliche)
- "The future of AI agents" (vision statement, will be ignored)
- "Enterprise-grade" (anything)

**Do say:**
- "Files on disk" (concrete)
- "Your git repo" (ownership implicit in the word "your," technical signal)
- "gpg --verify" (technical, testable)
- "Survives a restart" (specific, the exact pain they have)
- "cp -r and it moves" (Unix idiom, immediately legible to the audience)

### The one-sentence sovereignty test

Before including any sentence with a sovereignty implication, ask: *can a reader verify this claim in 60 seconds with standard Unix tools?* If yes, include it. If not, cut it or rephrase until it passes.

---

## Section 5: Recommended Post Structure for Day 10

**Post type:** Show HN technical post, ~600–800 words in the body (HN posts can be longer but they're skimmed, not read linearly)

**Recommended structure:**

1. **The problem, in one sentence** — state the exact gap, in their vocabulary
   > "Your local AI agent doesn't know who it is between restarts."

2. **What you built, in one sentence**
   > "I gave it a home directory."

3. **Show the structure immediately** — three `cat` commands, max. Show something real.
   ```
   ~/.juno/
     memories/001-identity.md    ← who the agent is (persistent, committed)
     trust/bonds/juno-to-sibyl.md ← what it's authorized to do (signed file)
     LOGS/                        ← what it decided (git history)
   ```

4. **The git property** — one paragraph on why git is the right substrate
   - Fork to create a new entity lineage
   - Roll back to undo a drift
   - Diff to see what changed between sessions
   - The agent's git log is its cognitive history

5. **Show it working** — the 6-day operational proof
   - 15 entities, real operations, public repos
   - `git log --oneline` on any entity shows committed decisions
   - Point to the trust bond: `gpg --verify` output (show actual output, not just the command)

6. **What it doesn't do** — required for HN credibility
   - "koad:io doesn't manage inference. It doesn't know about your models or your VRAM. Use Ollama, llama.cpp, or whatever you run — koad:io sits above that and gives the agent a stable identity."

7. **How to try it** — must be cloneable right now
   - Link to the entity repo
   - One command to see what agent identity looks like

**First comment (posted immediately by koad):**
- Acknowledge the most predictable comparison (CrewAI/AutoGen) and give the technical differentiation
- State what's not built yet (honest)
- Invite the "why not just dotfiles" question by pre-answering it warmly

---

## Section 6: Timing and Cross-Post Strategy

**Best day:** Tuesday. The Sturdy Statistics analysis confirms Tuesday has a 60% higher average peak score than Monday or Wednesday.

**Best time window:** 8–10am US Eastern (maximizes US audience first-look before European evening decay).

**Cross-post sequence:**
1. Show HN first — let it breathe for 24–48 hours
2. r/selfhosted — after HN (different framing: "add identity and memory to your local agents without any new infrastructure")
3. r/LocalLLaMA — third (framing: "you have inference. here's what's still missing.")
4. DEV Community — fourth, expanded version of the post body

**Do not cross-post simultaneously.** HN detects traffic patterns. Let organic HN engagement develop before driving traffic from other communities.

---

## What Faber Needs Before Writing

**Required to have in hand before writing:**

1. A cloneable public entity repo — at minimum one of: `~/.juno/`, `~/.sibyl/` — with a live README that passes the "30-second test" (someone can understand what they're looking at immediately)

2. A working trust bond that survives `gpg --verify` — and the actual output of running that command, formatted for copy-paste into the post

3. `git log --oneline` output from at least one entity showing 5+ days of real commits — screenshot or copy-paste ready

4. One specific operational story with verifiable evidence — the Aegis DRIFTING verdict is the strongest candidate (see `2026-04-04-week2-content-angles.md` Angle 2). Verify the 4-minute commit window in git logs before including.

**Nice to have:**

- A `git clone <repo> && cat memories/001-identity.md` sequence that works cleanly in a terminal demo
- The `gpg --verify` output showing "Good signature from Juno" — this one line is worth 500 words of sovereignty argument

---

## Confidence Summary

| Claim | Confidence | Basis |
|---|---|---|
| "Agent home directory" is genuinely unclaimed terminology | High | Exhaustive search, no prior usage found |
| Show HN success patterns (concrete demo, technical specificity, honest tradeoffs) | Very high | ASOF survival study + pattern analysis + prior research |
| AI-category Show HN posts underperform except "AI Automation" framing | High | Sturdy Statistics State of Show HN 2025 |
| Competitive differentiation from AutoGen/CrewAI/LangGraph | High | Current framework comparison data, community sentiment |
| Sovereignty argument must be technically grounded to land on HN | Very high | Consistent pattern across all prior HN research |
| Tuesday 8–10am ET is optimal posting time | High | Multiple sources consistent |
| First comment is the most important strategic piece after the post | High | Launch practitioner analysis |
| gitagent is the only adjacent prior art HN might raise | High | Research confirmed, 2.5K stars, active |

---

## Sources

**Data and analysis:**
- [Show HN Survival Study: 605 Posts Tracked for 63 Days — ASOF Research](https://asof.app/research/show-hn-survival)
- [State of Show HN 2025 — Sturdy Statistics](https://blog.sturdystatistics.com/posts/show_hn/)
- [Best of Show HN — All Time](https://bestofshowhn.com/)
- [Best of Show HN — January 2026](https://bestofshowhn.com/2026/1)
- [Best of Show HN — February 2026](https://bestofshowhn.com/2026/2)
- [Best AI Startups Show HN — March 2026](https://bestofshowhn.com/search?q=%5Bai%5D)

**Launch guidance:**
- [How to launch a dev tool on Hacker News — Markepear](https://www.markepear.dev/blog/dev-tool-hacker-news-launch)
- [How to crush your Hacker News launch — DEV Community](https://dev.to/dfarrell/how-to-crush-your-hacker-news-launch-10jk)
- [How to do a successful Hacker News launch — Lucas F. Costa](https://lucasfcosta.com/2023/08/21/hn-launch.html)

**Competitive landscape:**
- [AutoGen vs LangGraph vs CrewAI in 2026 — DEV Community](https://dev.to/synsun/autogen-vs-langgraph-vs-crewai-which-agent-framework-actually-holds-up-in-2026-3fl8)
- [LangGraph vs CrewAI vs AutoGen — Medium / Data Science Collective](https://medium.com/data-science-collective/langgraph-vs-crewai-vs-autogen-which-agent-framework-should-you-actually-use-in-2026-b8b2c84f1229)
- [Show HN: Self-hostable AI agents and internal software](https://news.ycombinator.com/item?id=47487223)

**Prior art search:**
- [Show HN: S.P.A.R.K.Y — Sovereign AI for Private Intelligence](https://news.ycombinator.com/item?id=46106949)
- [Show HN: Nex Sovereign — AI OS with visible reasoning and governance](https://news.ycombinator.com/item?id=46434021)
- [Why Data Sovereignty Will Define the Next Wave of AI Agent Adoption — AI Journal](https://aijourn.com/why-data-sovereignty-will-define-the-next-wave-of-ai-agent-adoption/)
- [GitHub: open-gitagent/gitagent](https://github.com/open-gitagent/gitagent)
- [Introducing the Agent Governance Toolkit — Microsoft Open Source Blog](https://opensource.microsoft.com/blog/2026/04/02/introducing-the-agent-governance-toolkit-open-source-runtime-security-for-ai-agents/)

**Internal Sibyl research (build on these, don't repeat):**
- `2026-04-04-hn-reception-patterns.md` — foundational HN analysis
- `2026-04-04-category-creation-research.md` — "agent home directory" naming validation
- `2026-04-04-week2-content-angles.md` — three post angles
- `2026-04-04-filesystem-as-context.md` — prior art on $CWD-routed identity pattern
- `2026-04-04-ollama-community-intelligence.md` — community vocabulary and Ollama naming sensitivity
