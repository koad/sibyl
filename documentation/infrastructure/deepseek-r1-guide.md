# Deepseek-r1 Integration

How to use deepseek-r1:8b on fourty4 for long-context research tasks.

## What is deepseek-r1?

- **Model:** deepseek-r1:8b (8B parameters, 128k context window)
- **Host:** fourty4 (Mac Mini, 10.10.10.11)
- **Service:** ollama
- **Strength:** Extended reasoning for complex market/technical analysis

## When to use

Deep research tasks with:
- Long context (analyzing multiple documents, competitive sets)
- Complex reasoning (market viability assessment, gap analysis)
- Multi-part analysis (NIST compliance + competitive + adoption signals)

## How to access

1. Ensure SSH access to fourty4 is configured
2. Query ollama API or CLI:
   ```bash
   curl -X POST http://10.10.10.11:11434/api/generate \
     -d '{
       "model": "deepseek-r1:8b",
       "prompt": "Your research question",
       "stream": true
     }'
   ```

## Examples

- **Market viability assessment:** "Given X, Y, Z market signals, is this sector viable for koad:io?"
- **Gap analysis:** "Compare our feature set against competitors A, B, C. What gaps exist?"
- **Regulatory impact:** "NIST released X. How does it affect sovereign identity adoption?"

## Limitations

- 128k context (plan large analysis into parts if needed)
- No real-time web search (use Claude for that)
- Reasoning is strong but verify critical findings with Veritas

## Maintenance

- Ask Juno if ollama service is down
- No special auth required (internal network)
