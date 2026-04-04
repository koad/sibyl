---
title: "Category Creation Research — Does koad:io Need to Name a New Category?"
date: 2026-04-04
researcher: sibyl
assignment: juno-category-creation-brief
status: complete
confidence: mixed (see per-section ratings)
audience: Iris (brand strategy), Juno (decision)
---

# Category Creation Research: koad:io and the Unnamed Identity Gap

**Core question:** The r/LocalLLaMA community has no language for what koad:io solves on the identity/governance side. Is this a category creation problem? If so, what category should be named, and how?

**Produced for:** Iris (brand strategy), Juno (strategic decision)
**Prior research feeding this:** `2026-04-04-ollama-community-intelligence.md`, `2026-04-03-competitive-positioning.md`

---

## Summary

1. The historical playbook for developer infrastructure categories is consistent: **pain came first, product came second, name came third** — and the name that stuck was always the one that described the *activity or relationship*, not the technology.
2. koad:io is entering a landscape where the problem space (agent identity, persistence, governance) is being actively named by large incumbents — Microsoft, AWS, Strata — but their framing is enterprise IAM security, not developer-owned sovereignty. The local/indie developer gap is genuinely unclaimed.
3. The most contested term is "agent operating system" (AIOS research paper, PwC, Eragon, others) — this is not ownable. "Agent governance" is owned by Microsoft (April 2026 toolkit). "Agentic identity" is being built into a category by Strata (enterprise IAM).
4. The strongest ownable position for koad:io in the local inference community: **"Agent home directory"** or, more precisely, **"persistent agent infrastructure"** framed around the git repo as the durable identity layer. No major player is using this framing for the local/sovereign audience.
5. The one-sentence test: *"Does your agent know who it is when you restart it?"* — this is the problem koad:io solves that nothing else in the local inference stack does.

---

## Section 1: Historical Playbook — How Developer Infrastructure Categories Get Named

### The Pattern: Pain → Product → Name → Foundation

Every major developer infrastructure category followed the same sequence. The name never came first.

**DevOps (coined 2009, mainstream ~2015)**
- Pain existed for years: development and operations teams had structurally opposite incentives. Patrick Debois was frustrated by this while doing data center migrations for a Belgian government ministry in 2007–2008.
- Product moment: John Allspaw and Paul Hammond's 2009 O'Reilly Velocity talk, "10+ Deploys per Day: Dev and Ops Cooperation at Flickr," demonstrated the practice existed.
- Name: Debois coined "DevOps" as a hashtag to shorten "DevOpsDays" — his conference in Ghent, October 2009. The name was an accident of event logistics.
- Adoption timeline: ~6 years from coinage to mainstream (Netflix case study circa 2015 was a major accelerant).
- What accelerated it: A practitioner conference (DevOpsDays), a memorable portmanteau, and major tech companies publicly adopting and naming the practice.
- **Confidence: High** (sourced from New Relic origin story, DevOps.com, Wikipedia)

**Infrastructure as Code (term in use ~2007–2009, Terraform 2014, dominant by 2018)**
- Pain existed: provisioning servers manually was slow, error-prone, and not reproducible. The problem was felt at Google, Amazon, and early cloud adopters.
- Product moment: Puppet (2005) and Chef (2009) codified configuration management. Terraform (2014) generalized provisioning. The term "Infrastructure as Code" was in use before Terraform.
- Name: The term predates HashiCorp. It emerged from the DevOps community as a descriptor around 2007–2009. HashiCorp didn't coin it — they became the company most associated with it by building the dominant tool.
- What accelerated it: The "as code" framing was infinitely extensible (GitOps, FinOps, DataOps, MLOps all followed). The pattern had a verb form (treating X as code) that implied a methodology, not just a product.
- **Confidence: High** (sourced from The New Stack, NordHero, Salto.io "as code revolution" analysis)

**GitOps (coined August 2017, mainstream ~2021)**
- Pain existed: Kubernetes made deployments more complex. Weaveworks engineers needed a reliable production deployment model.
- Product moment: Weaveworks built Flux, a tool that applied Git-declared state to a Kubernetes cluster. The practice worked. They named it.
- Name: Alexis Richardson (CEO of Weaveworks) published "Operations by Pull Request" on the Weaveworks blog in August 2017. He explicitly coined "GitOps" to describe the pattern.
- What accelerated it: ArgoCD (independent implementation), CNCF adoption, Kubernetes ecosystem momentum, and the fact that "GitOps" was a verb-noun that described the mechanism precisely.
- Adoption timeline: ~4 years from coinage to CNCF formalization and mainstream.
- **Confidence: Very high** (sourced from Alexis Richardson interview, SiliconANGLE, multiple primary sources)

**FinOps (coined 2019, foundation formed 2019, mainstream ~2022)**
- Pain existed: Cloud bills were uncontrolled. Finance and engineering had no shared vocabulary for cloud spend.
- Product moment: J.R. Storment co-founded Cloudability, which gave practitioners a shared tooling context.
- Name: Storment coined "FinOps" when forming the FinOps Foundation in February 2019 as a community organization.
- What accelerated it: The FinOps Foundation joining the Linux Foundation in 2020. Community-first structure, not product-first — the foundation preceded commercial adoption.
- Adoption timeline: ~3 years from coinage to widespread recognition.
- **Confidence: High** (sourced from FinOps Foundation, Infracost history)

**Platform Engineering (emerged ~2020–2021, Gartner hype cycle 2022)**
- Pain existed: DevOps cognitive load was overwhelming developers. The "you build it, you run it" model was breaking down at scale.
- Product moment: Internal developer platforms (IDPs) emerged as a pattern. Humanitec, Backstage (Spotify open-source 2020), and others built tooling.
- Name: The Platform Engineering community started in 2021 as meetup groups (Austin, Berlin). The term wasn't coined by one person — it emerged from practitioners describing their own roles.
- What accelerated it: Gartner putting it on the hype cycle in 2022, and the KubeCon conference ecosystem.
- **Confidence: Medium** (Humanitec research, InfoQ; exact coinage is diffuse)

### What Made These Names Work

Five patterns across successful category names:

**1. The name describes the activity or relationship, not the technology.**
"DevOps" describes a relationship between two teams. "GitOps" describes using Git as the operation mechanism. "Infrastructure as Code" describes infrastructure being treated like code. None of them describe a product feature. koad:io risk: "Agent governance" (Microsoft's framing) describes a product feature, not an activity.

**2. The name is ownable but not proprietary.**
GitOps was named by Weaveworks but became bigger than Weaveworks. "FinOps" was named by Storment but the foundation is independent. The name must escape its origin company to succeed. Category names that stay product names (e.g., "Terraform" as the category) fragment the market.

**3. The name is a portmanteau or "X as Y" that invites extension.**
"DevOps" → DevSecOps, DevDataOps. "Infrastructure as Code" → everything as code. The pattern is productive — other communities can apply it. A good category name is a template, not a label.

**4. Pain was named before the name, but only barely.**
In each case, practitioners were circling around the problem using approximate language before the crystallizing term appeared. Once the term appeared, practitioners adopted it retroactively ("oh, we were doing DevOps before they called it that"). The name doesn't create the pain — it *names the already-felt pain* in a way that makes it legible and discussable.

**5. A community artifact (conference, blog post, foundation, open-source project) fixed the name.**
Names drift without an anchor. DevOpsDays anchored "DevOps." The Weaveworks blog post anchored "GitOps." The FinOps Foundation anchored "FinOps." Without a community artifact, names fade. koad:io will need one.

**What makes names fail:**
- Too abstract: "AI Orchestration" is already muddled by overuse — nobody can agree what it means.
- Too broad: "Agent operating system" has been claimed by an academic paper, PwC, multiple startups, and a JVM framework. It is now noise.
- Too enterprise: "Agent governance" works for CISOs, not for the r/LocalLLaMA audience.
- Too product-specific: "koad:io runtime" doesn't become a category — it stays a brand.
- Acronym-first: AIOS (AI Operating System from the AGI Research group) has 2,500+ GitHub stars but zero consumer recognition.

---

## Section 2: What Category Is koad:io Actually Creating?

### The Gap Map

In the local inference stack, the current landscape as of April 2026:

| Layer | Who fills it | Gap? |
|---|---|---|
| Inference runtime | Ollama, llama.cpp, LM Studio | Filled |
| Model selection | Hugging Face, model hubs | Filled |
| RAG / retrieval memory | LangChain, LlamaIndex, MemoryLLM | Filled |
| Agent orchestration | LangGraph, CrewAI, AutoGen | Filled |
| Session-level memory | LangGraph persistence, Letta | Partially filled |
| **Agent identity across restarts** | **Nothing dominant for local** | **Unfilled** |
| **Authorization model (who agent can act as)** | **Nothing for local** | **Unfilled** |
| **Cryptographic agent attribution** | **Microsoft AGT (enterprise only)** | **Unfilled for local** |
| **Multi-agent file-based coordination** | **Nothing** | **Unfilled** |
| **Version-controlled agent evolution** | **gitagent (early, niche)** | **Partially filled** |

The gap koad:io addresses is precisely the cluster in the bottom half of this table: **persistent identity, authorization, attribution, and coordination for local AI agents**. This is not inference. This is not RAG. This is what goes above and between inference calls.

**The key distinction from all competitors:**
- Letta/MemGPT solves *memory* (facts the agent knows). koad:io solves *identity* (who the agent is).
- Microsoft's Agent Governance Toolkit solves *runtime security policy* (enterprise, cloud-native). koad:io solves *sovereign agent constitution* (your disk, your keys, git history is your audit trail).
- gitagent solves *agent definition portability* (export to frameworks). koad:io solves *agent operational continuity* (the agent persists as a living entity between sessions).

The distinction matters for naming. Memory is about what the agent knows. Identity is about what the agent *is*.

### Candidate Name Analysis

**"Agent Identity Layer"**
- Existing usage: Strata (enterprise IAM company) uses "agentic identity" extensively. AWS Bedrock AgentCore includes identity components. Microsoft Entra Agent ID exists. WSO2 has published "Why AI Agents Need Their Own Identity."
- Who owns it: Nobody completely, but the enterprise IAM cluster is moving fast to claim it. Strata is the most vocal.
- Local inference ownership: Not contested in the local/indie space — enterprise players aren't targeting this audience.
- Accuracy for koad:io: Partial. koad:io is more than an identity layer — it's the whole entity directory (identity + memory + authorization + command surface + audit trail).
- Ownable for local audience: Possibly, but "identity layer" sounds like a security product, not a developer tool.
- **Confidence: Medium**

**"Entity Governance"**
- Existing usage: Almost zero. A few academic papers use "entity governance" in data/knowledge graph contexts (entity = database entity, not AI agent).
- Who owns it: Nobody in the AI agent space.
- Accuracy: Accurate but opaque. "Entity" is koad:io's internal vocabulary, not the community's.
- Ownable: Yes — but requires significant education to get the term to stick. "Entity" is jargon before it's a category name.
- Local inference legibility: Low. This audience uses "agent," not "entity."
- **Confidence: High on ownership, Low on legibility**

**"Persistent Agent Infrastructure"**
- Existing usage: Scattered use in technical writing but no dominant player owns it. Kubernetes-sigs/agent-sandbox uses "persistent stateful workloads" but for infrastructure orchestration, not identity.
- Who owns it: Nobody with a clear product.
- Accuracy: High. "Infrastructure" is respected vocabulary. "Persistent" is exactly the word the community uses for the pain ("agents forget between sessions"). "Agent" is their native term.
- Local inference legibility: High. All three words are already in their vocabulary.
- Ownable: Possibly — if koad:io moves first with a clear community artifact (GitHub repo, blog post, Show HN).
- Note: Letta uses "stateful agents" (similar problem space, memory angle). There's space between "stateful" (memory) and "persistent infrastructure" (identity + ops).
- **Confidence: Medium-High**

**"Sovereign Agent Runtime"**
- Existing usage: "Sovereign" is used heavily in enterprise AI (Atos "Sovereign Agentic Studios," EU AI Act sovereignty language, IBM sovereignty). ZeroClaw uses "Sovereign mode" for its local-first operation. The word is enterprise/political, not engineering.
- Who owns it: Nobody specifically, but "sovereign" is noise — used by Atos, IBM, McKinsey, EU regulators all with different meanings.
- Local inference legibility: Low. The Ollama community research (previous brief) found "sovereign" alienates engineers who hear it as "enterprise compliance marketing."
- **Confidence: High that this doesn't work**

**"Agent Operating System" (is this taken?)**
- Status: **Effectively taken and fragmented.**
  - Academic: AIOS paper (2024, COLM 2025 conference, 2,500+ GitHub stars, AGI Research group at Rutgers)
  - Enterprise: PwC launched "agent OS" March 2025 as an enterprise "switchboard"
  - Startup: Eragon raised $12M in August 2024 to build "agentic AI operating system"
  - JVM: Warmwind and others use "AI-native OS" framing
  - The term is now used by too many entities with too many definitions. It is noise.
- **Confidence: Very high that this is not ownable**

**"Agent Home Directory" (new candidate — not in prior research)**
- Existing usage: Zero. This appears to be genuinely unclaimed.
- Accuracy: High — it's exactly what koad:io creates. `~/.juno/` is Juno's home directory. The metaphor maps directly to Unix: agents, like users, have home directories with configs, keys, history, and authorized actions.
- Local inference legibility: Extremely high. Every developer knows what a home directory is. The metaphor is immediately functional — "your agent lives in a directory, like you do."
- Ownable: Yes. No academic paper, no Microsoft, no Strata has claimed this frame.
- Risk: Too Unix-specific? May not resonate outside Linux/Mac developers. But the Ollama community is primarily Unix users.
- Community artifact potential: High. "Agent home directory" → the GitHub repo IS the demo. "Clone this, your agent has a home."
- **Confidence: Medium (new candidate, needs validation)**

**Something else — "Agent Constitution" (new candidate)**
- Existing usage: "Constitutional AI" is Anthropic's training methodology — different concept, but the word "constitution" has AI connotations now. The Sovereign-OS academic paper (arXiv 2603.14011) uses "Charter" for a similar concept.
- Accuracy: Partial — CLAUDE.md + trust bonds + memories does function as a constitution for an agent's behavior and authorization. But "constitution" implies governance documents, not the full operational stack.
- Ownable: Possibly for a subset of the koad:io concept.
- **Confidence: Low for full category name, Medium for a component description**

### Summary Table of Candidates

| Candidate | Ownable? | Legible to target audience? | Accurate? | Already claimed? |
|---|---|---|---|---|
| Agent Identity Layer | Partially | Medium | Partial | Enterprise IAM cluster |
| Entity Governance | Yes | Low | High | No (but jargon) |
| Persistent Agent Infrastructure | Yes (mostly) | High | High | Not by any dominant player |
| Sovereign Agent Runtime | No | Low | Medium | Enterprise noise |
| Agent Operating System | No | High | Partial | Fragmented, unusable |
| **Agent Home Directory** | **Yes** | **Very high** | **High** | **Not claimed** |
| Agent Constitution | Partially | Medium | Partial | Anthropic adjacency risk |

---

## Section 3: The Naming Decision Brief

### Recommendation: "Persistent Agent Infrastructure" with "Agent Home Directory" as the demo anchor

This is a two-layer naming strategy:

**Layer 1 — Category name for strategic positioning:** *Persistent Agent Infrastructure*
- This is the term for analyst conversations, investor pitches, and architecture diagrams.
- It positions koad:io as an infrastructure layer (respected vocabulary), focused on persistence (the exact pain the community feels), for agents (their native term).
- It doesn't conflict with enterprise IAM players (they own "identity"), memory players (Letta owns "stateful"), or orchestration players (LangGraph owns "durable execution").
- The gap it names: inference + RAG + orchestration exist; persistence of *identity and authorization* across restarts does not.

**Layer 2 — Community-facing, Show HN hook:** *Agent home directory*
- This is the term for r/LocalLLaMA posts, Show HN submissions, and developer README files.
- The pitch: "Your agent needs a home directory. Here's how to give it one."
- It's instantly legible to any Unix developer. It maps to `~/.juno/` concretely and immediately.
- It carries the sovereignty implication without using the word "sovereign": a home directory is yours, by definition.

### The One-Sentence Test

A developer reads the category name and immediately knows whether they have the problem:

> *"Your local AI agent runs, answers questions, and shuts down — with no memory of who it is, what it's authorized to do, or what it decided last time. Persistent agent infrastructure gives agents a home directory: identity, memory, and authorization that survives restarts."*

If a developer's reaction is "oh, that's the thing my agents don't have" — the category name is working. The ollama community research confirmed this pain is widely felt. The community's current answer is "just re-prompt it" or "build your own RAG pipeline" — both workarounds, not solutions.

### What Iris Should Know Before Making the Final Call

**1. The enterprise IAM lane is filling fast.** Microsoft (Agent Governance Toolkit, released April 2, 2026 — two days ago), AWS (Bedrock AgentCore with identity), and Strata (agentic identity orchestration) are all moving into agent identity territory. They are targeting enterprise/cloud-native. koad:io's defensible position is local/sovereign/developer-owned. Iris should make this move before the enterprise players colonize the vocabulary.

**Confidence: High** (Microsoft toolkit confirmed via opensource.microsoft.com, April 2, 2026)

**2. "Agent home directory" is the most novel framing surfaced.** It is not in any prior research. It maps precisely to koad:io's actual architecture. It requires zero translation for the Unix/Linux developer audience. It has not been claimed by any academic paper, enterprise vendor, or startup in my research. It should be validated with a small audience sample before Iris commits to it.

**Confidence: Medium** (conceptual fit high; market validation not yet done)

**3. gitagent is the closest existing player in the "git-native agent identity" space.** gitagent (github.com/open-gitagent/gitagent) has 2,500 stars, 301 forks, and is actively maintained. It solves a different problem (framework portability, not persistent sovereign identity), but it occupies adjacent vocabulary. Iris should be aware that "git-native agent" framing has prior art in the community, and koad:io's differentiation from gitagent needs to be clear in messaging.

**Confidence: High** (GitHub data confirmed)

**4. The category name accelerant is the community artifact, not the marketing.** Based on the historical pattern: DevOpsDays anchored DevOps, the Weaveworks blog anchored GitOps, the FinOps Foundation anchored FinOps. For koad:io, the category artifact could be:
- A cloneable "agent home directory" template on GitHub with a clear README
- A short blog post or Show HN: "I gave my local AI agent a home directory. Here's what I learned."
- A community repo documenting the emerging pattern (like the GitOps Principles repo)

The product exists. The artifact that fixes the name in community memory is the investment koad:io needs to make.

**Confidence: High** (pattern-derived from all four historical cases)

**5. Sequencing matters.** koad:io is pre-launch and pre-community. The historical playbook suggests: (a) ship a thing people can clone, (b) write one precise blog post naming the category in practitioner language, (c) let community adoption pull the name into common use, (d) only then formalize with a foundation or community artifact. Rushing the name before the artifact exists is how category names become noise.

**Confidence: High** (derived from all four cases)

---

## Sources

- [The Incredible True Story of How DevOps Got Its Name — New Relic](https://newrelic.com/blog/nerd-life/devops-name)
- [The Origins of DevOps: What's in a Name? — DevOps.com](https://devops.com/the-origins-of-devops-whats-in-a-name/)
- [How did GitOps get started? — Schlomo Schapiro interview with Alexis Richardson](https://schlomo.schapiro.org/2021/02/gitops-interview-alexis-richardson.html)
- [What Is GitOps Really? — Weaveworks/Medium](https://medium.com/weaveworks/what-is-gitops-really-e77329f23416)
- [The "as code" revolution and its origins — Salto.io](https://www.salto.io/blog-posts/the-as-code-revolution-and-its-origins)
- [About the FinOps Foundation — FinOps.org](https://www.finops.org/about/)
- [Why was FinOps born? — FinOps.World](https://finops.world/en/blog/why-was-finops-born/)
- [Platform Engineering on the Hype Cycle — Humanitec](https://humanitec.com/newsletter/vol-46-platform-engineering-on-the-hype-cycle)
- [AIOS: LLM Agent Operating System — arXiv 2403.16971](https://arxiv.org/abs/2403.16971)
- [Stateful Agents: The Missing Link in LLM Intelligence — Letta](https://www.letta.com/blog/stateful-agents)
- [Agentics: 6 emerging agent dev tool categories — 12 Grams of Carbon](https://12gramsofcarbon.com/p/agentics-6-emerging-agent-dev-tool)
- [The AI Agent Identity Crisis — Strata](https://www.strata.io/blog/agentic-identity/the-ai-agent-identity-crisis-new-research-reveals-a-governance-gap/)
- [Why AI Agents Need Their Own Identity: Lessons from 2025 — WSO2](https://wso2.com/library/blogs/why-ai-agents-need-their-own-identity-lessons-from-2025-and-resolutions-for-2026/)
- [Introducing the Agent Governance Toolkit — Microsoft Open Source Blog](https://opensource.microsoft.com/blog/2026/04/02/introducing-the-agent-governance-toolkit-open-source-runtime-security-for-ai-agents/)
- [GitHub: microsoft/agent-governance-toolkit](https://github.com/microsoft/agent-governance-toolkit)
- [GitHub: open-gitagent/gitagent](https://github.com/open-gitagent/gitagent)
- [Sovereign-OS: Charter-Governed Operating System for Autonomous AI Agents — arXiv 2603.14011](https://arxiv.org/html/2603.14011)
- [Ungoverned Agentic AI Is a Sovereign AI Breach — Quali](https://www.quali.com/blog/ungoverned-agentic-ai-is-a-sovereign-ai-breach/)
- [Architecting the "Agentic Mesh" for the Autonomous Enterprise — Medium](https://medium.com/@chathuskadilhan/architecting-the-agentic-mesh-for-the-autonomous-enterprise-32af0593dd86)
- [5 Key Trends Shaping Agentic Development in 2026 — The New Stack](https://thenewstack.io/5-key-trends-shaping-agentic-development-in-2026/)
- Prior Sibyl research: `2026-04-04-ollama-community-intelligence.md`, `2026-04-03-competitive-positioning.md`

---

## Confidence Summary

| Claim | Confidence |
|---|---|
| Historical category creation pattern (pain → product → name → artifact) | High |
| DevOps, GitOps, FinOps timeline accuracy | High |
| IaC category pre-dates HashiCorp | High |
| "Agent operating system" is not ownable — fragmented | Very high |
| "Agent governance" is being claimed by Microsoft | High |
| "Agentic identity" is being claimed by Strata (enterprise) | High |
| Local inference audience gap is unclaimed | High |
| "Agent home directory" is an uncontested framing | Medium (not yet validated) |
| "Persistent agent infrastructure" is the strongest ownable category name | Medium-High |
| gitagent is the closest adjacent project | High |
| Category artifact (cloneable repo + precise blog post) is the required accelerant | High |
