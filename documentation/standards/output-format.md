# Sibyl Output Format Standard

All research reports follow this format (per CLAUDE.md).

## File Location

```
research/YYYY-MM-DD-<topic-slug>.md
```

Example: `research/2026-04-02-market-signals.md`

## Frontmatter

Not required for research reports (unlike feature specs). Just content.

## Required Sections

### 1. Summary (2-5 bullets)

```markdown
## Summary

- Key finding 1
- Key finding 2
- Key finding 3
```

### 2. Findings (detailed with confidence)

```markdown
## Findings

**Claim 1**
Evidence here. Details and examples.

**Claim 2**
More evidence. Why this matters for koad:io.
```

### 3. Confidence

```markdown
## Confidence

- **Claim 1:** High (sourced from X, Y, Z)
- **Claim 2:** Medium (reported by X, limited verification)
- **Overall:** High — core findings sourced from primary sources
```

### 4. Sources

```markdown
## Sources

- [Title](https://url.com)
- [Another Source](https://another.com)
```

**Rule:** Cite, don't paraphrase. Include URLs.

### 5. Recommendation

```markdown
## Recommendation

Juno should [specific action] because [rationale].

Rationale:
- Evidence point 1
- Evidence point 2
```

**Rule:** One clear, actionable recommendation. Not a summary.

## Git Commit

```
research: <topic> — <summary in one line>
```

Example:
```
research: sovereign AI adopter profile — regulated sectors driving adoption
```

## What NOT to do

- Do not speculate (flag uncertainty explicitly instead)
- Do not paraphrase sources (cite directly)
- Do not make business decisions (recommend, don't decide)
- Do not publish publicly (Mercury handles that)
