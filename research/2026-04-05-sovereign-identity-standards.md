# Sovereign Identity & Decentralized Identifier Standards
## How koad:io's Identity Model Relates to the Existing Standards Landscape

**Filed:** 2026-04-05
**Analyst:** Sibyl
**For:** Vesta (spec reconciliation), Juno (strategic positioning)
**Related:** `2026-04-05-trust-bonds-technical-deep-dive.md`

---

## Executive Summary

- koad:io's identity model (`canon.koad.sh/entity.keys`, GPG-signed trust bonds, Ed25519/ECDSA/RSA keys in `id/`) is **structurally compatible with the W3C DID and VC standards**, but not currently compliant. The delta is small and optional.
- The `canon.koad.sh/juno.keys` pattern is a **functional analog of `did:web`** — same mechanics, different serialization. DID-compliance would be a thin JSON-LD wrapper over infrastructure that already exists.
- koad:io's Alice graduation certificates **are not Verifiable Credentials** as defined by the W3C spec. They could be, with approximately one sprint of work. Whether they should be is a strategic question, not a technical one.
- For human authentication (Insiders, GitHub Sponsors), **Sign-In With Ethereum (SIWE) is the wrong choice** for koad:io. GitHub OAuth with a thin sovereignty posture is the pragmatic path; for the long game, OpenID Connect Self-Issued (SIOP v2) is the correct standard.
- **The standards worth aligning with:** `did:web`, W3C VC Data Model, SIOP v2. These are genuine infrastructure.
- **The standards that are dead ends:** `did:ethr` and other ledger-anchored DIDs, KERI (Key Event Receipt Infrastructure) for this scale, and any specification requiring a blockchain for basic identity operations.

---

## 1. Decentralized Identifiers (DIDs) — W3C Spec and Adoption

### What DIDs Are

A DID is a globally unique identifier that resolves to a DID Document — a JSON-LD file containing the subject's public keys, authentication methods, and service endpoints. The core insight: the identifier is not tied to any centralized registry. The controller holds the private key and owns the identifier.

```
did:web:canon.koad.sh:juno
    ↓ resolves via HTTPS
https://canon.koad.sh/juno/did.json
    ↓ returns
{
  "@context": "https://www.w3.org/ns/did/v1",
  "id": "did:web:canon.koad.sh:juno",
  "verificationMethod": [{
    "id": "did:web:canon.koad.sh:juno#ed25519-key-1",
    "type": "Ed25519VerificationKey2020",
    "controller": "did:web:canon.koad.sh:juno",
    "publicKeyMultibase": "z..."
  }]
}
```

### Current Adoption Landscape

The DID ecosystem is fragmented across ~150 registered methods, but three dominate practical usage:

| Method | Mechanism | Suitable for koad:io? |
|--------|-----------|----------------------|
| `did:web` | HTTPS + path, no ledger | Yes — directly maps to canon.koad.sh |
| `did:key` | Self-contained, key IS the DID | Yes — for ephemeral/session identity |
| `did:ethr` | Ethereum ledger anchored | No — blockchain dependency, no benefit at this scale |
| `did:ion` | Bitcoin ledger (Microsoft) | No — same objection |
| `did:peer` | P2P, local scope only | Possibly — for entity-to-entity in closed team |

W3C DID Core v1.0 reached Recommendation status in July 2022. The spec is stable. `did:web` is the lowest-friction entry point for an entity that already has a domain.

### does canon.koad.sh/juno.keys map onto did:web?

**Yes, functionally. Not yet structurally.**

Current koad:io pattern:
```
canon.koad.sh/juno.keys  →  SSH/PGP armored public keys (plain text)
```

`did:web` pattern:
```
canon.koad.sh/juno/did.json  →  DID Document (JSON-LD, structured)
```

The underlying mechanics are identical: HTTPS resolution of a domain-hosted file, no ledger required, the domain operator controls the content. The difference is serialization format and one additional layer of indirection (DID Document vs. raw key file).

**What it would take to be did:web compatible:**

1. Create `did.json` files at `canon.koad.sh/<entity>/did.json` (one per entity)
2. Populate each with the existing public keys from `~/<entity>/id/` in the DID Document format
3. Register nothing — `did:web` resolution is pure HTTPS
4. Optionally: add a `#service` entry pointing to the entity's GitHub repo as the service endpoint

This is a low-effort, high-interoperability upgrade. It does not require changing how keys are generated, stored, or used internally. It adds a public-facing structured format that any DID-aware tool can consume.

**Confidence: High — did:web spec is minimal and directly maps.**

### did:key — for ephemeral and session identity

`did:key` encodes the public key directly into the identifier string. No document to host, no resolution required.

```
did:key:z6MkhaXgBZDvotDkL5257faiztiGiC2QtKLGpbnnEGta2doK
```

This is useful for:
- One-time session keys during entity spawning
- Verification of a single operation without establishing a persistent identity
- Cross-entity handshakes where the full DID document isn't needed

koad:io could use `did:key` as the identity format for signed code blocks and IBCT-style delegation tokens (see trust bonds deep dive). No infrastructure change required — it's a formatting convention over existing keys.

---

## 2. Verifiable Credentials (VCs) — Are koad:io Certificates VCs?

### What Verifiable Credentials Are

A Verifiable Credential is a JSON-LD document in which an **issuer** makes claims about a **subject**, signed with a cryptographic proof that any party can verify without contacting the issuer.

```json
{
  "@context": ["https://www.w3.org/2018/credentials/v1"],
  "type": ["VerifiableCredential", "AliceGraduationCredential"],
  "issuer": "did:web:canon.koad.sh:alice",
  "issuanceDate": "2026-04-05T00:00:00Z",
  "credentialSubject": {
    "id": "did:web:canon.koad.sh:koad",
    "level": 3,
    "achievement": "Alice Curriculum — Level 3 Complete",
    "completedAt": "2026-04-05"
  },
  "proof": {
    "type": "Ed25519Signature2020",
    "verificationMethod": "did:web:canon.koad.sh:alice#ed25519-key-1",
    "proofValue": "..."
  }
}
```

The W3C VC Data Model v2.0 reached Candidate Recommendation in January 2024. The ecosystem has matured: digital diplomas, government credentials (EU Digital Identity Wallet), and enterprise identity are all deploying VCs.

### Are Alice Graduation Certificates VCs?

**Not currently. They share the same intent but lack the required structure.**

What koad:io's Alice certificates likely contain (inferred from architecture):
- Signed assertion that a student completed a level
- Issuer is Alice (the entity)
- Signed with Alice's GPG key

What they're missing to be W3C VCs:
1. JSON-LD format with the VC context
2. `issuer` expressed as a DID (requires did:web for Alice)
3. `credentialSubject.id` expressed as a DID (requires the holder to have a DID)
4. `proof` block using a VC-compatible proof suite (Ed25519Signature2020 maps directly from existing Ed25519 keys)

**The work involved:** Primarily a format translation. Alice's existing Ed25519 key can sign VCs without modification. The main addition is the JSON-LD wrapper and DID identifiers for issuer and subject.

**Should koad:io make Alice certificates VC-compliant?**

This is a strategic question. Arguments for:

- **Portability:** A holder can present their Alice certificate to any VC-aware system without koad:io involvement. This directly supports the sovereignty principle — "your certificate, not locked in our system."
- **Ecosystem interoperability:** EU Digital Identity Wallet, OIDC4VC (OpenID for Verifiable Credentials) integrations, Learning Machine/Blockcerts-compatible wallets — all become available.
- **Legitimate curriculum credentialing:** As Chiron's curriculum matures, VC-format certificates become genuinely meaningful as portable educational credentials.

Arguments against (now):

- **No current demand.** Until Alice has paying students who need to present credentials elsewhere, VC compliance adds no user-facing value.
- **Dependency on did:web.** Certificates cannot be VC-compliant without Alice having a DID. This is a two-step dependency.
- **JSON-LD complexity.** The VC ecosystem has tooling (Veramo, SpruceID, DIF libraries), but it adds a dependency surface.

**Sibyl's recommendation:** Design for VC compatibility, implement on demand. Use DID-native identifiers for Alice and students in the data model now — the format migration is then trivial when the use case arrives. The wrong time is before Alice has her first student; the right time is at the first graduation.

---

## 3. OpenID Connect, SIWE, and Human Authentication

### The Insiders Section Problem

koad:io's Insiders section (MVP Zone) uses GitHub OAuth for human authentication. The question is whether there's a sovereign alternative worth considering.

### Sign-In With Ethereum (SIWE) — EIP-4361

SIWE allows a user to authenticate by signing a message with their Ethereum wallet. No central authority, the private key is the identity.

**Why koad:io should not use SIWE:**

1. **Wallet friction is a conversion killer.** Requiring MetaMask or a hardware wallet at signup eliminates the majority of potential Insiders. koad:io's audience is indie developers and sovereignty-minded professionals, not crypto natives.
2. **The sovereignty argument doesn't hold uniquely.** SIWE trades dependence on GitHub for dependence on Ethereum infrastructure and wallet tooling. This is a lateral move, not an upgrade.
3. **No integration ecosystem for GitHub-adjacent communities.** The Insiders section lives adjacent to GitHub Sponsors; SIWE has zero overlap with that context.
4. **Blockchain dependency contradicts koad:io's stated philosophy.** koad:io explicitly avoids ledger-anchored identity (same reason `did:ethr` is a dead end). SIWE is fundamentally ledger-anchored.

### GitHub OAuth — The Pragmatic Choice

GitHub OAuth is the correct answer for the Insiders section today, for three reasons:

1. **The Insiders audience is already on GitHub.** Zero new account creation friction.
2. **GitHub Sponsors integration is native.** Sponsor status can be verified programmatically in the same auth flow.
3. **GitHub IS the trust signal.** An Insiders member's GitHub profile — contributions, repos, tenure — is more identity signal than any cryptographic proof would provide.

The sovereignty concern with GitHub OAuth is real but manageable: koad:io does not hold the authentication source. The mitigation is simple: store minimal data from the OAuth flow, do not create a second identity layer that depends on GitHub for anything beyond initial auth.

### OpenID Connect Self-Issued OP v2 (SIOP v2) — The Long Game

SIOP v2 (part of the OpenID Connect for Verifiable Presentations suite) allows a user to authenticate using a DID as their identifier — no central OP required. The wallet IS the identity provider.

This is the correct long-term pattern for koad:io's Insiders authentication if/when:

1. koad:io issues VCs (e.g., Alice graduation certificates, Sponsor tier credentials)
2. The Insiders experience needs to verify those credentials at login
3. A meaningful segment of the audience holds DIDs (which is increasingly likely as EU DWI and platform DID support expands)

The spec is stable: SIOP v2 and OpenID for Verifiable Presentations (OID4VP) reached Final draft in 2023. Wallet support is growing (Sphereon, SpruceID, Microsoft Authenticator, Apple Wallet announcements in 2025).

**Implementation pattern when ready:**

```
User presents: did:web:canon.koad.sh:koad
                + Alice Level 3 VC (Verifiable Presentation)
koad:io verifies: DID resolves, VC signature valid, issuer = did:web:canon.koad.sh:alice
Result: authenticated + credentialed, zero third-party contact required
```

This is the native sovereignty path. It requires did:web for entities and users, and VC-format certificates — both recommended above as future investments.

---

## 4. What koad:io Should NOT Do

### Dead Ends

**`did:ethr`, `did:ion`, `did:btcr` — Ledger-anchored DIDs**

These require a blockchain to anchor and rotate keys. The pitch is "decentralized" but the reality is: you've traded dependence on a domain registrar for dependence on a blockchain network, a gas fee economy, and a specific wallet ecosystem. For a sovereignty-first system that explicitly avoids vendor lock-in, this is backward. The resolution infrastructure is more fragile than HTTPS, not less.

**KERI (Key Event Receipt Infrastructure)**

KERI (by Sam Smith) is an ambitious protocol for self-certifying identifiers with cryptographic key event logs. It is technically rigorous and blockchain-independent. It is also: pre-standard, opaque to most developers, lacking production tooling outside niche security research, and solving problems that are not koad:io's current problems. Watch the space in 3–5 years; don't adopt it now.

**X.509 / PKI Certificates for entity identity**

Certificate Authorities are the antithesis of koad:io's model. An X.509 cert requires a CA to vouch for you. That CA can revoke your identity. The cost is recurring. The infrastructure is centralized. koad:io's GPG-based approach is strictly superior for entity identity — it achieves the same non-repudiation without any CA dependency.

**Solid (Tim Berners-Lee's Linked Data project)**

Solid pods for identity and data ownership are philosophically aligned with koad:io but practically stranded: limited adoption, brittle tooling, steep learning curve, no clear community momentum in 2026. The Solid project has been in "almost there" status for five years. Not a dead end philosophically, but not a live infrastructure bet.

**Anything requiring DID Universal Resolver for basic operations**

The DIF Universal Resolver aggregates resolution across 100+ DID methods. If any koad:io identity operation requires hitting an external resolver service, the sovereignty argument dissolves. `did:web` avoids this entirely — it resolves directly via HTTPS to koad:io-controlled infrastructure.

### Genuine Infrastructure Worth Aligning With

| Standard | Why | When |
|----------|-----|------|
| `did:web` | Direct map to canon.koad.sh; thin JSON wrapper over existing keys | Next infrastructure sprint |
| W3C VC Data Model v2 | Portable Alice certificates; future Insiders credential verification | At first Alice graduation |
| SIOP v2 / OID4VP | Sovereign human auth when VC ecosystem matures | Post-Alice Phase 2 |
| `did:key` | Ephemeral/session identity for delegation tokens | Alongside Biscuit/IBCT adoption |
| Ed25519Signature2020 proof suite | Already using Ed25519; VC proof is the same key, different format | Part of did:web work |

---

## 5. Synthesis: Where koad:io Sits in the Standards Landscape

koad:io's identity model was designed from first principles for sovereignty, and it largely arrived at the same conclusions the W3C standards work has reached — independently and earlier. The main gap is not conceptual but formal: the infrastructure does DID-equivalent things without speaking the DID vocabulary.

This creates a specific opportunity: koad:io can claim **W3C DID compatibility as a feature** rather than an obligation. The framing is not "we had to adopt the standard" but "we designed for sovereignty and the standard caught up with us." The `canon.koad.sh` key distribution model, the trust bond structure (issuer + subject + scope + signature), and the selective disclosure model all have direct analogs in the DID/VC ecosystem.

**The three-step path:**

1. **Immediate (did:web):** Add `did.json` files to `canon.koad.sh` for each entity. Zero change to key infrastructure. Unlocks DID interoperability.

2. **Near-term (VC certificates):** When Alice issues her first graduation certificate, format it as a W3C VC. The signing key doesn't change; the wrapper does.

3. **Long-term (SIOP v2):** When the Insiders section needs credential-verified access, SIOP v2 over the did:web infrastructure provides sovereign authentication with no third-party dependency.

**What not to change:** The internal identity model, GPG trust bonds, the Keybase sigchain layer, or the `entity.keys` format for SSH/GPG distribution. These are working. DID compatibility is an outward-facing layer, not a replacement.

---

## Confidence Summary

| Claim | Confidence |
|-------|-----------|
| canon.koad.sh maps functionally to did:web | High — spec is minimal, HTTPS resolution is identical |
| did:web compliance requires ~1 sprint of work | High — JSON-LD wrapper, no key changes |
| Alice certificates are not currently W3C VCs | High — format mismatch is clear |
| VC compliance requires did:web as prerequisite | High — issuer must be a DID |
| SIWE is wrong for koad:io's audience | High — wallet friction + blockchain dependency |
| GitHub OAuth is correct for Insiders now | High — audience alignment, Sponsors integration |
| SIOP v2 is the correct long-term auth pattern | Medium-High — spec stable, wallet support growing but uneven |
| Ledger-anchored DIDs are dead ends for koad:io | High — contradicts core sovereignty principle |
| KERI is not ready for production adoption | High — pre-standard, tooling immature |

---

## Sources

- [W3C DID Core v1.0 Recommendation](https://www.w3.org/TR/did-core/) (July 2022)
- [W3C DID Method: did:web](https://w3c-ccg.github.io/did-method-web/)
- [W3C Verifiable Credentials Data Model v2.0](https://www.w3.org/TR/vc-data-model-2.0/)
- [OpenID Connect Self-Issued OP v2 (SIOP v2)](https://openid.net/specs/openid-connect-self-issued-v2-1_0.html)
- [OpenID for Verifiable Presentations (OID4VP)](https://openid.net/specs/openid-4-verifiable-presentations-1_0.html)
- [EIP-4361: Sign-In With Ethereum](https://eips.ethereum.org/EIPS/eip-4361)
- [DIF Universal Resolver](https://dev.uniresolver.io/)
- [Veramo — W3C VC / DID framework (TypeScript)](https://veramo.io/)
- [SpruceID — DIF-aligned DID/VC tooling](https://spruceid.com/)
- [EU Digital Identity Wallet Architecture Reference Framework](https://digital-strategy.ec.europa.eu/en/policies/eudi-wallet-implementation)
- [AI Agents with Decentralized Identifiers and Verifiable Credentials](https://arxiv.org/abs/2511.02841) (arxiv:2511.02841)
- [KERI — Key Event Receipt Infrastructure (Sam Smith)](https://keri.one/)
- [Solid Project — Tim Berners-Lee](https://solidproject.org/)
- [Ed25519Signature2020 — W3C VC proof suite](https://w3c-ccg.github.io/di-eddsa-2020/)

---

*Sibyl — Research Director, koad:io ecosystem*
*Filed: 2026-04-05 | Assignment: koad/sibyl research brief*
