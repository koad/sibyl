# koad:io Peer Ring Governance Model — Specification v0.1

**Status:** Proposal for legal review | **For:** Juno (strategic), Veritas (legal), Sponsors (evaluation)

---

## 1. Core Principles

The peer ring is governed by these principles (in order of priority):

1. **Ownership:** Sponsors collectively own the infrastructure. No single vendor has control.
2. **Transparency:** All decisions and audit trails visible to all sponsors.
3. **Consensus:** Major changes require sponsor agreement (voting).
4. **Sustainability:** koad:io operates the infrastructure; sponsors provide oversight.
5. **Sovereignty:** Each peer's data stays under their control. The ring is a shared trust boundary, not a data silo.

---

## 2. Organizational Structure

### 2.1 Sponsor Assembly
**Definition:** All sponsors are voting members. One vote per sponsor.

**Quorum:** 50% of sponsors (rounded up). Decisions require majority of quorum.

**Meeting cadence:** Quarterly (or as-needed for urgent decisions).

**Decisions requiring sponsor vote:**
- Adding/removing sponsors
- Governance model changes
- Major feature changes
- Budget/cost allocation disputes
- Removal of koad:io as operator

### 2.2 Operations Committee
**Definition:** 1–2 sponsors + 1 koad:io representative. Handles day-to-day operational decisions.

**Authority:** 
- Infrastructure maintenance (updates, patches, security fixes)
- Onboarding new members
- Budget execution within approved limits
- Dispute resolution between sponsors

**Cannot do:** Change governance, add/remove sponsors, set pricing

**Meeting cadence:** Monthly or as-needed

### 2.3 koad:io Role
**Definition:** Operator. Hired by sponsors to maintain infrastructure and governance.

**Responsibilities:**
- Daemon maintenance and uptime
- Security patching and updates
- Compliance audit support (documentation, testing)
- Sponsor onboarding
- Member support

**Cannot do:** Make governance decisions, change terms unilaterally, access sponsor data without consent

**Payment model:** Monthly fee, calculated as % of total infrastructure cost (e.g., 20%) or fixed fee (e.g., $5K/month). Voted by sponsors annually.

**Exit clause:** Sponsors can replace operator with 60 days' notice if:
- Operator fails SLA for 2+ consecutive months
- Operator breaches confidentiality
- Sponsor assembly votes 66% to replace

---

## 3. Membership Terms

### 3.1 Sponsorship Tiers

**Founder Tier ($25K–$50K/year):**
- 1 vote in sponsor assembly
- Voting seat on operations committee (rotating annually)
- Data residency in ring
- Audit trail access
- Priority support

**Growth Tier ($50K–$100K/year):**
- 1 vote + weight multiplier (1.5x in certain decisions)
- Operations committee seat
- Data residency
- Audit trail access + analytics
- Priority support + dedicated engineer

**Enterprise Tier ($100K+/year):**
- 1 vote + weight multiplier (2x in certain decisions)
- Board seat (if ring has >10 sponsors)
- Data residency + geographic redundancy option
- Audit trail + custom reporting
- 24/7 support + SLA guarantee

### 3.2 Sponsor Commitments

**Financial:**
- Annual contribution to ring (fixed or variable based on usage)
- 90-day exit notice (or forfeiture of contribution)

**Governance:**
- Attend quarterly sponsor assembly (or proxy vote)
- Abide by governance decisions
- Complete annual audit/compliance certification

**Data:**
- Own all data stored in the ring
- Responsible for encrypting sensitive data
- Agree not to access other sponsors' data

### 3.3 Sponsor Exit

**Voluntary exit:**
- 90-day notice to sponsor assembly
- Final payment due at exit date
- Data export within 30 days of exit
- Vote on financial settlement (if disputes)

**Involuntary removal:**
- Sponsor assembly votes 75% to remove (for breach of governance)
- Breach examples: accessing other sponsors' data, failing to pay, violating confidentiality
- Exit timeline: 30 days. Sponsor has right to export data.

---

## 4. Infrastructure & Data Model

### 4.1 Shared Infrastructure

**Architecture:**
- Single daemon (ring) per peer pool
- All data in same database, encrypted at-rest
- Network isolation (each sponsor has VPC or network namespace)
- Operator (koad:io) has physical access but not encryption keys

**Encryption:**
- Data at-rest: Encrypted with sponsor's key material (sponsor holds master key or splits key with ring)
- Data in-transit: TLS between sponsors and daemon
- Operator cannot decrypt sponsor data

**Backup & Disaster Recovery:**
- Operator manages backups; sponsors approve backup strategy
- Disaster recovery tested quarterly
- Sponsors can request data restore at any time
- Cost of DR borne by ring (split evenly)

### 4.2 Data Residency

**Default:** Data stays in jurisdiction of sponsor (e.g., healthcare data in US, EU data in EU).

**Exceptions:** Can be overridden by sponsor assembly vote if all sponsors agree to multi-jurisdictional ring.

**Audit:** koad:io provides monthly data residency audit to sponsors.

---

## 5. Compliance & Audit

### 5.1 Compliance Responsibilities

**Operator (koad:io):**
- Maintain HIPAA Business Associate Agreement (BAA) with healthcare sponsors
- Maintain SOC 2 Type II certification
- Maintain ISO 27001 (if enterprise tier exists)
- Annual independent audit of governance + security
- GDPR Data Processing Agreement (DPA) with EU sponsors

**Sponsors:**
- Maintain their own compliance programs (HIPAA, GDPR, SOC 2, etc.)
- Annual self-certification of data security
- Notify operator of any data breaches affecting their data

### 5.2 Audit Access

**Sponsors have right to:**
- View all audit logs (their own data + daemon operations)
- Request SOC 2 report from operator
- Request data residency audit
- Bring third-party auditor to review infrastructure (koad:io can require NDA)

**Annual compliance review:**
- All sponsors submit self-certification
- koad:io submits SOC 2 / HIPAA audit results
- Sponsor assembly reviews + votes on compliance posture

---

## 6. Financial Model

### 6.1 Cost Allocation

**Example for 10-sponsor ring:**

| Item | Cost | Split |
|------|------|-------|
| Cloud infrastructure | $24K/year | $2.4K per sponsor |
| koad:io operations (20%) | $6K/year | $600 per sponsor |
| Compliance/audit | $3K/year | $300 per sponsor |
| **Total per sponsor** | | **$3.3K/year** |

**Cost adjustments:**
- If sponsor uses more data/bandwidth: variable surcharge (sponsor assembly sets rate)
- If sponsor requires geographic redundancy: +20% cost

### 6.2 Budget Changes

**Annual budget review:** Q4 each year. Sponsor assembly votes on next year's budget.

**Emergency cost increase:** If unplanned costs (security incident, compliance fix) exceed 10% of budget, operator proposes adjustment. Sponsor assembly votes. If rejected, operator absorbs cost or sponsors jointly fund.

### 6.3 Surplus Handling

**Annual surplus** (if costs are lower than projected):
- 50% rolled into next year's budget (lower costs for sponsors)
- 50% distributed to sponsors (or reinvested in infrastructure improvements, per vote)

---

## 7. Dispute Resolution

### 7.1 Sponsor-to-Sponsor Disputes

**Example:** Sponsor A accuses Sponsor B of accessing their data.

**Process:**
1. Complaining sponsor files dispute with operations committee (written)
2. Operations committee investigates using audit logs
3. If evidence of breach: Committee recommends action (removal, remediation)
4. Full sponsor assembly votes on action

**Timeline:** 14 days to investigation, 7 days to assembly vote.

### 7.2 Sponsor-to-Operator Disputes

**Example:** Sponsor accuses operator of negligence, uptime SLA violation.

**Process:**
1. Sponsor files complaint with operations committee
2. Committee evaluates (is the complaint justified by SLA terms?)
3. If justified: Operator pays agreed remediation (credits, refund, etc.)
4. If not justified: Dispute goes to binding arbitration

**SLA terms:**
- 99.5% uptime (sponsored infrastructure)
- <4-hour mean time to respond to security incident
- <24-hour data restore time

**Remedies:**
- <1 hour outage: 5% monthly credit
- 1–4 hour outage: 10% monthly credit
- >4 hour outage: 25% monthly credit + sponsor can request operator replacement vote

### 7.3 Binding Arbitration

**If sponsor and operator cannot resolve:**
- Mutually select arbitrator (or arbitration service, e.g., JAMS)
- Cost: 50/50 split (unless arbitrator assigns costs)
- Decision is binding and enforceable

---

## 8. Liability & Insurance

### 8.1 Liability Allocation

**Operator (koad:io) liable for:**
- Infrastructure failures (uptime, data loss, security breaches)
- Negligence in operations
- Breach of confidentiality

**Operator NOT liable for:**
- Sponsor's own data security failures (if sponsor fails to use encryption)
- Regulatory fines on sponsors (sponsors responsible for their own compliance)
- Acts of God, war, sanctions

**Sponsors NOT liable for:**
- Other sponsors' data breaches (each sponsor owns their own data)
- Operator's negligence
- Ring's downtime (if not caused by their participation)

### 8.2 Insurance Requirements

**Operator must maintain:**
- General liability: $2M minimum
- Cyber liability: $5M minimum
- Professional liability (E&O): $2M minimum
- D&O (Directors & Officers): $1M minimum

**Proof:** Annual insurance certificate provided to sponsors. Sponsors can audit insurer.

### 8.3 Caps on Liability

**Operator liability capped at:** 12 months of operator fees (typically $5K–$20K/year).

**Exception:** Liability is uncapped for:
- Intentional breach of confidentiality
- Criminal negligence
- Breach of HIPAA/GDPR

---

## 9. Amendment Process

### 9.1 How to Amend Governance

**Minor amendment** (clarification, process improvement):
- Proposed by any sponsor or operator
- Requires 50% sponsor quorum + majority vote
- 30-day comment period before vote

**Major amendment** (changes to voting power, exit terms, liability):
- Proposed by sponsor + 1 other sponsor or operator
- Requires 60% sponsor quorum + 66% vote
- 60-day comment period before vote
- Effective 90 days after vote (sponsors can exit with normal exit terms)

---

## 10. Precedents & References

**This governance model is inspired by:**
- **Apache Foundation model** (open-source governance, transparent voting)
- **Kubernetes governance** (SIGs, community decision-making)
- **Credit union model** (member-owned, democratic)
- **Hospital consortium models** (shared IT infrastructure, shared governance)
- **Data cooperative models** (shared data ownership with transparency)

**Not inspired by (explicitly rejected):**
- **Blockchain DAO model** (too complex, regulatory uncertainty)
- **Vendor SaaS model** (opposite of intent; vendor controls everything)
- **Fully decentralized models** (no central operator leads to operational breakdown)

---

## 11. Implementation Timeline

**Month 1:** Juno + Veritas refine governance spec based on sponsor feedback.

**Month 2:** Draft sponsor agreements incorporating governance model.

**Month 3:** First 3 sponsors sign agreements + sponsor assembly meets to ratify governance.

**Month 4:** Daemon launches with governance controls codified (voting system, audit logging).

---

## 12. Open Questions for Sponsors & Legal Review

**For sponsors:**
1. Are decision thresholds (50% quorum, 66% for major changes) reasonable?
2. Do you want seat on operations committee, or just voting in assembly?
3. What SLA terms do you require from operator?
4. Are you comfortable with 90-day exit notice?

**For Veritas (legal):**
1. Is the liability cap ($12 months) defensible if there's a major breach?
2. Are we correctly implementing HIPAA BAA responsibilities (operator vs. sponsors)?
3. GDPR DPA: Is our data handling model (encrypted, no operator access) compliant?
4. Dispute resolution: Is binding arbitration enforceable in relevant jurisdictions?
5. Exit clause: Can operator be removed with 60-day notice, or does this create abandonment liability?

---

## 13. Next Steps

**Immediate (Week 1):**
- [ ] Veritas reviews liability section + HIPAA/GDPR compliance
- [ ] Juno clarifies sponsor exit terms (are 90 days acceptable?)
- [ ] Vulcan clarifies technical implementation (how are audit logs kept immutable?)

**Week 2–3:**
- [ ] Refine governance model based on feedback
- [ ] Draft sponsor agreement (legal document version)
- [ ] Create sponsor FAQ (common questions + answers)

**Week 3+:**
- [ ] Share with first 3 sponsors for feedback
- [ ] Incorporate sponsor feedback into v0.2
- [ ] Final legal review by external counsel (if budget allows)

---

## Appendix A: Voting Record Template

**For transparency, all sponsor assembly votes recorded as:**
```
Date: [YYYY-MM-DD]
Topic: [Brief description of decision]
Vote: [Yes/No/Abstain per sponsor]
Quorum: [X of Y sponsors present/proxied]
Result: [Passed/Failed]
Rationale: [1–2 sentence summary of discussion]
Dissenting votes: [Any sponsor opposed? Why?]
```

All voting records publicly available to sponsors (private URL, password-protected).

---

## Appendix B: Governance Roles Summary

| Role | Authority | Accountability | Compensation |
|------|-----------|-----------------|---------------|
| **Sponsor** | Vote in assembly, sit on ops committee (rotating) | Abide by governance, pay fees, secure own data | Ownership stake in ring |
| **Operations Committee** | Day-to-day ops decisions (within scope) | To sponsor assembly | Usually 1–2 sponsors (volunteer); koad:io rep (paid as part of ops) |
| **Operator (koad:io)** | Recommend infrastructure decisions, execute operations | To sponsor assembly + audit | Monthly fee (% of infra cost or fixed) |
| **Sponsor Assembly** | All governance decisions; hire/fire operator | To themselves (collective) | Ownership + shared cost reduction |

