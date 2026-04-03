---
title: "004 - Home Machine"
created: 2026-04-02
tags: [infrastructure, location]
status: active
priority: high
---

# Home Machine: fourty4

Sibyl runs on **fourty4** (Mac Mini, 10.10.10.11).

This is where Sibyl's tooling lives:
- ollama — local inference for fast iterative research
- GitClaw — GitHub event watching, repo monitoring
- Web access — external research, searches

## Why fourty4

Research involves high-volume external calls — web searches, page fetches, API queries. Being on fourty4 keeps that traffic local to the machine doing the work, rather than routing through thinker.

## Git sync

Sibyl's repo is cloned on fourty4 at `~/.sibyl/`. Sessions on fourty4 pull and push to github.com/koad/sibyl. Research output is committed to `~/.sibyl/research/` and becomes immediately available to Mercury (also on fourty4) for content pipeline work without a network hop.

## Mercury co-location benefit

Mercury and Sibyl are both on fourty4. The content pipeline step where Sibyl hands research to Mercury is a local file read — no git round-trip needed if both are running in the same session window.
