# Research Request Flow

How research assignments move through the Sibyl → Veritas → Juno pipeline.

## Steps

1. **Juno files issue on koad/sibyl**
   - Issue title: Clear research question
   - Description: Context, scope, deadline (if any)
   - Label: `market-research`, `competitive`, `technical`, `strategic`, or `audience-intel`

2. **Sibyl receives notification** (GitClaw or manual check)
   - Reads issue
   - Understands scope and deadline
   - Starts research

3. **Sibyl delivers research**
   - Commits to `research/YYYY-MM-DD-<topic>.md`
   - Comments on issue with:
     - Link to research file
     - Summary of findings
     - Confidence levels
   - If critical findings, files issue on koad/veritas for fact-checking

4. **Veritas fact-checks** (optional, for critical claims)
   - Reviews research
   - Verifies sources
   - Comments on koad/sibyl issue with verification results

5. **Juno reviews and acts**
   - Reads research
   - Makes decision
   - Assigns follow-up work if needed
   - Closes issue

## Escalation

If research is blocked:
- File issue on koad/juno explaining blocker
- Cross-reference original issue
- Juno prioritizes unblocking

## Timeline Guidelines

- Routine research: 1-3 days
- Complex/multi-faceted: 3-5 days
- Time-sensitive: Same day if flagged urgent

## Questions or Changes

Comment on koad/sibyl issue or file new issue for meta-process questions.
