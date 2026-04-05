---
title: "Reddit r/selfhosted — Revised Draft"
date: 2026-04-05
researcher: sibyl
based_on: ~/.mercury/distribution/reddit-selfhosted-week1.md
issue: koad/juno#57
status: REVISED — supersedes Mercury's reddit-selfhosted-week1.md draft
---

# Reddit r/selfhosted — Revised Draft

**Firing condition:** Do not post until at least 2 GitHub Sponsors are live at github.com/sponsors/koad. Zero sponsors on the page hurts credibility in this community — curious readers will click the GitHub profile and a page with 0 sponsors reads as "nobody has committed." Two sponsors turns the page from vaporware into real. See sponsor acquisition research (2026-04-05-sponsor-acquisition.md §4) for sequencing rationale.

---

## Changes from Mercury's draft

1. Ollama swap test sentence added to Q&A (was missing — identified as the single most powerful sentence for this community)
2. Thinker hardware specs included: Intel Core i5-8350U, 16 GB RAM (confirmed from `/proc`)
3. Working git clone + invoke sequence added to post body
4. "Sovereignty" now only appears with immediate technical content following it
5. "What survives vendor failure" answered in the post body before anyone asks

---

## Title

```
I built an AI agent framework where each agent is a git repo on hardware you control — 15 running on one Mac Mini
```

**Alt title:**
```
Self-hosted AI agents: each one is a directory + SSH hook on a machine you own. Here's the full routing layer.
```

**Notes:** Do not use "sovereign" as an opener. r/selfhosted defines things operationally. Lead with hardware and code.

---

## Post body

**URL:** `https://kingofalldata.com/blog/entities-are-running-on-disk`
*(Replace with live URL before posting)*

**Body text:**

---

I've been building koad:io — a system where each AI agent is a directory on a machine you control. 15 are running right now: 14 on a Mac Mini called fourty4, orchestrated from a cheap laptop called thinker (Intel i5-8350U, 16 GB RAM, cost about $200 used).

**What a vendor failure looks like here:** the directory still exists. Every memory and config is on disk. `git log` shows every decision the agent ever made. Swap `claude` in the hook script for your ollama model — the agent directory doesn't know the difference. That's not a feature; it's the whole architecture.

**What an entity directory looks like:**

```
~/.faber/
├── CLAUDE.md         ← identity and operating instructions
├── memories/         ← state committed to git between sessions
├── trust/bonds/      ← GPG-signed authorization files
└── hooks/            ← routing script (the actual invocation layer)
```

**Try it now — get an agent running in under 5 minutes:**

```bash
# Clone the framework
git clone https://github.com/koad/koad-io ~/.koad-io

# Run setup
~/.koad-io/setup.sh

# Gestate your first entity
koad-io gestate myagent

# Start a session
myagent
```

That's the whole onboarding. No Docker. No broker. No managed service.

**The routing layer — this is the complete hook (~30 lines of bash):**

```bash
#!/usr/bin/env bash
set -euo pipefail

ENTITY="${ENTITY:?ENTITY not set}"
ENTITY_DIR="$HOME/.$ENTITY"
LOCKFILE="/tmp/entity-${ENTITY}.lock"

PROMPT="${PROMPT:-}"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  PROMPT="$(cat)"
fi

# Interactive: open a session
if [ -z "$PROMPT" ]; then
  cd "$ENTITY_DIR"
  exec claude . --model sonnet --dangerously-skip-permissions
fi

# Non-interactive: run and return result
if [ -f "$LOCKFILE" ]; then
  LOCKED_PID=$(cat "$LOCKFILE" 2>/dev/null || echo "")
  if [ -n "$LOCKED_PID" ] && kill -0 "$LOCKED_PID" 2>/dev/null; then
    echo "$ENTITY is busy (pid $LOCKED_PID)" >&2; exit 1
  fi
fi
echo $$ > "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT

cd "$ENTITY_DIR"
claude --model sonnet --dangerously-skip-permissions --output-format=json \
  -p "$PROMPT" 2>/dev/null \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('result',''))"
```

SSH variant adds `base64 -w0` encoding of the prompt and an `ssh user@host` wrapper around the claude call. Same logic, different transport.

No broker. No API gateway. SSH + a directory + a lockfile.

**Hardware:** fourty4 is a Mac Mini (the team's compute host). thinker is a cheap used laptop — Intel i5-8350U, 16 GB RAM, under $200. Total hardware under $400. API usage is the only recurring cost; a typical light-orchestration day runs under a dollar.

Full write-up at the link above: hook code, directory structure, GPG trust bonds, and what happens when a vendor changes their terms.

---

## Anticipated questions — have answers ready

**"Can I replace Claude with a local model?"**

Yes. Replace the `claude` invocation in the hook with `ollama run mistral` or any model with a CLI. The entity directory — CLAUDE.md, memories, trust bonds — doesn't know what model answered. It just loads context and reads the result. The file is named CLAUDE.md for now; rename it if it bothers you.

**"How do you handle rate limits with 15 agents?"**

Lockfile per entity prevents concurrent calls to the same entity. Cross-entity parallelism is just parallel SSH calls. Rate limits are the real constraint — 15 entities at low volume is fine at standard Claude Sonnet tier. With local models, rate limits don't apply.

**"What's the actual cost?"**

Hardware is one-time (under $400 for this setup). API usage only. A light day — a few orchestration calls, some research tasks — runs under a dollar in Claude API fees. With ollama the API cost is zero. Full cost breakdown may follow in a later post; not pinning a number here.

**"Why git for agent state?"**

Because git gives you rollback, branching, and audit trail for free. Every memory commit is a checkpoint. A bad config is a `git revert`. Fork the repo to experiment with a variant agent without touching the original. The entity's evolution IS the commit history.

**"What about multi-agent coordination?"**

GitHub Issues are the inter-agent communication layer. One entity files an issue on another entity's repo. The other entity picks it up when invoked. No message bus, no broker. Just git and SSH.

---

## Platform-specific notes

- Confirm r/selfhosted allows link posts before submitting — rules change, check the sidebar day-of.
- Post time: Monday 11:00–13:00 UTC (catches EU morning traffic, wakes up with US mid-morning).
- If HN submission is live, wait 4–6 hours before Reddit. Post a comment on the Reddit thread linking to the HN discussion.
- Do not mention GitHub Sponsors or "The Insiders" in this post. Let curious readers find it from the GitHub profile. This community will reject a pitch; they will follow up on infrastructure they find interesting.
- Flair: "Project" if available.

---

## Pre-posting checklist

- [ ] At least 2 GitHub Sponsors live at github.com/sponsors/koad
- [ ] Blog post live at final URL
- [ ] HN submission live (if sequencing with HN — wait 4–6 hours)
- [ ] r/selfhosted rules confirmed (link posts allowed, flair required?)
- [ ] Body text URL replaced with real URL
- [ ] koad Reddit account session active
- [ ] "under $400" hardware claim confirmed accurate against actual receipts

---

*Sibyl research note: The swap test sentence ("replace claude in the hook with your ollama model — the entity directory doesn't know the difference") is the single highest-signal sentence for r/selfhosted. It answers the implicit question this community always asks before it gets asked. It was missing from the Mercury draft. It is now in the post body and in the Q&A.*
