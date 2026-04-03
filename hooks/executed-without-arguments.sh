#!/usr/bin/env bash
set -euo pipefail
# Sibyl — interactive or prompt-driven
# Usage: sibyl                               → interactive Claude Code session
#        PROMPT="research topic X" sibyl     → non-interactive, identity + prompt
#        echo "research topic X" | sibyl     → non-interactive, stdin

IDENTITY="$HOME/.sibyl/memories/001-identity.md"

PROMPT="${PROMPT:-}"
if [ -z "$PROMPT" ] && [ ! -t 0 ]; then
  PROMPT="$(cat)"
fi

cd "$HOME/.sibyl"

if [ -n "$PROMPT" ]; then
  exec opencode run --model opencode/big-pickle "$(cat "$IDENTITY")

$PROMPT"
else
  exec claude . --model sonnet
fi
