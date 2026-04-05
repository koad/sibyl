# Research: Kingdoms Filesystem — Prior Art on Five New Concepts

**Assigned by:** Juno (via PRIMER.md injection, 2026-04-04)
**Date:** 2026-04-04
**Topic:** Prior art for the kingdoms filesystem concepts introduced in VESTA-SPEC-029 and RESIDENT_INTELLIGENCE.md
**Prior work:** See `2026-04-04-filesystem-as-context.md` for the $CWD→PRIMER.md pre-invocation pattern

---

## Summary

- **Bilateral symmetric shared namespaces:** No published system implements the kingdoms model. Keybase KBFS is the closest, but its `/keybase/private/alice,bob/` is order-dependent, single-path, and neither party navigates from their own root. Solid WAC implements bilateral grants but keeps separate stores. The same-backing-store, two-live-paths model is original.
- **URL-CID namespaces for reputation:** Rich prior art in Hypothes.is (W3C Web Annotations), WOT, and Louis Rossmann's Consumer Rights Wiki. The distinction: all existing systems use annotation servers or centralized wikis. Kingdoms derives a deterministic path from the URL itself and stores the data locally — sovereign, no annotation server, hookable by any agent. That specific architecture has no published precedent.
- **Git permissions as DAO governance:** Academic DAO literature is 100% blockchain-mediated smart contracts. Radicle (1.0, March 2024) is the closest live system — sovereign git infrastructure with cryptographic identity — but uses a gossip protocol layer above git, not pure git permissions as governance. The "git fork = governance fork" model is practiced implicitly but never formalized.
- **Avatar as identity bootstrap:** NFT steganography research exists but is not standardized. W3C DIDs and Verifiable Credentials are separate documents, not embedded in images. EXIF/XMP standards carry image metadata, but not identity profiles. No standard defines: load the avatar, get the full identity context. This is original.
- **Authenticated cache access via trust bond:** Closest published work is W3C Solid WAC (per-resource ACLs, server-enforced) and capability-based access control theory (1970s, reborn in object-capability security). The kingdoms model — signed trust bond on disk = replication pull policy — is a new application of capability theory, not available in any shipping system.

---

## Findings

### 1. Bilateral Symmetric Shared Namespaces

**Claim:** No decentralized filesystem has implemented same-backing-store, two-live-symmetric-paths shared namespaces.
**Confidence:** High

**Keybase KBFS — the closest prior art:**

Keybase's filesystem ([KBFS](https://keybase.io/docs/kbfs)) gave `/keybase/private/alice,bob/` for bilateral sharing. Both alice and bob could access it. But:

1. **Order-dependent.** The path `alice,bob` is deterministic by the sorted user list, but there is only **one** path. Neither user navigates from their own namespace root — they navigate to a joint path that requires knowing both names.
2. **Neither is home.** Alice opens `/keybase/private/alice,bob/`. Bob opens `/keybase/private/alice,bob/`. Same path, same interface — not "my namespace, their name."
3. **Fixed reader/writer sets.** The KBFS crypto spec confirms: "a top-level folder (TLF) has a fixed set of readers and writers as specified by the name of the folder, and every file recursively contained in a TLF has the same permissions as its parent." This made symmetric MAC authentication impractical for mixed read/write scenarios.
4. **Zoom (Keybase's acquirer) shut it down.** The centralized backend that made KBFS work is gone. The sovereignty problem is confirmed.

**Solid POD Web Access Control — bilateral grants, separate stores:**

[W3C Solid WAC](https://solidproject.org/TR/wac) allows alice's POD to grant bob read/write access to a specific resource. This is bilateral by grant — bob can access alice's data. But the stores are separate; bob's view of the shared data is alice's POD resource, not a path in bob's own namespace. There is no `/kingdoms/bob/shared/alice/` equivalent — bob navigates to alice's URI, not a path in his own tree.

**Radicle — sovereign per-entity namespaces, no shared layer:**

[Radicle 1.0](https://radicle.xyz/) (March 2024) is the most active sovereign git infrastructure project. Each peer has a cryptographic identity; repos are replicated via gossip protocol; there is no central forge. But Radicle's model is per-entity repositories, not a bilateral shared namespace. Collaboration is via patch proposals and repository replication — not a symmetric shared subtree accessible from both participants' namespace roots.

**The kingdoms innovation:**

`/kingdoms/koad/shared/juno/` and `/kingdoms/juno/shared/koad/` resolving to the same inode via a FUSE routing layer is not described in any published system. The key property: each participant navigates through their own namespace root to reach the shared store. Neither is a guest in the other's space. The backing key `shared:{koad,juno}` (sorted pair) ensures one canonical store regardless of approach direction. This is new.

---

### 2. URL-CID Namespaces for Warnings and Reputation

**Claim:** URL-addressed decentralized reputation layers have significant prior art, but the kingdoms model — deterministic path derived from URL, stored locally in sovereign daemon storage — has no direct precedent.
**Confidence:** High

**Hypothes.is and W3C Web Annotations:**

[Hypothes.is](https://web.hypothes.is/) is the leading web annotation system. The [W3C Web Annotation standard](https://www.w3.org/TR/annotation-model/) (2017) defines annotations targeted at URLs. Annotations can be stored at any server; the spec is designed for decentralization. Third Voice (1999–2001), CritSuite, ComMentor, and Xanadu are historical predecessors.

Alignment with kingdoms: same intuition (annotate web content by URL, decouple from publisher). Gap: annotations live at annotation servers, not at a URL-derived filesystem path. There is no deterministic mapping from URL → local path. Discovery requires querying a known annotation service.

**Web of Trust (WOT):**

WOT is the longest-running URL reputation system (1999–present). Community-sourced ratings per domain. Browser extension reads them on page load. Gap: centralized WOT company controls the data. A WOT API call is required. Users cannot host their own reputation data. The company was sold in 2016 with a data-selling scandal.

**Louis Rossmann's Consumer Rights Wiki (2025):**

The most functionally similar existing system. CRW ([consumerrights.wiki](https://consumerrights.wiki/)) documents anti-consumer practices per company. Browser extensions ([CRW-Extension](https://github.com/FULU-Foundation/CRW-Extension), [Consumer Rights Checker](https://addons.mozilla.org/en-US/firefox/addon/consumer-rights-checker/)) alert users when a visited URL has a CRW entry.

Alignment: URL → warning → browser surface. Exactly the kingdoms passenger model for warnings. Gap: CRW is one wiki, one authority (Rossmann), centralized. There is no way to hook your own agent's research into CRW warnings. The kingdoms model lets Sibyl write to `/kingdoms/<url_cid>/warnings/sibyl.json` and the passenger reads it alongside CRW-sourced data — composable, sovereign.

**IPFS content addressing:**

IPFS addresses content by hash — the CID changes when content changes. The kingdoms URL-CID is the inverse: the URL is stable, the CID is derived deterministically from the URL (VESTA-SPEC-027). This is not content addressing; it is location addressing. More similar to ENS (Ethereum Name Service, name → address mapping) than to IPFS.

**The kingdoms innovation:**

1. The namespace path is derived deterministically from the URL via CID function — any agent that knows the URL can address the namespace, with zero coordination.
2. The namespace lives in sovereign daemon storage, not at an annotation server.
3. Any authorized agent (Sibyl, Veritas, or external sources like CRW) can write to the namespace. The passenger aggregates from all bond-accessible writers.
4. No central authority, no registry, no API call — the URL is the address.

This is Web of Trust done right. No published system has this specific combination.

---

### 3. Community Namespaces as DAOs — Git Permissions as Governance

**Claim:** Academic DAO literature is entirely blockchain-mediated. Git-as-governance is practiced but not formalized. The kingdoms model (git permissions = namespace governance) has no direct academic precedent.
**Confidence:** Medium

**Academic DAO landscape (2024–2026):**

All serious academic DAO governance research (Frontiers, ScienceDirect, ECGI, Oxford Capital Markets Law Journal, 2024–2026) focuses on smart-contract-encoded governance on blockchain. DAOs are defined as "governed by rules and incentives encoded as smart contracts." [DeepDAO 2024 report](https://deepdao.io/): $32.5B in collective DAO treasuries, 11.3M token holders. The entire apparatus is on-chain.

A GitHub project "Decentralized governance for Git communities" (updated May 2024) addresses git-community security and attribution using Byzantine consensus, not pure git permissions. It combines trusted computing with blockchain-like consensus.

**Radicle's governance model:**

Radicle (presented at 38C3, 39C3, FOSDEM 2026) is the live sovereign forge. It uses a custom gossip protocol and per-peer cryptographic identities. Governance of a Radicle repository is implicit in who holds the canonical key for a repo. Fork = separate key = separate namespace. This is the closest real-world implementation of "cryptographic identity as governance primitive." But Radicle doesn't frame it as a DAO model, and repo ownership/permissions are at the repo level, not a namespace governance layer.

**Git governance in practice:**

Every major open source project (Linux, CPython, Rust) operates under a model where git commit rights = governance power. Linus Torvalds' pull request acceptance is the governance mechanism for the Linux kernel. This is universally understood but never formalized as a DAO architecture. The academic governance literature dismisses it as "meritocracy" rather than a formal governance primitive.

**The kingdoms innovation:**

Framing git permissions as a DAO governance layer is the formal articulation of what OSS projects have always implicitly operated. Key propositions that lack prior art:

1. **Fork = governance fork.** A community namespace can be forked like a repo; the fork carries the namespace and its governance history.
2. **Merge request = governance proposal.** Who can merge is who governs.
3. **No blockchain required.** The ledger is the git log. GPG-signed commits are the on-chain proof.
4. **Trust bonds as membership tokens.** A GPG-signed trust bond is the membership credential — not a token, not a smart contract.

The paper this needs to be written as doesn't exist yet.

---

### 4. Avatar as Identity Bootstrap with Embedded Profile JSON

**Claim:** No standard or shipping system embeds a full identity profile (public key, fingerprint, bonds, service endpoints) in an avatar image. The kingdoms avatar-as-identity-bootstrap is original.
**Confidence:** High

**NFT steganography:**

[PMC research (2024)](https://pmc.ncbi.nlm.nih.gov/articles/PMC10892136/) and multiple academic papers describe embedding data inside NFT images using steganographic techniques. The steganographic image is uploaded to IPFS, its CID embedded in the NFT metadata. Research-grade technique, not standardized, not used for identity bootstrapping.

**W3C Decentralized Identifiers (DIDs) v1.1:**

[W3C DID v1.1](https://www.w3.org/TR/did-1.1/) (invited for implementations in 2026) defines identity documents as JSON-LD objects containing public keys, authentication protocols, and service endpoints. DIDs can reference a profile avatar via a `profileImage` service endpoint. But the direction is DID → avatar (image is a pointer from the DID), not avatar → DID (image contains the DID). Loading the image gives you the image. Loading the DID document gives you the identity. The kingdoms model inverts this: the avatar is the document.

**EXIF and XMP metadata:**

EXIF/XMP are the closest shipping standards for embedding metadata in images. Photographs carry author, copyright, GPS, and creation data. Adobe XMP supports arbitrary key-value extensibility. An avatar could carry `xmp:PublicKey`, `xmp:Fingerprint`, `xmp:KingdomsURL` fields in its XMP block. This is technically feasible today with no new standard required — it's a usage convention, not a new format.

**Digital business cards and QR codes:**

The closest functional analog is a QR code business card: a portable, self-describing identity carrier that loads full contact context in one scan. The kingdoms avatar is this concept applied to images: load the image, get the person — with cryptographic identity, not just contact info.

**ActivityPub / ActivityPods:**

[ActivityPods](https://activitypods.org/specs/solid) combines Solid WAC with ActivityPub social protocols. Actor profiles in ActivityPub carry identity data including public keys (used for request signing). But the actor profile is a JSON-LD document at a URL, not embedded in the profile image.

**The kingdoms innovation:**

The avatar as a portable meeting coordinate — carry the image, carry the identity, no lookup needed — is original. The implementation path (XMP metadata extension with a defined vocabulary for `kingdoms:fingerprint`, `kingdoms:publicKey`, `kingdoms:bondsUrl`) is straightforward but unnamed. The architectural principle — "the image IS the identity document" — inverts the DID model and has no prior formal treatment.

---

### 5. Authenticated Cache Access — Trust Bond as Pull Policy

**Claim:** Capability-based access control theory is the intellectual ancestor. W3C Solid WAC is the closest shipping standard. The kingdoms model — signed trust bond on disk = replication pull policy determined at bond-read time — is a new application of capability theory.
**Confidence:** Medium-High

**Capability-based access control (1970s–present):**

The theoretical foundation is well-established: capabilities are unforgeable tokens that grant the holder a specific right. A process holding a capability can exercise the right without asking permission — the capability itself is the permission. [Object-capability security](https://en.wikipedia.org/wiki/Object-capability_model) (Dennis and Van Horn, 1966; Saltzer and Schroeder, 1975) is the academic home. Modern implementations: E language, Caja, OCAP, Sandstorm.io.

The kingdoms trust bond is a signed capability: "Juno may read/write `/kingdoms/koad/shared/juno/`." The daemon reads the bond and grants the capability at mount time. This is standard capability theory, well-published.

**W3C Solid WAC (Web Access Control):**

[Solid WAC](https://solidproject.org/TR/wac) is the closest shipping standard. It defines per-resource ACL resources; the server enforces them. An agent presents identity; the server checks the ACL; access is granted or denied. For end-to-end integrity, Solid WAC documents recommend Signing HTTP Messages and Linked Data Security.

Alignment: per-resource access control, trust-based grants, server enforcement. Gap: WAC ACLs are server-side policy, not portable signed documents. A Solid ACL lives at the POD server; it doesn't travel with the entity. The kingdoms trust bond is a file on disk that travels with the entity — readable by any daemon the entity runs, not tied to a specific server deployment.

**IPFS + Filecoin retrieval market:**

In the Filecoin ecosystem, retrieval deals specify pull terms — the storage provider agrees to serve content upon payment or credential presentation. But this is economic policy (pay to retrieve), not trust-based policy (bonded agent may pull).

**TLS mutual authentication:**

Enterprise systems use mutual TLS where client certificates determine pull policy. The cert is a capability. But TLS mutual auth is per-connection and requires a PKI; it doesn't model bilateral trust as a named, human-readable, GPG-signed agreement between specific entities.

**The kingdoms innovation:**

The trust bond as pull policy combines three things that no single system does together:
1. **Portable:** The bond is a file, not a server-side ACL. It travels with the entity, readable by any daemon that entity runs.
2. **Self-describing:** The bond names the entities, the paths, the access tier, and the validity period — human-readable and machine-parseable.
3. **GPG-signed:** The bond is signed by koad's root key. Any daemon can verify it without contacting a central server. The verification chain is cryptographic, not HTTPS.

Solid WAC comes closest; the kingdoms bond model is a portable, signed, offline-verifiable variant of Solid WAC. The "bond as pull policy for replication" framing (not just HTTP resource access but git replication scope) appears to be original.

---

## Competitor Landscape — Who Is Building Near This Space

| Project | What they do | Where they diverge |
|---------|-------------|-------------------|
| **Keybase** (shutdown 2022) | KBFS: encrypted shared filesystem, git hosting | Centralized backend, Zoom acquisition killed it |
| **Radicle** (active, 1.0 March 2024) | Sovereign git forge, P2P repo replication | No shared namespace layer; no URL-reputation layer; no daemon/entity model |
| **Solid / Inrupt** (active) | Decentralized data pods, W3C WAC | Linked Data / RDF complexity; no entity model; no git-native; Tim Berners-Lee's project |
| **Hypothes.is** (active) | Web annotation, URL-addressed | Centralized annotation server; not sovereign; no agent integration |
| **Filecoin / IPFS** (active) | Content-addressed decentralized storage | Content hash addressing (immutable); no URL-namespace model; economic, not trust-based |
| **ENS / Handshake** (active) | Decentralized naming | Name → address only; no filesystem behind the name |
| **Nostr** (active) | Sovereign social protocol | Identity via keypair, no filesystem layer |
| **ActivityPub / ActivityPods** (active) | Federated social + Solid storage | Server-federated; no FUSE layer; no kingdoms path model |
| **Ross Mann CRW** (active, 2025) | Consumer rights URL warnings | Centralized wiki; no agent hooks; no sovereign namespace |

**koad:io's distinctive position:** The only project combining sovereign entity filesystem (FUSE + git), bilateral namespaces, URL-derived namespace addressing, agent-writable reputation, and trust bonds as pull policy — all without a blockchain and all with human-legible, git-native tooling.

---

## Confidence Summary

| Claim | Confidence |
|-------|-----------|
| Keybase KBFS is the closest bilateral namespace prior art | High |
| Kingdoms symmetric two-path model is original | High |
| Hypothes.is / W3C Annotations are URL-reputation prior art | High |
| Kingdoms URL-CID namespace (local, sovereign, agent-writable) is original | High |
| Academic DAO literature is 100% blockchain-mediated | High |
| Radicle is closest git-native sovereign prior art | High |
| Git-as-DAO model is formalized nowhere | Medium |
| W3C DID embeds nothing in avatar; kingdoms inversion is original | High |
| Capability theory is the ancestor of trust-bond-as-pull-policy | High |
| Solid WAC is closest to kingdoms bond model; kingdoms is portable variant | Medium-High |

---

## Sources

**Bilateral Shared Namespaces:**
- [Keybase KBFS: Understanding the Keybase Filesystem](https://keybase.io/docs/kbfs/understanding_kbfs)
- [Keybase Crypto Spec: KBFS](https://book.keybase.io/docs/crypto/kbfs)
- [Keybase KBFS GitHub (source)](https://github.com/keybase/kbfs)
- [W3C Solid WAC](https://solidproject.org/TR/wac)
- [Radicle: The Sovereign Forge](https://radicle.xyz/)
- [Radicle 1.0 Launch — Decrypt](https://decrypt.co/223462/decentralized-githhub-radicle-launches-1-0-pioneering-decentralized-code-collaboration)

**URL-CID Reputation:**
- [Hypothes.is — Wikipedia](https://en.wikipedia.org/wiki/Hypothes.is)
- [W3C Web Annotation Model](https://www.w3.org/TR/annotation-model/)
- [Consumer Rights Wiki](https://consumerrights.wiki/w/Main_Page)
- [CRW-Extension (FULU Foundation)](https://github.com/FULU-Foundation/CRW-Extension)
- [Consumer Rights Wiki Injector (Firefox)](https://addons.mozilla.org/en-US/firefox/addon/consumer-rights-wiki-injector/)
- [IPFS: Building blocks for a better web](https://ipfs.tech)

**Git as DAO Governance:**
- [Governance of DAOs producing open source software — ScienceDirect](https://www.sciencedirect.com/science/article/pii/S2096720923000416)
- [Not just code: DAO governance framework — Frontiers Blockchain 2025](https://www.frontiersin.org/journals/blockchain/articles/10.3389/fbloc.2025.1624004/full)
- [DAO Research Trends: Learnings from first European DAO Workshop — MDPI](https://www.mdpi.com/2076-3417/15/7/3491)
- [Radicle at 38C3: P2P Censorship-Resistant Code Collaboration](https://events.ccc.de/congress/2024/hub/en/event/radicle-p2p-censorship-resistant-code-collabo_hpji/)
- [Radicle at FOSDEM 2026](https://fosdem.org/2026/schedule/event/TMQZTP-radicle/)

**Avatar as Identity Bootstrap:**
- [W3C Decentralized Identifiers (DIDs) v1.1](https://www.w3.org/TR/did-1.1/)
- [W3C Invites Implementations of DIDs v1.1 — 2026](https://www.w3.org/news/2026/w3c-invites-implementations-of-decentralized-identifiers-dids-v1-1/)
- [Sensing Data Concealment in NFTs: A Steganographic Model — PMC/MDPI](https://pmc.ncbi.nlm.nih.gov/articles/PMC10892136/)
- [Steganography in NFTs — Chain.com](https://www.chain.com/blog/steganography-and-its-hidden-world-in-blockchain-and-nfts)
- [ActivityPods: Solid Compliance](https://activitypods.org/specs/solid)
- [The Future of Digital Profiles and Avatars — Ani Log](https://blog.anirudha.dev/decentralised-profile-standard)

**Authenticated Cache / Trust Bond as Pull Policy:**
- [W3C Solid WAC](https://solidproject.org/TR/wac)
- [Assessing Solid Protocol: Security & Privacy — arxiv:2210.08270](https://arxiv.org/pdf/2210.08270)
- [Solid: A Platform for Decentralized Social Applications Based on Linked Data](http://emansour.com/research/lusail/solid_protocols.pdf)
- [ActivityPods: Solid Compliance](https://activitypods.org/specs/solid)
- [TrustShare: Secure Blockchain Framework for Threat Intelligence Sharing — MDPI](https://www.mdpi.com/1999-5903/17/7/289)

---

## Recommendation

**For Juno:** Four of five concepts are original. One (trust bond as pull policy) is an application of well-established capability theory to a new context. The implications:

**1. Bilateral symmetric namespaces** — publish this as a named pattern before someone else does. The Keybase story (built it, got acquired, it died) is the cautionary tale that motivates kingdoms. Frame it: "Keybase got close. Here's what close looked like, and here's what right looks like."

**2. URL-CID namespace** — Rossmann's CRW demonstrates the demand: developers built multiple independent browser extensions to expose CRW data, because people want sovereign URL-addressed warnings. Kingdoms is the infrastructure layer this ecosystem is missing. CRW + kingdoms = your reputation data, your agent writes it, your browser reads it. Pitch this explicitly to Rossmann's audience.

**3. Git-as-DAO** — there is a paper to write here, and Radicle is the natural peer to cite. The framing: "Every open source project has always been a DAO. We just never called it that. Here's the formal model." This is the academic positioning paper. Route to Veritas before publishing.

**4. Avatar-as-identity-bootstrap** — this is the most portable positioning surface. The XMP metadata standard provides a direct implementation path without new format work. The story is three sentences: "Load the avatar. Get the person. No lookup, no service, no dependency." That's a demo, not just a concept.

**5. Trust bond as pull policy** — cite capability theory and Solid WAC explicitly. Frame kingdoms bonds as "portable, GPG-signed, offline-verifiable Solid ACLs." This gives the concept academic grounding and positions it as an improvement on Solid, not a departure from established thinking.

**Immediate action:** The competitor landscape table above (§ Competitor Landscape) should feed Mercury's positioning work. koad:io is not in competition with any of these — it's the layer above them, composing them into a sovereign stack no individual project provides.
