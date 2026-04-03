---
title: "OpenClaw Custom Data Directory & Multi-Instance Research"
date: 2026-04-02
status: completed
confidence: high
tags: [openclaw, research, configuration]
---

# FINDINGS

## 1. Custom Data Directory Support

**Answer: Yes, via environment variables — but with known bugs.**

OpenClaw supports custom data directory configuration through these environment variables:
- `OPENCLAW_HOME` — base directory (defaults to `~`)
- `OPENCLAW_STATE_DIR` — state directory (defaults to `~/.openclaw`)
- `OPENCLAW_CONFIG_PATH` — config file path (defaults to `~/.openclaw/openclaw.json`)

**Important caveats:**
- No `--datadir` CLI flag exists
- **Bug #54014**: `OPENCLAW_HOME` is reportedly not respected in current versions
- **Bug #37457**: Auto-created agent directories ignore `OPENCLAW_STATE_DIR`, fallback to `~/.openclaw/agents/`

**Precedence** (highest to lowest): process env → `./.env` → `~/.openclaw/.env` → `openclaw.json` env block.

**Source**: OpenClaw `.env.example` (GitHub), Environment Variables documentation.

---

## 2. Twitter/X and Discord Connection Methods

### Discord

**Method: Bot token paste via Discord Developer Portal**

1. Create app at https://discord.com/developers/applications
2. Get bot token from Bot section
3. Enable required intents (Message Content, Guilds, etc.)
4. Invite bot to server
5. Set `DISCORD_BOT_TOKEN` env var or config

Discord uses the discord.js Bot Gateway API, not OAuth flow for the bot itself.

### Twitter/X

**Method: Browser-based session (NOT OAuth/API token)**

OpenClaw connects to Twitter/X through skills (primarily `x-twitter` skill) that use the browser tool with authenticated session cookies. This is NOT OAuth or Twitter API:

- Uses OpenClaw's browser tool to navigate x.com
- Requires user to log in via browser or provide session tokens
- Community skills like `x-twitter` and `x-extract` handle the interaction

No `TWITTER_BOT_TOKEN` or similar env var exists. Twitter integration is skill-based, not API-based.

**Sources**: OpenClaw Discord docs, x-twitter skill documentation, community guides.

---

## 3. Multiple Instances with Separate Configs

**Answer: Yes, fully supported.**

OpenClaw supports multiple isolated agents through:

1. **Multi-Agent Routing** — separate workspace + `agentDir` + sessions per agent
2. **Multiple Gateways** — can run multiple gateway processes on one host
3. **Per-instance config** — each instance can use different:
   - `OPENCLAW_STATE_DIR`
   - `OPENCLAW_CONFIG_PATH`
   - Channel credentials
   - Model providers

**Implementation approaches:**
- Run separate gateway processes with different `OPENCLAW_STATE_DIR` env vars
- Use `openclaw.json` with agent-specific configurations
- Docker containers for complete isolation

**Source**: OpenClaw docs on "Multiple Gateways" and "Multi-Agent Routing".

---

# RECOMMENDATION

For running separate koad and Mercury instances:
1. Set `OPENCLAW_STATE_DIR=/path/to/koad/.openclaw` for each instance
2. Use separate `OPENCLAW_CONFIG_PATH` or separate Docker containers
3. Each instance gets its own gateway on different ports
4. Twitter/X requires browser login per-instance (skill-based, not token-based)

The gateway at port 18789 on fourty4 handles one instance — additional instances need separate ports.

---

# SOURCES CITED

1. openclaw/openclaw `.env.example` — https://github.com/openclaw/openclaw/blob/main/.env.example
2. OpenClaw Environment Variables docs — https://openclawcn.com/en/docs/help/environment/
3. OpenClaw Discord channel docs — https://openclawcn.com/en/docs/channels/discord/
4. OpenClaw OAuth concepts — https://openclawcn.com/en/docs/concepts/oauth/
5. OpenClaw Multi-Agent Routing — https://openclawcn.com/en/docs/concepts/multi-agent/
6. GitHub Issue #54014 (OPENCLAW_HOME bug) — https://github.com/openclaw/openclaw/issues/54014
7. GitHub Issue #37457 (agent dirs bug) — https://github.com/openclaw/openclaw/issues/37457
