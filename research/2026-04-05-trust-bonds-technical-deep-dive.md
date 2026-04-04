# Trust Bonds: Technical Deep-Dive
## Cryptographic Authorization in Multi-Agent AI Systems

**Filed:** 2026-04-05
**For:** Faber post `2026-04-06-trust-bonds.md` (in Veritas review at koad/veritas#11)
**Assignment:** koad/sibyl#14

---

## Summary

- The field of cryptographic trust in multi-agent AI systems is consolidating fast — MIT, Google DeepMind, NIST, and W3C all produced foundational work in 2025–2026. koad:io's GPG trust bond approach is well-positioned within this emerging consensus.
- GPG clearsign is the **correct primitive for identity attestation** ("koad trusts Sibyl") but is **insufficient alone for pipeline delegation** ("Juno delegates task X to Sibyl with constraint Y"). The field distinguishes these two layers; koad:io has Layer 1 right.
- GPG detached signatures are formally preferred over clearsign by GnuPG's own documentation — this is a low-lift improvement Faber should acknowledge in the post.
- NIST's AI Agent Standards Initiative (Feb 2026) explicitly addresses multi-agent trust boundaries and chain-of-custody logging — koad:io's approach is ahead of where NIST is targeting enterprise compliance.
- The strongest emerging alternative for pipeline delegation is **Biscuits** (Ed25519-chained + Datalog policies), not JWT or macaroons. A future evolution path from GPG bonds → Biscuit delegation tokens is architecturally sound.

---

## Findings

### 1. Public Literature on Cryptographic Trust in Multi-Agent Systems

**MIT Media Lab, Jan 2025 — "Authenticated Delegation and Authorized AI Agents"**
(arxiv:2501.09674; ICML 2025 poster)

The canonical academic framing. Authors (South, Marro, Hardjono et al.) argue that current AI agent deployments lack authenticated, auditable delegation — agents act with borrowed authority but leave no cryptographic trail. They propose extending OAuth 2.0 and OIDC with agent-specific credentials and metadata. Key finding: "by the third delegation hop, there is no cryptographic link to the initiating agent or user."

*Confidence: High — peer-reviewed, MIT affiliation, ICML acceptance.*

**arxiv:2511.02841 — "AI Agents with Decentralized Identifiers and Verifiable Credentials"** (Nov 2025)

Proposes equipping each agent with a W3C DID (ledger-anchored) and a set of Verifiable Credentials. Enables agents to prove identity at session start without a central authority. Directly relevant: "unlike X.509 certificates reliant on centralized authorities, DIDs are infrastructure-agnostic, portable, and support key rotation without breaking continuity." DIDs are the W3C standard path to what koad:io's GPG identity achieves without ledger dependency.

*Confidence: High — arxiv preprint, strong W3C alignment.*

**AIP: Agent Identity Protocol** (arxiv:2603.24775, 2026)

Most recent. Addresses MCP and A2A protocol gaps directly. Introduces Invocation-Bound Capability Tokens (IBCTs): compact JWT for single-hop delegation, Biscuit tokens with Datalog policies for multi-hop. This is the emerging standard for pipeline-style agent workflows.

*Confidence: High — recent, directly targets MCP/A2A which are now dominant protocols.*

**CSA, March 2026 — "Fixing AI Agent Delegation for Secure Chains"**

Practitioner framing: delegation chains are "high-leverage targets." 97% of non-human identities carry excess privileges. Attack vectors include Agent Session Smuggling (Nov 2025) and Cross-Agent Privilege Escalation (Sept 2025) — both exploitable when delegation lacks cryptographic constraints.

*Confidence: High — CSA primary source.*

---

### 2. GPG Clearsign vs. Other Signing Approaches for AI Governance

**GPG Clearsign**

- Battle-tested (30+ years), decentralized, offline-capable, human-readable
- Provides non-repudiation: the signer's key identity is verifiable without a central authority
- Aligns with self-sovereign model — no vendor, no kill switch
- **Known limitation:** GnuPG's own documentation deprecated clearsign in favor of **detached signatures** ("clearsigned documents are deprecated because detached signatures provide a more solid framework" — gnupg.org manual)
- **Structural gap:** GPG signs a document but does not encode *what the signer permits downstream*. No native capability attenuation. Each hop in a delegation chain requires a new manual signature.

**JWT**

- Cannot be restricted by the holder without contacting a central issuer
- Fails in offline/sovereign context
- Appropriate for stateless API auth, not agent trust bonds

**Macaroons**

- HMAC-based; every verifier can potentially forge tokens (shared secret)
- Capability attenuation built in — holder can add constraints that reduce but never expand authority
- Google DeepMind's Delegation Capability Tokens are macaroon-based
- *Not appropriate for koad:io's root-authority bonds* — shared-secret model contradicts non-repudiation requirement

**Biscuits**

- Public-key version of macaroons (Ed25519 chained signatures)
- Datalog policy language — expresses conditional delegation, RBAC, hierarchies
- Verifier does not need root secret
- "Biscuit is a public key version of macaroons" — Clever Cloud
- Best fit for pipeline delegation (Juno → Sibyl with scoped constraints)
- **Not yet in production for agent-to-agent use at scale** — emerging

**GPG for AI Governance (practitioner literature)**

From attested intelligence and alphacorp practitioner sources: borrowing git's signed-commit model for AI rule approval "has potential benefits: battle-tested cryptography, decentralization, offline capability." Open question flagged in the literature: "what happens when private keys are compromised, how to make this accessible to non-technical users." These are known open questions, not blockers for a closed team like koad:io.

*Confidence: High on GPG strengths/limitations. Medium on Biscuits as the emerging standard — strong signal but limited production deployments confirmed.*

---

### 3. Academic / Practitioner Precedents for Signed Authorization Delegation in AI

| Source | Approach | Status |
|--------|----------|--------|
| MIT (arxiv:2501.09674, Jan 2025) | OAuth 2.0 + OIDC extensions for agents | ICML 2025, peer-reviewed |
| Google DeepMind (2025) | Delegation Capability Tokens (macaroon-based) | Published research, not deployed standard |
| arxiv:2509.13597 (Sept 2025) | "Agentic JWT" — delegation protocol for autonomous agents | Preprint |
| arxiv:2603.24775 (2026) | AIP: IBCTs over MCP/A2A | Preprint, high relevance |
| W3C DID/VC (arxiv:2511.02841) | Decentralized identity + verifiable credentials per agent | Preprint, W3C standards alignment |

No production-deployed standard exists yet. GPG-based approaches represent the most mature deployed cryptographic primitive in this space, even if not yet mainstream in AI governance specifically.

*Confidence: High — the field has no dominant standard; koad:io's approach is defensibly ahead of the curve.*

---

### 4. NIST AI Agent Security and Trust Relationships

**NIST AI Agent Standards Initiative — announced Feb 17, 2026** (nist.gov/caisi)

Three pillars: industry-led standards (ISO/IEC JTC 1), open-source protocol development (NSF co-investment), fundamental security research. The NCCoE published a concept paper (Feb 2026) adapting SP 800-53 controls for AI agents, specifically addressing:
- Least-privilege tool access
- Agent action containment
- **Multi-agent trust boundaries**
- **Chain-of-custody logging for autonomous operations**

NIST red-team exercises (Jan 2025): 81% attack success rate against AI agents vs 11% against baseline defenses — emphasis on trust boundary weaknesses.

**NIST IR 8596 (iprd)** — Cybersecurity Framework Profile for AI Agents. In initial public review draft. Not yet finalized.

**AI Agent Interoperability Profile** — planned Q4 2026. Will formalize trust relationship standards. koad:io should watch this for compliance alignment.

*Confidence: High — direct NIST primary sources. AI Agent Interoperability Profile timeline is NIST's own stated target, subject to slip.*

---

## Confidence Summary

| Claim | Confidence |
|-------|-----------|
| GPG clearsign deprecated in favor of detached signatures | High — GnuPG official docs |
| MIT/ICML paper establishes academic consensus on authenticated delegation | High — peer-reviewed |
| Biscuits are the strongest emerging primitive for pipeline delegation | Medium — strong signal, limited production |
| NIST treating multi-agent trust boundaries as a priority | High — primary source |
| No deployed standard exists yet; GPG is defensibly appropriate | High |
| DID/VC path is the W3C-aligned long-term trajectory | High — W3C standards alignment |

---

## Sources

- [Authenticated Delegation and Authorized AI Agents — MIT Media Lab](https://www.media.mit.edu/publications/authenticated-delegation-and-authorized-ai-agents/) (arxiv:2501.09674)
- [ICML 2025 Poster: AI Agents Need Authenticated Delegation](https://icml.cc/virtual/2025/poster/40172)
- [AIP: Agent Identity Protocol for Verifiable Delegation Across MCP and A2A](https://arxiv.org/abs/2603.24775) (arxiv:2603.24775)
- [AI Agents with Decentralized Identifiers and Verifiable Credentials](https://arxiv.org/abs/2511.02841) (arxiv:2511.02841)
- [Agentic JWT: A Secure Delegation Protocol for Autonomous AI Agents](https://arxiv.org/html/2509.13597v1) (arxiv:2509.13597)
- [CSA: Fixing AI Agent Delegation for Secure Chains](https://cloudsecurityalliance.org/blog/2026/03/25/control-the-chain-secure-the-system-fixing-ai-agent-delegation)
- [CSA: AI Security When Your Agent Crosses Multiple Independent Systems](https://cloudsecurityalliance.org/blog/2026/03/11/ai-security-when-your-agent-crosses-multiple-independent-systems-who-vouches-for-it)
- [NIST AI Agent Standards Initiative announcement](https://www.nist.gov/news-events/news/2026/02/announcing-ai-agent-standards-initiative-interoperable-and-secure)
- [NIST AI Agent Standards Initiative landing page](https://www.nist.gov/caisi/ai-agent-standards-initiative)
- [NIST IR 8596 iprd — Cybersecurity Framework Profile for AI](https://nvlpubs.nist.gov/nistpubs/ir/2025/NIST.IR.8596.iprd.pdf)
- [Architecting Trust: NIST-Based Security Governance Framework for AI Agents — Microsoft](https://techcommunity.microsoft.com/blog/microsoftdefendercloudblog/architecting-trust-a-nist-based-security-governance-framework-for-ai-agents/4490556)
- [GnuPG Manual: Making and Verifying Signatures](https://www.gnupg.org/gph/en/manual/x135.html)
- [Biscuit: public key capability tokens — Clever Cloud](https://www.clever.cloud/blog/engineering/2021/04/12/introduction-to-biscuit/)
- [Google DeepMind validates macaroon-based agent delegation](https://earezki.com/ai-news/2026-03-11-what-google-deepmind-gets-right-about-agent-delegation-and-what-satgate-already-built/)
- [The Agent Authorization Design Space — The Synthesis](https://thesynthesis.ai/journal/the-agent-authorization-design-space)
- [Who Signed This? Provenance for AI Agents — Alexander Zanfir / Medium](https://medium.com/@alexzanfir/who-signed-this-provenance-for-ai-agents-78208f9574f1)
- [AI Trust Standards Evolve: PKI for AI Agents — HID Global](https://blog.hidglobal.com/trust-standards-evolve-ai-agents-next-chapter-pki)
- [Cryptographic Identity Systems for Auditing Autonomous AI Agents](https://earezki.com/ai-news/2026-03-28-cryptographic-identity-systems-for-auditing-autonomous-ai-agents/)
- [Agentic AI Governance — Attested Intelligence](https://attestedintelligence.com/agentic-ai-governance)

---

## Recommendation

**For Faber (the Apr 6 post on trust bonds):**

koad:io's GPG trust bond approach is defensible and well-positioned relative to the field — but Faber should frame it precisely to avoid overreach.

**What GPG bonds do correctly:**
- Layer 1 identity attestation: "koad trusts Sibyl to perform research" — this is an identity assertion, not a capability token. GPG is the right primitive for this.
- Non-repudiation without a central authority — directly implements the "not your keys, not your agent" principle
- Aligns with the practitioner-cited benefits (decentralized, offline, battle-tested)

**What Faber should acknowledge:**
1. GnuPG recommends detached signatures over clearsign — trivial to migrate, worth noting as a known improvement
2. GPG bonds are Layer 1 (identity/trust). For pipeline task delegation with scoped constraints (Juno → Sibyl with specific limits), the field is moving toward Biscuits or AIP-style IBCTs — this is a future evolution, not a current gap for koad:io's architecture
3. NIST is formalizing multi-agent trust boundaries as a compliance concern — koad:io's approach anticipates this requirement

**One-sentence conclusion:**
GPG trust bonds are the right foundation for sovereign agent identity — they establish *who is trusted*, not just *who is authenticated* — and the field is only now arriving at the same conclusion through academic consensus and NIST standards work.
