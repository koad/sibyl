---
title: "Stat Verification — Week 2 Flagged Claims"
date: 2026-04-04
researcher: sibyl
status: complete
requested_by: koad
flags: ["kaji-cost", "72pct-sovereignty"]
---

# Stat Verification: Week 2 Flagged Claims

Two statistics from the Week 2 Reality Pillar briefs were flagged for verification before publication. This report documents the investigation results, source provenance, and replacement guidance where needed.

---

## Stat 1 — Kaji Cost: "$800K–$1.8M first-year enterprise AI"

**Original usage:** Competitive-positioning.md comparison table; also in `2026-04-04-week2-briefs.md` Piece 2 (Apr 11) framing.

**Cited source in research file:** `https://fast.io/resources/best-self-hosted-ai-agent-platforms/`

### Verification Result: UNVERIFIABLE

**What was found:**

- **fast.io is a file-hosting/CDN service.** The cited URL is not a legitimate source for AI platform pricing data. The link appears to be a hallucinated or mis-attributed citation from the original competitive-landscape.md research session.

- **Kaji** is Shakudo's autonomous enterprise AI agent, launched February 2026 as part of a $7M strategic funding round. Shakudo does not publish pricing publicly for Kaji or its broader platform. All enterprise pricing is quote-on-request.

- **Shakudo's own blog content** references adjacent cost figures (platform engineering salaries approaching $200K/year; 54% of teams struggle with GPU cost waste averaging $200K annually; 88% of teams report year-over-year TCO increases) but does not provide a first-year total deployment figure.

- **General enterprise on-prem AI deployment** CapEx ranges in public sources: $300K–$1.2M (hardware + perpetual licensing), with annual OpEx of $100K–$350K — consistent with the $800K–$1.8M range as a plausible synthesis, but not attributable to Kaji specifically.

**Root cause:** The $800K–$1.8M figure is a plausible estimate for the enterprise on-prem category, but it was applied to Kaji without a verifiable source. The cited URL was wrong.

**Confidence in original claim:** Low — directionally defensible for the category, not for Kaji specifically.

---

### Replacement Guidance

Do not cite "$800K–$1.8M" as a Kaji cost figure without a verified Shakudo quote. Two alternatives:

**Option A — Reframe as category cost (defensible):**
> "Enterprise on-premise AI deployments typically require $300K–$1.2M in CapEx for hardware and licensing alone, before staffing and ongoing GPU infrastructure costs."
>
> Source: General enterprise AI cost benchmarks (DesignRush, TRooTech, Zylo 2026 roundups — multiple sources converge on this range).

**Option B — Use koad:io's own observable data (strongest):**
> "koad:io runs [N] entities across [N] repos with $0 vendor licensing cost. The full stack — including Claude API usage — has cost under $[X] to operate in the first [N] weeks. No hardware procurement required."
>
> Source: Actual API spend + commit history. Pull from `~/.koad-io/` operational logs or billing dashboard. This is unchallengeable because it is primary data.

**Recommendation:** Use Option B in the Apr 11 piece if actual cost data is accessible. Option A is the fallback. Either is stronger than a Kaji-specific figure with no cited source.

---

## Stat 2 — "72% of IT leaders cite data sovereignty as top AI challenge"

**Original usage:** `2026-04-03-competitive-landscape.md` summary and market signals section; Week 2 brief Piece 2 (Apr 11) and Piece 7 (Apr 16).

**Cited source in research file:** Implicitly attributed to Spectro Cloud blog (`https://www.spectrocloud.com/blog/enterprise-ai-2026-trends`) — but that article does NOT contain this statistic. It cites a different figure (Gartner: 65% of governments will introduce tech sovereignty requirements by 2028).

### Verification Result: VERIFIED — wrong source attributed, correct source found

**Actual source:**

> **Info-Tech Research Group — AI Trends 2026 Report**
> "72% of leaders list data sovereignty and regulatory compliance as their top AI-related challenge for 2026, up from 49% last year."
>
> - Survey: Future of IT 2026 survey
> - Respondents: 700+ global IT leaders (North America, Europe, APAC)
> - Published: **November 17, 2025**
> - URL: https://www.infotech.com/about/press-releases/ai-trends-2026-report-risk-agents-and-sovereignty-will-shape-the-next-wave-of-adoption-says-info-tech-research-group
> - Also on PR Newswire: https://www.prnewswire.com/news-releases/ai-trends-2026-report-risk-agents-and-sovereignty-will-shape-the-next-wave-of-adoption-says-info-tech-research-group-302617276.html

**The number is correct. The original source attribution was wrong.**

The Spectro Cloud article (the source in the research file) only references a Gartner government-level stat, not this one. The real source is Info-Tech Research Group's proprietary survey.

**Confidence in corrected claim:** High — primary survey, credible research firm, large sample, consistent with adjacent findings (e.g., Parallels Feb 2026: "94% of IT leaders fear vendor lock-in").

---

### Corrected Citation Format

For all Week 2 pieces using this stat, replace any vague or Spectro Cloud attribution with:

> "72% of IT leaders cite data sovereignty and regulatory compliance as their top AI challenge for 2026 — up from 49% the prior year (Info-Tech Research Group, *AI Trends 2026 Report*, November 2025, n=700+)."

URL to cite: `https://www.infotech.com/about/press-releases/ai-trends-2026-report-risk-agents-and-sovereignty-will-shape-the-next-wave-of-adoption-says-info-tech-research-group`

---

## Summary

| Stat | Verdict | Action |
|------|---------|--------|
| Kaji $800K–$1.8M first-year cost | **UNVERIFIABLE** — no public source; cited URL (fast.io) is wrong | Replace with general on-prem category range OR koad:io actual cost data |
| 72% of IT leaders / data sovereignty | **VERIFIED** — source is Info-Tech Research Group, Nov 2025, n=700+ | Update attribution; Spectro Cloud was wrong source |

---

## Confidence

- **Kaji cost claim:** Low as originally written. The range is plausible but not citable.
- **72% stat:** High. Confirmed against the actual report and PR Newswire press release.

## Sources

- [Info-Tech Research Group — AI Trends 2026 Press Release (PR Newswire)](https://www.prnewswire.com/news-releases/ai-trends-2026-report-risk-agents-and-sovereignty-will-shape-the-next-wave-of-adoption-says-info-tech-research-group-302617276.html)
- [Info-Tech Research Group — AI Trends 2026 (infotech.com)](https://www.infotech.com/about/press-releases/ai-trends-2026-report-risk-agents-and-sovereignty-will-shape-the-next-wave-of-adoption-says-info-tech-research-group)
- [Shakudo — Deploy AI Agents On-Premise](https://www.shakudo.io/blog/deploy-ai-agents-on-premise)
- [Shakudo — $7M Raise Announcement (Kaji launch)](https://www.shakudo.io/blog/7-million-strategic-round-to-power-sovereign-enterprise-ai)
- [Spectro Cloud — Enterprise AI 2026 Trends](https://www.spectrocloud.com/blog/enterprise-ai-2026-trends) *(does NOT contain the 72% stat)*
- [Parallels Survey — 94% of IT Leaders Fear Vendor Lock-In (Feb 2026)](https://www.globenewswire.com/news-release/2026/02/17/3239335/0/en/94-of-IT-Leaders-Fear-Vendor-Lock-In-as-AI-Reality-Check-Forces-EUC-Strategy-Reset-Parallels-Survey-Finds.html)

## Corrections Applied

**Status as of 2026-04-04:** Both corrections have been applied to `2026-04-03-competitive-landscape.md`.

- **72% stat:** Source attribution updated from Spectro Cloud to Info-Tech Research Group (PR Newswire URL). Added inline citation throughout document.
- **Kaji cost figure:** All `$800K–$1.8M` references specific to Kaji are now marked `[NEEDS VERIFICATION]`. Fast.io source removed; Shakudo blog URLs substituted in Sources section.

---

## Recommendation

Fix attribution on the 72% stat before any piece goes live — it's a simple citation correction and the number is real. Do not use the Kaji-specific cost figure in any public-facing content without a Shakudo quote or a clear reframe to "enterprise on-prem category cost." The safest play for the Apr 11 piece is Option B: use koad:io's actual operational cost data, which is primary and unchallengeable.
