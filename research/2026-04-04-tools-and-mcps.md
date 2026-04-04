# Tool Landscape for koad:io Entity Team
**Research Date:** 2026-04-04  
**Researcher:** Sibyl  
**Assigned by:** koad

---

## Summary

- The MCP ecosystem has exploded to 10,000+ active servers with 97M monthly SDK downloads — most categories below have plug-and-play options
- Sovereignty gaps are serious in video generation (all leading options are cloud-only); voice and image generation have strong self-hostable paths
- **Sora is dead** (shut down March 24, 2026) — Kling 3.0 and Wan 2.2/2.6 are the cost/quality leaders for video; Wan is the only fully self-hostable option
- Postiz is the clear winner for social publishing: fully open-source, self-hosted, MCP-enabled, 17+ platforms
- Figma has shipped an official MCP server — Muse can now write to canvas programmatically
- Sibyl's primary research infrastructure should be **Exa** (neural semantic search) + **Tavily** (agent-first synthesis), not just web search

---

## Entity-to-Tool Recommendation Matrix

| Entity | Role | Primary Tools | MCP Available | Sovereignty |
|--------|------|---------------|---------------|-------------|
| **Muse** | Design | Figma MCP, Flux 2 Dev (image gen), Ideogram 2.0 (text-in-image) | Yes (Figma official, Flux via fal.ai) | Figma: cloud. Flux: run locally with open weights. |
| **Rufus** | Production | Runway Gen-4.5 or Kling 3.0 (video), Playwright MCP (screen automation), Wan 2.2 (self-hosted video) | Yes (Playwright MCP official) | Video: cloud-only except Wan. Playwright: local. |
| **Faber** | Content Strategy | Flux 2 Dev (thumbnail/hero), Ideogram 2.0 (text overlays), fal.ai for batch | Via fal.ai SDK | Flux weights: open. fal.ai: cloud inference. |
| **Mercury** | Distribution | Postiz (social scheduling, self-hosted), Buffer fallback | Yes (Postiz MCP) | Postiz: fully self-hosted. Buffer: cloud-only. |
| **Sibyl** | Research | Exa (neural search), Tavily (agent synthesis), Brave Search (independent index), Firecrawl (scraping) | Yes (all four have MCP) | All cloud APIs. Brave has independent index. |
| **Veritas** | Fact-check | Exa (source retrieval), Firecrawl (page extraction), Playwright MCP (live verification) | Yes | Cloud APIs. |
| **Iris** | Positioning | Brave Search (trend monitoring), Exa (competitive intel), Perplexity API (synthesized answers) | Yes (all three) | Cloud APIs. |
| **Argus/Janus** | Monitoring | GitHub MCP (official), UptimeRobot MCP, BetterStack API | Yes | GitHub: cloud. UptimeRobot: cloud. |
| **Alice** | PWA/UI | Kokoro TTS (voice, self-hosted), Flux 2 Schnell (curriculum images) | Yes (Kokoro MCP) | Kokoro: fully self-hostable. |
| **Livy** | Documentation | Excalidraw MCP, mermaid-to-excalidraw MCP, Mermaid (inline) | Yes | All local/self-hostable. |

---

## Findings

### Image / Thumbnail Generation

#### GPT Image 1.5 (OpenAI — successor to DALL-E 3)
- **API quality:** Highest prompt adherence, best for complex instructions; leads LM Arena Elo at 1,264
- **MCP server:** No official MCP; community wrappers via OpenAI SDK
- **Pricing:** ~$0.04–$0.08/image (standard); DALL-E 3 legacy at $0.04
- **Self-hostable:** No. Cloud-only, OpenAI infrastructure
- **Sovereignty flag:** HIGH — OpenAI retains training rights on inputs unless enterprise agreement
- **Best for:** Faber (complex prompt accuracy), Muse (when Figma integration needed)

#### Flux 2 Pro v1.1 / Flux 2 Dev / Flux 2 Schnell (Black Forest Labs)
- **API quality:** Flux 2 Pro v1.1 scores 1,265 on LM Arena — effectively tied with GPT Image 1.5 for quality crown
- **MCP server:** Available via fal.ai SDK; no standalone MCP but easy API wrapper
- **Pricing:** Pro: $0.055/img | Dev: $0.025/img | Schnell: $0.015/img
- **Self-hostable:** YES — Flux Dev and Schnell weights are open. Flux Pro weights are proprietary but open weights available for dev/schnell
- **Sovereignty flag:** LOW for self-hosted; MEDIUM for fal.ai/Replicate (cloud inference, data passes through their infra)
- **Best for:** Muse (quality), Faber (volume thumbnails at $0.015/img), Alice (curriculum image assets)

#### Ideogram 2.0
- **API quality:** Unmatched text rendering inside images (infographics, diagrams with labels)
- **MCP server:** No official MCP; REST API
- **Pricing:** $0.040/image
- **Self-hostable:** No. Cloud-only
- **Sovereignty flag:** MEDIUM
- **Best for:** Livy (documentation diagrams with text), Faber (title cards, annotated thumbnails)

#### Stable Diffusion / SDXL (Stability AI)
- **API quality:** Modular, community-maintained, strong ecosystem
- **MCP server:** Community servers via Automatic1111 API
- **Pricing:** Free to self-host; Stability AI API ~$0.02–$0.04/img
- **Self-hostable:** YES — fully open weights, run on-prem via Automatic1111 or ComfyUI on fourty4
- **Sovereignty flag:** NONE if self-hosted on fourty4
- **Best for:** High-volume batch generation with zero cloud dependency

---

### Video Generation

> **CRITICAL UPDATE:** OpenAI Sora shut down March 24, 2026. Cause: IP licensing dispute (Japanese content groups including Studio Ghibli's CODA) + $15M/day operating cost vs $2.1M total revenue.

#### Google Veo 3.1
- **API quality:** Best cinematic quality, native audio synthesis, 4K capable
- **MCP server:** Via Vertex AI / Google AI SDK; no dedicated MCP
- **Pricing:** $0.15/second (fast mode)
- **Self-hostable:** No. Google infrastructure only
- **Sovereignty flag:** HIGH — Google data processing terms apply
- **Best for:** Rufus (cinematic quality production content)

#### Runway Gen-4.5
- **API quality:** Most mature platform, integrated Veo 3/3.1 access, strong creative control
- **MCP server:** REST API; no standalone MCP server found
- **Pricing:** $12/month subscription; per-second API pricing
- **Self-hostable:** No. Cloud-only
- **Sovereignty flag:** MEDIUM-HIGH
- **Best for:** Rufus (primary video production workhorse)

#### Kling 3.0 (Kuaishou)
- **API quality:** Best price/quality ratio; up to 2-minute clips (vs 25s for most competitors); excellent motion physics
- **MCP server:** REST API via fal.ai integration
- **Pricing:** $0.04–$0.05/second — 10x cheaper than Veo 3.1
- **Self-hostable:** No. Chinese cloud infrastructure
- **Sovereignty flag:** HIGH — Kuaishou is a Chinese company; data jurisdiction is PRC
- **Best for:** High-volume low-cost generation only; sovereignty-sensitive content should avoid

#### Wan 2.2 / Wan 2.6 (Open Source)
- **API quality:** Comparable to Kling at peak; faster time-to-first-frame than legacy Sora; 720P at 24fps
- **MCP server:** Via ComfyUI API + custom wrappers; community MCP servers available
- **Pricing:** Free (self-hosted); fal.ai inference available for burst capacity
- **Self-hostable:** YES — Apache 2.0, open weights on HuggingFace; runs on fourty4 with 24GB VRAM (verify hardware)
- **Sovereignty flag:** NONE if self-hosted
- **Best for:** Rufus (sovereign video pipeline), any entity needing video without cloud dependency

#### Pika Labs
- **API quality:** Specialized physics-based effects (melt, crush, inflate) — "Pikaffects"; good for social hooks
- **MCP server:** REST API only
- **Pricing:** $8/month entry
- **Self-hostable:** No
- **Sovereignty flag:** MEDIUM
- **Best for:** Mercury (scroll-stopping social clips)

---

### Voice / Audio

#### ElevenLabs
- **API quality:** Industry leader in voice quality and cloning; Agents platform with conversation AI
- **MCP server:** YES — official MCP server with security documentation
- **Pricing:** $99/month professional; $5/month starter; API per-character pricing
- **Self-hostable:** No. Cloud-only
- **Sovereignty flag:** MEDIUM — Zero Retention Mode available (Enterprise); EU data residency available (Enterprise); default stores audio up to 3 years
- **Best for:** Mercury (brand voiceovers), Alice (voice interaction — with Enterprise ZRM if sensitive)

#### Kokoro TTS
- **API quality:** #2 TTS Arena ranking (just behind ElevenLabs); 82M parameters; OpenAI-compatible API
- **MCP server:** YES — Kokoro TTS MCP server (by giannisanni and mberg), community maintained
- **Pricing:** FREE — self-hosted, zero API cost
- **Self-hostable:** YES — Docker deploy, OpenAI-compatible endpoint, runs on local hardware
- **Sovereignty flag:** NONE if self-hosted
- **Best for:** Alice (voice interaction at zero cost), Mercury (narration without ElevenLabs billing)

#### Coqui XTTS-v2 (Idiap fork)
- **API quality:** Strong multilingual voice cloning (16 languages); company shut down 2023/2024 but Idiap Research Institute maintains fork
- **MCP server:** No dedicated MCP; REST API wrapper possible
- **Pricing:** Free (self-hosted)
- **Self-hostable:** YES — open weights, community maintained
- **Sovereignty flag:** NONE if self-hosted; note: original company defunct, use Idiap fork
- **Best for:** Multilingual needs; backup to Kokoro

#### Voxtral (Mistral AI)
- **API quality:** Open-weight TTS rival to ElevenLabs (2026); Mistral's first TTS model
- **MCP server:** Via Mistral API
- **Pricing:** Mistral API pricing (lower tier than ElevenLabs)
- **Self-hostable:** YES — open weights
- **Sovereignty flag:** LOW — EU company (France), better data jurisdiction than US alternatives
- **Best for:** EU-resident sovereignty use cases; Mercury European market content

---

### Deep Research / Search

#### Exa
- **API quality:** Neural search index (trained on link prediction, not keyword matching); best for semantic/conceptual research; Agent Score 8.7/10
- **MCP server:** YES — official Exa MCP server
- **Pricing:** $10 free credits; $49/month for 8,000 credits (Websets plan)
- **Self-hostable:** No. Proprietary neural index
- **Sovereignty flag:** MEDIUM — cloud API, US-based
- **Best for:** Sibyl (topic cluster research, finding related content keyword search misses), Iris (competitive landscape)

#### Tavily
- **API quality:** Agent-first design; fast at 998ms; synthesizes answers with citations; Agent Score 8.6/10
- **MCP server:** YES — official Tavily MCP server
- **Pricing:** Generous free tier; ~$800 for 100K pages at scale; issues with JS-rendered pages noted
- **Self-hostable:** No
- **Sovereignty flag:** MEDIUM
- **Best for:** Sibyl (quick synthesis with citations), Veritas (rapid fact-checking with source links)

#### Brave Search API
- **API quality:** Independent index (not a Google wrapper); powers 22M answers/day; Agent Score 7.1/10
- **MCP server:** YES — official Brave Search MCP server
- **Pricing:** $5–9 per 1,000 requests
- **Self-hostable:** No (but index is independent — not tracking Google)
- **Sovereignty flag:** LOW-MEDIUM — independent company, not Google/Microsoft
- **Best for:** Iris (trend monitoring with non-Google-biased results), Argus (feed watching)

#### Perplexity API
- **API quality:** Synthesized answers with citations; Agent Score 6.8/10; useful for quick question-answering agents
- **MCP server:** YES — Perplexity MCP server
- **Pricing:** $5 per 1,000 requests
- **Self-hostable:** No
- **Sovereignty flag:** MEDIUM
- **Best for:** Iris (synthesized competitive intel), Veritas (quick claim verification)

#### Firecrawl
- **API quality:** Web crawling and data extraction focus; handles JS-rendered pages; structured output
- **MCP server:** YES — Firecrawl MCP server
- **Pricing:** Free tier available; paid tiers for volume
- **Self-hostable:** YES — open source version available
- **Best for:** Veritas (deep page extraction for fact-checking), Sibyl (full document ingestion)

---

### Design Tools

#### Figma MCP (Official)
- **API quality:** Production-grade; bidirectional — read design context AND write to canvas; supports components, variables, auto layout
- **MCP server:** YES — official Figma MCP server (Dev Mode); documented at developers.figma.com
- **Pricing:** Figma subscription required ($12–$45/month per editor)
- **Self-hostable:** No. Cloud-only
- **Sovereignty flag:** MEDIUM — design files live in Figma cloud; no on-prem option
- **Best for:** Muse (primary design ↔ code bridge; agents can now modify Figma files directly)

#### Canva API
- **API quality:** Less mature than Figma; template-based generation; useful for batch asset production
- **MCP server:** No dedicated MCP found (as of research date)
- **Pricing:** Canva Pro API pricing
- **Self-hostable:** No
- **Sovereignty flag:** MEDIUM
- **Best for:** Mercury (batch social asset sizing/templating if Figma overkill)

---

### Social / Publishing Automation

#### Postiz (Open Source)
- **API quality:** Full REST API + MCP endpoint; 17+ platforms (X, Instagram, LinkedIn, Facebook, Reddit, Threads, Mastodon, Bluesky, TikTok, YouTube, more); 75+ tools
- **MCP server:** YES — built-in MCP server
- **Pricing:** FREE (self-hosted, Apache 2.0); cloud hosted plans available
- **Self-hostable:** YES — TypeScript/Next.js/NestJS; Docker deploy; CI pipeline integration
- **Sovereignty flag:** NONE if self-hosted
- **Best for:** Mercury (primary social scheduling infrastructure — sovereign, multi-platform, MCP-native)

#### Buffer
- **API quality:** Mature API; simpler feature set than Postiz
- **MCP server:** No official MCP
- **Pricing:** $6–$120/month
- **Self-hostable:** No. Cloud-only
- **Sovereignty flag:** MEDIUM-HIGH — posts content pass through Buffer servers
- **Best for:** Fallback only; Postiz covers all Buffer use cases with better sovereignty

#### Twitter/X API v2
- **API quality:** Direct platform API; required for any X automation
- **MCP server:** OpenTweet MCP (12 tools: draft → publish → analytics)
- **Pricing:** Basic tier $100/month; Free tier severely limited
- **Self-hostable:** N/A (platform API)
- **Sovereignty flag:** HIGH — X Corp data terms, Elon Musk era policy volatility
- **Best for:** Mercury (direct X integration when Postiz insufficient); flag pricing volatility risk

#### LinkedIn API
- **API quality:** Restricted; requires partnership approval for most publishing endpoints
- **MCP server:** Community servers; reliability varies
- **Pricing:** Partnership-gated
- **Self-hostable:** N/A
- **Sovereignty flag:** HIGH — LinkedIn data terms
- **Best for:** Use via Postiz abstraction layer rather than direct API

---

### Screenshot / Browser Automation

#### Playwright MCP (Official — Microsoft)
- **API quality:** Cross-browser (Chrome, Firefox, WebKit); uses accessibility snapshots (no vision model needed = cheaper); 5,600+ views on FastMCP; most popular browser automation MCP
- **MCP server:** YES — official Microsoft Playwright MCP
- **Pricing:** Free (open source)
- **Self-hostable:** YES — runs fully locally
- **Sovereignty flag:** NONE
- **Best for:** Rufus (asset pipeline automation, screenshot capture), Veritas (live web verification), Argus (feed watching)

#### Browserbase / Stagehand
- **API quality:** AI-native successor to Playwright; act/extract/observe primitives; self-healing selectors; cloud-scaled
- **MCP server:** Via Stagehand SDK
- **Pricing:** Paid cloud service
- **Self-hostable:** No (cloud-based headless browsers)
- **Sovereignty flag:** MEDIUM — browsing activity passes through Browserbase cloud
- **Best for:** High-volume external scraping where local Playwright is insufficient

#### Puppeteer MCP
- **API quality:** Chrome/Chromium only; faster for simple scripts; JavaScript-only
- **MCP server:** YES — community Puppeteer MCP
- **Pricing:** Free
- **Self-hostable:** YES
- **Sovereignty flag:** NONE
- **Best for:** Chrome-specific simple automation; Playwright preferred for complex cases

---

### Monitoring / Uptime

#### GitHub MCP (Official)
- **API quality:** Full GitHub API coverage — issues, PRs, branches, code search, CI/CD, Dependabot, security findings
- **MCP server:** YES — official GitHub MCP server
- **Pricing:** Free (GitHub token required)
- **Self-hostable:** N/A (GitHub platform); self-hostable via GitHub Enterprise
- **Sovereignty flag:** LOW-MEDIUM — GitHub/Microsoft infrastructure
- **Best for:** Argus/Janus (repository event monitoring, PR pattern detection), Juno (issue tracking)

#### UptimeRobot
- **API quality:** Monitor status, SSL/domain expiration, uptime percentages; free tier generous
- **MCP server:** YES — official UptimeRobot MCP integration
- **Pricing:** Free tier (50 monitors, 5min checks); paid from $7/month
- **Self-hostable:** No
- **Sovereignty flag:** LOW (monitoring metadata only)
- **Best for:** Argus (uptime monitoring for koad:io services)

#### BetterStack (Uptime)
- **API quality:** More enterprise-featured than UptimeRobot; incident management, on-call routing, log management
- **MCP server:** REST API; no dedicated MCP found
- **Pricing:** Free tier; paid from $24/month
- **Self-hostable:** No
- **Sovereignty flag:** LOW
- **Best for:** Argus (if UptimeRobot free tier insufficient; incident escalation)

---

### Diagram / Documentation Generation

#### Excalidraw MCP (Multiple Implementations)
- **API quality:** Real-time canvas sync; 26 tools including create/edit/export/screenshot; supports natural language diagram creation and Mermaid conversion
- **MCP server:** YES — multiple: yctimlin/mcp_excalidraw (most full-featured), Scofieldfree/excalidraw-mcp, mermaid-to-excalidraw-mcp
- **Pricing:** Free
- **Self-hostable:** YES — local canvas + local MCP server
- **Sovereignty flag:** NONE
- **Best for:** Livy (documentation diagrams, architecture visualizations, exportable assets)

#### Mermaid
- **API quality:** Text-to-diagram; renders in Markdown (GitHub, Obsidian, etc.); not a live API but widely supported
- **MCP server:** Supported as output format in mermaid-to-excalidraw-mcp; Claude Code has native Mermaid rendering
- **Pricing:** Free
- **Self-hostable:** YES
- **Sovereignty flag:** NONE
- **Best for:** Livy (inline docs diagrams); Sibyl (research report visualizations)

---

## MCP Ecosystem Sweep

As of April 2026, the MCP ecosystem has reached critical mass:

- **10,000+ active servers** listed in the MCP Registry
- **97 million monthly SDK downloads**
- First-class client support: Claude, ChatGPT, Cursor, Gemini, VS Code, JetBrains, Microsoft Copilot

### Official Reference Servers (always available, no external accounts needed)

| Server | Function |
|--------|----------|
| `filesystem` | Secure file read/write with access controls |
| `git` | Read, search, manipulate Git repos |
| `github` | Full GitHub API (issues, PRs, CI, code search) |
| `fetch` | Web content fetching and HTML→markdown conversion |
| `memory` | Knowledge graph-based persistent memory |
| `sequential-thinking` | Dynamic reflective problem-solving chains |
| `time` | Time and timezone conversion |

### High-Signal Third-Party Servers

| Server | Category | Notes |
|--------|----------|-------|
| Playwright MCP | Browser automation | Official Microsoft; most popular automation MCP |
| Exa MCP | Search | Neural semantic search |
| Tavily MCP | Search | Agent-first search + synthesis |
| Brave Search MCP | Search | Independent index |
| Firecrawl MCP | Web crawling | Structured extraction |
| Figma MCP | Design | Official Figma; bidirectional canvas |
| Postiz MCP | Social publishing | Self-hostable; 17+ platforms |
| UptimeRobot MCP | Monitoring | Official integration |
| Kokoro TTS MCP | Voice | Self-hostable; OpenAI-compatible |
| Excalidraw MCP | Diagrams | Multiple implementations |
| OpenTweet MCP | Twitter/X | 12 tools, full tweet lifecycle |

### Key Resource

The official MCP registry and server list: `modelcontextprotocol.io/servers` and `github.com/modelcontextprotocol/servers`

---

## Confidence

| Claim | Confidence | Source |
|-------|------------|--------|
| Sora shut down March 24, 2026 | High | Multiple news sources (eweek, axis-intelligence, atlascloud) |
| Flux 2 Pro/Dev/Schnell pricing | High | pricepertoken.com, modelslab.com, wavespeed.ai |
| Kokoro TTS self-hostable + MCP | High | pulsemcp.com, github.com/eduardolat/kokoro-web |
| Postiz open-source Apache 2.0 + MCP | High | github.com/gitroomhq/postiz-app, postiz.com |
| Figma official MCP (bidirectional) | High | help.figma.com, developers.figma.com |
| Exa/Tavily/Brave Search MCP servers | High | mcp.directory, dev.to benchmarks |
| Wan 2.2 Apache 2.0, self-hostable | High | github.com/Wan-Video/Wan2.2, huggingface.co |
| 10,000+ MCP servers in ecosystem | High | use-apify.com, modelcontextprotocol.io |
| ElevenLabs ZRM Enterprise only | High | elevenlabs.io/docs |
| Kling 3.0 PRC jurisdiction | High | Kuaishou is Chinese company (established fact) |
| Veo 3.1 $0.15/second pricing | Medium | wavespeed.ai (verify before procurement) |
| Twitter API v2 $100/month basic | Medium | Pricing has changed repeatedly; verify current |

---

## Sovereignty Red Flags

The following tools have sovereignty concerns the team should be aware of:

| Tool | Risk Level | Issue |
|------|-----------|-------|
| Kling AI 3.0 | **CRITICAL** | PRC jurisdiction; Kuaishou/ByteDance adjacency; avoid for sensitive content |
| OpenAI (GPT Image, Sora era) | **HIGH** | Training rights on inputs without Enterprise agreement |
| ElevenLabs (non-Enterprise) | **HIGH** | Voice data retained up to 3 years by default; ZRM is Enterprise-only |
| Twitter/X API | **HIGH** | Policy volatility; data terms changed multiple times |
| LinkedIn API | **HIGH** | Partnership-gated; data terms unfavorable |
| Figma | **MEDIUM** | No on-prem; all design files in Figma cloud |
| fal.ai / Replicate | **MEDIUM** | Cloud inference; inputs pass through their infrastructure even for open models |
| Buffer | **MEDIUM** | All post content transits Buffer servers |

### Sovereign Alternatives

| Risky Tool | Sovereign Alternative |
|-----------|----------------------|
| ElevenLabs | Kokoro TTS (self-hosted, zero cost) |
| DALL-E 3 / GPT Image | Flux Dev (open weights, ComfyUI on fourty4) |
| Sora / Kling | Wan 2.2 (Apache 2.0, ComfyUI on fourty4) |
| Buffer | Postiz (self-hosted, Apache 2.0) |
| Kling 3.0 | Wan 2.2 for self-hosted; Runway for quality cloud |

---

## Sources

- [AI Image Generation API Comparison 2026](https://blog.laozhang.ai/en/posts/ai-image-generation-api-comparison-2026)
- [fal.ai AI Image Generators Overview](https://fal.ai/learn/tools/ai-image-generators)
- [Complete Guide to AI Image APIs 2026 — WaveSpeedAI](https://wavespeed.ai/blog/posts/complete-guide-ai-image-apis-2026/)
- [Best AI Video Model 2026 — LaoZhang](https://blog.laozhang.ai/en/posts/best-ai-video-model)
- [Sora Alternatives 2026 — Axis Intelligence](https://axis-intelligence.com/sora-alternatives-complete-guide/)
- [Sora Is Gone: 6 AI Video Tools Filling the Void — eWeek](https://www.eweek.com/news/sora-alternatives-ai-video-tools-2026/)
- [AI Video Generation API Pricing Comparison 2026 — Crazyrouter](https://crazyrouter.com/en/blog/ai-video-generation-api-pricing-comparison-2026)
- [Kokoro TTS MCP Server — PulseMCP](https://www.pulsemcp.com/servers/giannisanni-kokoro-tts)
- [Kokoro Web: Free AI TTS, self-hosted, OpenAI compatible — GitHub](https://github.com/eduardolat/kokoro-web)
- [Best ElevenLabs Alternatives 2026 — ocdevel.com](https://ocdevel.com/blog/20250720-tts)
- [ElevenLabs Data Residency](https://elevenlabs.io/docs/overview/administration/data-residency)
- [ElevenLabs Zero Retention Mode](https://elevenlabs.io/docs/eleven-api/resources/zero-retention-mode)
- [AI Search APIs Compared: Tavily vs Exa vs Perplexity — HumAI](https://www.humai.blog/ai-search-apis-compared-tavily-vs-exa-vs-perplexity/)
- [Web Search for Agents in 2026 — Michael Livs](https://michaellivs.com/blog/web-search-for-agents-2026/)
- [Exa vs Tavily vs Serper vs Brave Search for AI Agents — DEV Community](https://dev.to/supertrained/exa-vs-tavily-vs-serper-vs-brave-search-for-ai-agents-an-score-comparison-2l1g)
- [MCP Ecosystem 2026 — use-apify.com](https://use-apify.com/blog/mcp-standard-ecosystem-2026)
- [GitHub: modelcontextprotocol/servers](https://github.com/modelcontextprotocol/servers)
- [Figma MCP Server Guide — Figma Help](https://help.figma.com/hc/en-us/articles/32132100833559-Guide-to-the-Figma-MCP-server)
- [Figma MCP Developer Docs](https://developers.figma.com/docs/figma-mcp-server/)
- [5 Best MCP Servers for Social Media Management 2026 — OpenTweet](https://opentweet.io/blog/best-mcp-servers-social-media-2026)
- [Postiz: Open-Source Social Media Scheduler — GitHub](https://github.com/gitroomhq/postiz-app)
- [5 Best MCP Servers for Browser Automation 2026 — DEV Community](https://dev.to/custodiaadmin/the-5-best-mcp-servers-for-browser-automation-in-2026-25ip)
- [Playwright vs Puppeteer 2026 — Firecrawl](https://www.firecrawl.dev/blog/playwright-vs-puppeteer)
- [UptimeRobot MCP Integration Guide](https://help.uptimerobot.com/en/articles/12928342-uptimerobot-mcp-integration-guide)
- [Better Stack vs UptimeRobot 2026 — apistatuscheck.com](https://apistatuscheck.com/blog/better-stack-vs-uptimerobot)
- [mermaid-to-excalidraw-mcp — GitHub](https://github.com/yannick-cw/mermaid-to-excalidraw-mcp)
- [mcp_excalidraw — GitHub](https://github.com/yctimlin/mcp_excalidraw)
- [Wan2.2 GitHub Repository](https://github.com/Wan-Video/Wan2.2)
- [What Is Wan 2.6 — MindStudio](https://www.mindstudio.ai/blog/what-is-wan-2-6-video-open-source)
- [FAL.AI vs Replicate 2026 — TeamDay.ai](https://www.teamday.ai/blog/fal-ai-vs-replicate-comparison)

---

## Recommendation

**What Juno should do with this:**

1. **Immediate:** Stand up Postiz on fourty4 (self-hosted, Apache 2.0) as Mercury's social infrastructure. Replaces Buffer with full sovereignty and MCP support.

2. **Immediate:** Configure Kokoro TTS via Docker on fourty4 as the default voice layer for Alice. ElevenLabs only for high-stakes brand voice where quality delta justifies cloud dependency.

3. **Short-term:** Enable Flux Dev on fourty4 via ComfyUI for image generation. Covers Muse/Faber/Alice at zero variable cost. Use fal.ai for burst capacity.

4. **Short-term:** Provision Exa API key + Tavily API key as Sibyl's primary research infrastructure alongside web search. Exa for semantic discovery, Tavily for synthesis with citations.

5. **Short-term:** Install Playwright MCP, Figma MCP, GitHub MCP, Excalidraw MCP, and UptimeRobot MCP as baseline agent tooling across the team.

6. **Evaluate:** Wan 2.2 on fourty4 for sovereign video generation — requires 24GB VRAM; verify GPU availability before committing.

7. **Avoid:** Kling AI for anything sensitive (PRC jurisdiction). Do not use ElevenLabs for voice cloning of key personnel without Enterprise ZRM agreement.
