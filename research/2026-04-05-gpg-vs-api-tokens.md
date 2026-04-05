# GPG vs. API Tokens: The Sovereignty Tradeoff
## Research Brief for Day 26 Content

**Filed:** 2026-04-05
**Analyst:** Sibyl
**For:** Faber — Day 26 post
**Related prior research:**
- `2026-04-05-trust-bonds-technical-deep-dive.md` (Layer 1/Layer 2 distinction, Biscuit as evolution)
- `2026-04-05-sovereign-identity-standards.md` (DID/VC landscape, W3C alignment)
**Day 24 coverage:** Trust bonds deep-dive, Layer 1 vs Layer 2 distinction, Biscuit tokens introduced as evolution path.
**Day 26 angle:** Sovereignty argument for GPG at the identity layer — written for the developer who has only ever used JWTs, OAuth tokens, and API keys.

---

## Summary

- **The scale of token leakage is not theoretical.** GitHub alone saw 39 million secrets leaked in 2024 and 28.65 million in 2025 (a 34% YoY increase). The problem is structural, not a matter of developer carelessness — the token model creates a surface area that grows with every integration.
- **JWT's "stateless" advantage is inseparable from its revocation liability.** A JWT is valid until it expires. There is no native revocation primitive. Every workaround (blacklists, token versioning, short expiry) reintroduces server state — eliminating the claimed benefit. The stateless property and the sovereignty problem are the same property.
- **OAuth and OIDC are sophisticated but structurally vendor-dependent.** The entire trust chain rests on the issuer. If Auth0, Okta, or any Authorization Server is compromised, unavailable, or simply shuts down, your identity chain breaks. This is not a theoretical risk — the 2023 Okta breach propagated from their support system to downstream customers including Cloudflare.
- **GPG's operational overhead is real and should not be minimized.** Key loss without a revocation certificate was catastrophic in older versions (pre-2015). Modern GPG auto-generates revocation certificates at key creation. The actual overhead is: initial setup (1–2 hours), occasional rotation (annually or on compromise), and distribution of public keys. Hardware tokens (YubiKey) reduce the daily friction significantly.
- **Biscuit and UCAN are the honest evolution path.** Both offer GPG's core properties — offline-verifiable, decentralized, non-repudiation — with JWT-like ergonomics. Both are actively maintained (Eclipse Foundation for Biscuit, UCAN Working Group with updates through early 2026). Neither is production-mainstream yet. Biscuit has the better cryptographic story; UCAN has the broader ecosystem.
- **The honest koad:io framing:** GPG was the right pragmatic choice in 2025 — battle-tested, decentralized, no dependencies. It is not the optimal long-term answer. The ideal 2026 stack would use Ed25519-signed identity roots (what koad:io already does), Biscuit tokens for delegation chains, and `did:web` for portable public resolution. koad:io is two layers away from the optimal stack, not in the wrong direction.

---

## 1. The Operational Reality of API Tokens

### Scale of the Problem

**GitGuardian State of Secrets Sprawl (2025 edition, published March 2026):**

- 28.65 million new hardcoded secrets were added to public GitHub repositories in 2025 — a 34% year-over-year increase, the largest single-year jump recorded.
- GitHub's own 2024 data: 39 million secrets leaked that year.
- 32.2% of **internal** (private) repositories contain at least one hardcoded secret, versus 5.6% of public repos. The private repo number is the alarming one — it shows the problem is organizational, not just accidental public exposure.
- Non-human identities (NHIs) — API keys, service account tokens, machine credentials — now outnumber human users in most corporate environments and carry mostly long-lived, non-expiring credentials.
- AI service credential leaks increased 81% year-over-year in 2025. Claude Code-assisted commits leaked secrets at ~3.2% — roughly 2x the GitHub-wide baseline. AI coding tools accelerate secret introduction.

*Confidence: High — GitGuardian primary source, annual report, March 2026.*

### Real Documented Incidents

**Shai-Hulud worm (late 2024):**
A self-replicating worm that scanned compromised environments for GitHub Personal Access Tokens and cloud API keys, then used stolen npm tokens to identify and infect packages maintained by the same developers. Classic lateral movement enabled by token sprawl — one stolen token enables discovery of the next.

*Confidence: High — documented by security researchers, widely reported.*

**Wiz research on AI companies (2025):**
Wiz examined 50 AI companies. 65% had leaked verified secrets on GitHub. A single leaked Hugging Face token belonging to one of those companies could have exposed access to approximately 1,000 private models — proprietary IP extraction, not just service access.

*Confidence: High — Wiz primary research.*

### The Token Count Problem

The typical active developer in 2025–2026 manages:
- GitHub Personal Access Tokens (fine-grained and classic)
- Cloud provider credentials (AWS access keys, GCP service account keys, Azure credentials)
- Third-party API keys for each integrated service (Stripe, Twilio, SendGrid, etc.)
- CI/CD pipeline secrets (one per environment, per service)
- Package registry tokens (npm, PyPI, etc.)
- AI service credentials (OpenAI, Anthropic, Hugging Face)

OWASP recommends rotating high-privilege keys weekly or daily, and low-privilege keys monthly. For a moderately integrated developer, this means managing 20–50+ distinct secrets, each with its own rotation cadence, storage location, and revocation procedure. The cognitive overhead alone drives the behavior that causes leaks — people hardcode because the alternative is managing a secret management system that is itself complex.

*Confidence: Medium-High — synthesized from OWASP, GitGuardian, Wiz; specific per-developer counts are estimates, not directly surveyed.*

---

## 2. The JWT/OAuth Trust Model — What It Actually Asserts

### What a JWT Asserts

A JSON Web Token is a signed (or encrypted) JSON payload carrying claims: `iss` (issuer), `sub` (subject), `aud` (audience), `exp` (expiry), and application-defined claims. The signature proves the payload was not tampered with after issuance. That is all.

Critically: **a JWT asserts that the issuer believed these claims at the time of signing.** It does not assert that the claims are still true. It cannot be revoked without external infrastructure.

The trust chain is:
```
User authenticates → Authorization Server issues JWT → Relying Party verifies signature against issuer's public key → access granted
```

The Relying Party trusts the JWT only because it trusts the Authorization Server's public key. That trust is established out-of-band, usually via OIDC discovery or manual configuration.

*Confidence: High — this is the RFC 7519 specification.*

### The Central Issuer Dependency

The issuer is the load-bearing element. Remove the issuer and the trust chain collapses:
- If the Authorization Server is down, no new tokens can be issued. (Existing valid tokens continue to work until expiry — which may be minutes or hours depending on configuration.)
- If the Authorization Server's signing key is compromised, all tokens it has ever issued are suspect. Rotation requires reissuing tokens for all users and services.
- If the Authorization Server vendor shuts down, migrations require recreating the entire trust chain.

IETF researchers disclosed in January 2025 a vulnerability class affecting multiple OpenID and OAuth implementations: ambiguity in the audience values of JWT client authentication assertions allowed token misuse across issuers. The fix (requiring the issuer identifier URL as the sole audience value) is a clarification, not a redesign — the central-issuer dependency is structural.

**The vendor lock-in vector is not just contractual — it's cryptographic.** Your tokens encode the issuer's identity. Migrating away requires every token to be invalidated and reissued, coordinated across every service that accepted the old tokens.

*Confidence: High — IETF published, well-documented.*

### The Revocation Problem

The stateless JWT advantage (no server roundtrip for verification) is the same property that makes revocation impossible. To revoke a JWT before expiry, you need one of:

1. **Blacklist/denylist**: Check every token against a central store on every request. Reintroduces the server dependency that stateless JWTs were meant to avoid.
2. **Short expiry + refresh**: Access tokens expire in 5–15 minutes, refresh tokens in hours/days. Compromise is bounded but not eliminated; the refresh token is now the high-value target.
3. **Token versioning**: Store a version number per user, embed version in JWT. Increment to invalidate all tokens. Requires server state and adds latency.

None of these are revocation in the sense that GPG revocation certificates are revocation. GPG revocation is: publish a signed certificate to any keyserver and the key is globally invalid, verifiable by anyone, without contacting the original issuer.

*Confidence: High — well-documented JWT limitation; multiple implementation references.*

---

## 3. The Okta Breach: Vendor Dependency as Attack Surface

### What Happened (October–November 2023)

An attacker gained access to Okta's customer support system using credentials stolen from an employee's compromised personal Google account. The attacker accessed support case files — including HAR files containing live session tokens — and used those tokens to hijack the Okta sessions of five customers.

Okta's initial disclosure (October 2023) estimated fewer than 1% of customers affected. The November follow-up disclosed that **all Okta customers were affected** — contact information for all certified users and CIC customer contacts was accessed.

The downstream impact extended to Cloudflare: attackers used an authentication token stolen from Okta's support system to access Cloudflare's own Okta instance with administrative privileges.

**The sovereignty lesson:** Cloudflare did nothing wrong. Their tokens were valid. Their issuer was compromised. The trust chain flows upward to a vendor, and the vendor was the failure point.

*Confidence: High — Okta published post-incident analysis; Cloudflare disclosed independently; TechCrunch and The Hacker News documented the scope expansion.*

### The MFA Outage Pattern (2025)

A separate 2025 Okta incident — a synchronization failure between redundant authentication nodes — caused an MFA outage affecting an unspecified number of customers. The failure was not a breach, but the effect was the same: customers could not authenticate. Services relying on Okta for authentication could not verify users.

Within hours of the outage, phishing domains mimicking Okta login pages began circulating. Operational outages at an identity provider create secondary attack windows.

*Confidence: High — documented in security publications; Okta CEO statement on record.*

---

## 4. GPG's Operational Overhead — Honest Accounting

### What GPG Actually Requires

**Initial setup (one-time, 1–3 hours for a careful setup):**
- Generate a primary key (Ed25519 or RSA 4096)
- Generate subkeys for signing, encryption, authentication
- Export and store the primary key offline (USB drive, paper backup)
- Generate and store a revocation certificate
- Distribute the public key (keyserver, domain, GitHub)

**Ongoing maintenance:**
- Subkey rotation: recommended annually for active keys; optional for static identity keys
- Key signing: only relevant for web-of-trust participation, not required for koad:io's use case
- Public key distribution updates: required if rotating; a push to one keyserver propagates

**Hardware token path (YubiKey):**
- Subkeys stored on the YubiKey; private key material never leaves hardware
- Daily workflow: GPG operations require physical presence of the token
- Touch-to-sign policy: optional but available; forces physical consent per operation
- Backup strategy: a second YubiKey with the same subkeys, stored offline

*Confidence: High — GnuPG documentation, Arch Linux wiki, drduh YubiKey guide.*

### Real Failure Modes

**Lost key without revocation certificate (historical):**
Pre-2015 GPG behavior: no automatic revocation certificate. If you lost your key passphrase and your secret key, you could not revoke the public key — it would remain on keyservers indefinitely, appearing valid. Modern GPG (2.1+) auto-generates a revocation certificate at key creation, stored in `~/.gnupg/openpgp-revocs.d/`. This failure mode is largely resolved for new keys.

**Revocation certificate exposed:**
Anyone holding your revocation certificate can revoke your key. This action is irreversible. The cert must be protected as carefully as the private key.

**Key distribution staleness:**
After rotating or revoking, you must push the update to every keyserver you used and inform anyone who has your old key. For a small team (koad:io use case), this is a brief exercise. For large PKI deployments, propagation is non-trivial.

**Web of trust complexity:**
GPG's web-of-trust model — the trust-through-signature network — is largely irrelevant for koad:io's use case. koad:io's model is explicit bilateral bonds, not probabilistic web-of-trust inference. The complexity developers associate with GPG often conflates these two use cases.

**The real cost comparison:**
GPG initial setup is a one-time 2-3 hour investment. API token management is an ongoing weekly overhead across dozens of credentials, each with different rotation schedules, storage requirements, and revocation procedures. The overhead comparison depends entirely on the time horizon. At one year, GPG is likely lower overhead for an individual developer than managing 30+ API tokens responsibly.

*Confidence: Medium-High — synthesized from GnuPG documentation, Kali Linux 2025 key incident (lost signing key), community guides. Overhead comparison is analytical, not directly surveyed.*

---

## 5. Biscuit and UCAN — The Capability Token Evolution

### Biscuit (biscuitsec.org / Eclipse Foundation)

**What it is:** An authorization token with decentralized verification, offline attenuation, and logic-language policy enforcement (Datalog). Signed with Ed25519 public key cryptography.

**Core properties relevant to the sovereignty comparison:**
- **Decentralized verification:** Any party holding the issuer's public key can verify the token without contacting the issuer. Same as GPG; unlike JWT (which requires an issuer endpoint for key discovery).
- **Offline attenuation:** A token holder can generate a *more restricted* token (add constraints, reduce scope) without issuer involvement. This is not possible with JWT — delegation requires a new issuance request.
- **Capability chains:** Biscuit encodes what actions are permitted in the token itself, using Datalog logic rules. Policy travels with the token.
- **Revocation via identifiers:** Every Biscuit token carries a unique revocation identifier. Revocation requires publishing the identifier to a revocation list that verifiers consult.

**Current state (2025–2026):**
The project was transferred to the Eclipse Foundation, giving it long-term governance stability. Implementations exist in Rust, Go, Java, TypeScript, and Python. Active development is ongoing. The project is production-stable but not mainstream — it is more common in privacy-sensitive infrastructure and decentralized systems than in typical SaaS applications.

*Confidence: High — Eclipse Foundation governance public; biscuitsec.org documentation; GitHub activity.*

### UCAN (User Controlled Authorization Network, ucan.xyz)

**What it is:** A capability-based authorization token built on JWT encoding but with key-controlled delegation. The UCAN spec uses did:key identifiers — the key IS the identity.

**Core properties:**
- **No central server required:** "No all-powerful authorization server or server of any kind is required for UCANs." The user's key pair is the root of authority.
- **Self-contained:** Tokens carry all information needed to verify them, including the delegation chain. Offline verification is native.
- **Flexible deployment:** Works online, offline, fully P2P, federated, or centralized. The spec makes no assumption about network topology.
- **JWT encoding:** UCAN uses JWT format under the hood, making it interoperable with existing JWT tooling.

**Current state (2025–2026):**
Active development through early 2026. Delegation spec updated December 2025; container format updated January 2026. Go, TypeScript, and Rust implementations available. Fission (the primary UCAN backer) has used it in production for their WNFS distributed filesystem. Adoption is wider than Biscuit in the decentralized web / Fediverse community, narrower in enterprise contexts.

*Confidence: High — UCAN Working Group GitHub public; ucan.xyz documentation.*

### Biscuit vs. UCAN for koad:io Evolution

| Property | Biscuit | UCAN |
|----------|---------|------|
| Signing | Ed25519 (native) | Ed25519 via did:key |
| Policy language | Datalog (expressive, auditable) | Caveats (simpler, less expressive) |
| Offline verification | Yes | Yes |
| Offline attenuation | Yes | Yes |
| Revocation | Revocation list (optional, checked by verifiers) | Revocation via UCAN revocation tokens |
| Ecosystem | Eclipse Foundation, smaller community | UCAN WG, Fission, web3-adjacent |
| JWT compatibility | No (different format) | Yes (JWT encoding) |
| GPG key integration | Not native | Not native (did:key is the identity) |

**Recommendation for Faber:** Biscuit is the better technical story for koad:io's architecture. Its Datalog policy language maps naturally onto trust bond scope assertions. Its Eclipse governance means it won't evaporate. UCAN's JWT compatibility is pragmatic but the web3 association may be a positioning distraction.

*Confidence: Medium-High — comparative analysis based on public specs and documentation; neither system is widely enough adopted to have extensive production post-mortems.*

---

## 6. The Honest Framing for koad:io

### Why GPG Was the Right Choice Then

GPG was chosen for koad:io's trust bonds for defensible reasons:
1. It existed and worked in 2025. No integration risk.
2. Every developer who manages SSH keys already understands the model conceptually.
3. 30+ years of battle-testing. No known cryptographic weaknesses in the signing primitives.
4. No network dependencies. Verification works offline, forever, without calling any endpoint.
5. The GnuPG toolchain is universally available.

These are still good reasons. GPG is not wrong — it is appropriately scoped to what koad:io needs at Layer 1 (identity attestation). The prior Day 24 coverage correctly identified that GPG handles "koad trusts Juno" well; it handles "Juno delegates task X to Sibyl with constraint Y under time limit Z" poorly. That is a Layer 2 problem and GPG was never meant to solve it.

*Confidence: High — architectural analysis consistent with Day 24 brief and trust-bonds-technical-deep-dive.md.*

### What the Ideal 2026 Stack Looks Like (Designed From Scratch)

If the koad:io identity architecture were being designed in early 2026 with the current landscape:

**Layer 0: Cryptographic primitives**
Ed25519 key pairs per entity — same as current. Short keys, fast operations, broadly supported. This is already correct.

**Layer 1: Portable identity**
`did:web` DID Documents at `canon.koad.sh/<entity>/did.json`. This is a thin JSON-LD wrapper over the infrastructure that already exists. Delta from current: one sprint of work. Benefit: W3C standard resolution, compatible with any DID verifier.

**Layer 2: Identity attestation (trust bonds)**
GPG clearsign → detached signatures using the Ed25519 keys. The content (who, what scope, when, signed) is identical. The change is in the signature encoding. GnuPG's own docs recommend detached signatures; this is the technically correct improvement. Still GPG; still offline-verifiable; still no dependencies.

**Layer 3: Delegation and pipeline authorization**
Biscuit tokens for multi-hop delegation chains. "Juno delegates research to Sibyl with capability: read ~/.juno, write ~/.sibyl/research, no GitHub push." This capability is encoded in the token, signed by Juno's key, attenuatable by Sibyl when delegating subtasks. No new issuance request required. The Biscuit token IS the authorization document.

**Layer 4: Human-facing authentication**
SIOP v2 (Self-Issued OpenID Provider) for human-to-agent authentication. Passkeys (WebAuthn, Ed25519) for Insiders and GitHub Sponsors. No centralized identity provider required for core operations. GitHub OAuth as a pragmatic fallback where GitHub is already the trust anchor.

**What this stack gives you that the current stack does not:**
- W3C compatibility for DID/VC (Layer 1)
- Multi-hop delegation with auditable capability chains (Layer 3)
- Offline-verifiable, non-repudiable, decentralized at every layer

**What it does not change:**
- Files on disk as the source of truth
- Entity sovereignty (private key = identity control)
- No vendor as a required dependency for core operations
- koad as the root of trust for the entity network

**The honest summary for Faber to deliver to the audience:**
"We chose GPG because it was the best available tool we understood in 2025. The choice was sound. The field is now producing better tools for the Layer 2 and Layer 3 problems GPG was never designed for. Our Layer 1 is correct and will evolve in-place. The sovereignty principle — your keys, your identity, no required vendor — is consistent across the current stack and the ideal stack. The specific tools change. The principle does not."

*Confidence: High — this is architectural analysis, not empirical claim; architectural recommendations are well-supported by the prior research corpus.*

---

## Recommended Post Structure for Faber

**Working title:** "Why We Use GPG When You've Never Had To"

**Audience:** Developer who has shipped production OAuth, knows what a JWT is, considers GPG unnecessary complexity.

**Arc:**
1. Open with the leakage statistics — not to shame, to frame the structural problem. 39 million tokens in 2024. Not carelessness. The model.
2. Explain what a JWT actually asserts and doesn't. Stateless = no revocation. The issuer is the load-bearing wall.
3. The Okta case. Nothing the downstream developers did was wrong. The trust chain reached up to a vendor and the vendor was the failure point. This is not a Okta-specific problem; it is an OAuth/OIDC structural property.
4. GPG's honest overhead accounting. Initial setup: a morning. Ongoing: less than managing 30 API tokens responsibly. The comparison is almost never framed correctly.
5. What we're moving toward: Biscuit for delegation, did:web for portable identity. We're not defending GPG as the eternal answer. We're defending the principle the specific tool embodies.
6. Close on the sovereignty frame: the question is not "which tool is easiest." The question is "who holds the root of authority?" In OAuth, the vendor does. In GPG, you do. That choice is permanent in ways that have nothing to do with UX complexity.

**Tone:** Technically honest. Acknowledge GPG's friction without apologizing for the choice. The audience respects directness more than defensiveness.

---

## Source Notes

- GitGuardian State of Secrets Sprawl 2026 (covering 2025 data): https://blog.gitguardian.com/the-state-of-secrets-sprawl-2026/
- GitHub 2024 secrets report: https://github.blog/security/application-security/next-evolution-github-advanced-security/
- Snyk 2025 secrets analysis: https://snyk.io/articles/state-of-secrets/
- Okta October 2023 breach post-mortem: https://sec.okta.com/articles/2023/11/unauthorized-access-oktas-support-case-management-system-root-cause/
- Okta breach broader impact (all customers): https://techcrunch.com/2023/11/29/okta-admits-hackers-accessed-data-on-all-customers-during-recent-breach/
- Eclipse Biscuit project: https://www.biscuitsec.org/ and https://doc.biscuitsec.org/getting-started/introduction
- UCAN specification: https://ucan.xyz/specification/
- JWT revocation problem analysis: https://oneuptime.com/blog/post/2026-02-02-jwt-revocation/view
- GnuPG key management documentation: https://www.gnupg.org/gph/en/manual/c235.html
- drduh YubiKey guide: https://github.com/drduh/YubiKey-Guide
- IETF OAuth JWT vulnerability (Jan 2025): https://datatracker.ietf.org/doc/draft-ietf-oauth-rfc7523bis/
- Penligent JWT bypass and trust failures: https://www.penligent.ai/hackinglabs/pac4j-security-jwt-bypass-saml-complexity-and-the-trust-failures-that-matter/
