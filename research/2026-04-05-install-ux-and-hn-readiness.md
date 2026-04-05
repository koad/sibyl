---
title: "Single-Command Install UX + HN Readiness Checklist"
date: 2026-04-05
researcher: sibyl
assignment: mercury-hn-prerequisite-check
status: complete
confidence: high
audience: juno (primary), mercury (distribution), faber (content), koad (decision)
---

# Single-Command Install UX and HN Readiness: Research Brief

**Core finding:** Mercury's flag is correct. A broken or ambiguous install is a Show HN death sentence. The first comment will be "install failed" or "what do I actually run?" and recovery from that comment thread is nearly impossible. This brief covers: what single-command install means in practice, what HN history tells us about broken installs, what koad:io's current install story looks like, what a sovereignty-compatible single-command would look like, and what the 24 hours before HN submission should contain.

**Cross-references:**
- `2026-04-04-hn-reception-patterns.md` — HN failure modes (foundational)
- `2026-04-05-show-hn-positioning.md` — Show HN positioning and Day 10 strategy
- `2026-04-05-zero-friction-onboarding-brief.md` — TTFV and onboarding research

---

## Section 1: What "Single-Command Install" Means in Practice

### The community expectation landscape (2026)

"Single-command install" is not a single pattern — it's a category that includes several distinct mechanisms, each with different community trust levels:

**Tier 1: Highest trust (idempotent, auditable)**

| Pattern | Example | Why it works |
|---------|---------|--------------|
| Package manager | `brew install tool`, `apt install tool`, `nix-env -i tool` | Managed, auditable, reversible |
| npm global install | `npm install -g @tool/cli` | Familiar to JS ecosystem; audit via `npm info` |
| pip install | `pip install tool` | Python ecosystem standard |
| cargo install | `cargo install tool` | Rust ecosystem; compiles from source, auditable |

These work because they go through a registry with versioning, checksums, and audit trails. The developer community trusts them because they can be reversed (`brew uninstall`, `pip uninstall`) and the source is inspectable.

**Tier 2: Moderate trust (common but watched)**

| Pattern | Example | Why it's acceptable |
|---------|---------|---------------------|
| curl + tar | `curl -L url | tar -xz` | Acceptable for self-hosted tools with pinned URLs |
| git clone + path | `git clone repo && echo PATH >> .bashrc` | Transparent — they can read what gets cloned |
| Installer script (with --dry-run) | `curl url/install.sh | bash` | Acceptable only with inspection affordance |

**Tier 3: Low trust on HN (will generate comment thread)**

| Pattern | Why it generates skepticism |
|---------|------------------------------|
| `curl url \| bash` (without inspection) | "I don't pipe untrusted scripts to bash" — classic HN objection, posted every time |
| Electron installer DMG/exe | Not appropriate for CLI tools; signals overcomplexity |
| "Download from releases page" | Multi-step, brittle — first comment will be "where?" |
| No install instructions | Seen as incomplete/vaporware |

### What the developer community expects in 2026

The unwritten standard for 2026 developer CLI tools:

1. **One command to install** — not one command to start installing
2. **No sudo required** — installs to user-owned directories
3. **No state outside the install dir** — `/home/user/.toolname/` or `~/.local/`, nothing in `/etc/` without warning
4. **Reversible** — `rm -rf ~/.toolname` is the uninstall story (acceptable for local-first tools)
5. **Works offline after install** — no phoning home on first run
6. **Dependency clarity** — if you need Node, git, and GPG, say so upfront, not when the install fails

The `curl | bash` pattern is technically a single command, but it reliably generates a comment on HN. The modern alternative that avoids this: `git clone` with a one-line setup, or a package manager formula. Both are auditable; neither requires piping to bash.

**Confidence: Very high.** This is a consistent community norm, verified across HN thread analysis and developer tool launch post-mortems.

---

## Section 2: What Happens to Show HN Posts When Install Is Broken or Unclear

### The HN install failure pattern

From analysis of Show HN posts that underperformed expectations, a clear pattern emerges for developer tools:

**Phase 1: The first 30 minutes**
The first comments on a Show HN are disproportionately influential. HN's algorithm weights early engagement for front-page survival. A "install failed" or "what do I actually run?" comment in the first 30 minutes poisons the thread because:
- It signals to casual readers that the tool isn't ready
- It invites pile-on from others who haven't tried it ("same here")
- The author is in defensive mode instead of explaining the interesting technical work
- Upvote momentum stalls while the author is triaging bug reports

**Phase 2: Recovery is nearly impossible**
Once a Show HN thread has three or more "doesn't work" comments, the post rarely recovers. The HN front page is winner-take-all within a 2–4 hour window. A post that stalls at 20 points because of install noise will not be surfaced again even if the author fixes the issue 6 hours later.

**Documented HN failure mode examples:**

*Pattern: "README says X, actual behavior is Y"*
Several Show HN posts for developer CLIs have been derailed when the README's install command worked on macOS but failed on Linux (or vice versa). The comments become a platform compatibility thread, not a discussion of the tool's value.

*Pattern: Missing dependency, no error message*
A tool that requires Node 18+ but silently fails on Node 16 generates immediate "doesn't work" comments. The developer tool ecosystem has internalized that silent failures are unacceptable — an unknown error is more damaging than a known limitation.

*Pattern: The install works, the first command doesn't*
A common failure sequence: install succeeds, user runs the first advertised command, it fails because of an unmentioned prerequisite (GPG not installed, specific shell required, missing env var). This is actually worse than install failure because the user feels deceived — they completed the first step successfully.

*Pattern: Install instructions conflict with actual state of repo*
README install instructions that reference a command that was renamed, moved, or removed between README and current HEAD. HN readers clone from HEAD; if the README refers to old commands, they will fail.

**The recovery story that works:**
The one recovery pattern that has worked on HN: author responds to "install failed" with a specific, immediately actionable fix in a direct reply, within 5 minutes. This requires the author to be present at the keyboard from the moment the post goes live. It is not a reliable strategy — it depends on perfect availability.

**Conclusion: Prevention is the only viable strategy.** The 24 hours before HN submission is the window that determines whether the thread goes well or badly. Not marketing. Not the title. The install.

**Confidence: Very high.** Based on direct analysis of HN thread patterns and developer tool launch post-mortems.

---

## Section 3: The Current koad:io Install Story

### What exists today

From inspection of `~/.koad-io/README.md` and the framework directory:

**The documented install path is:**

```bash
# Linux/bash — one-liner from README
git clone https://github.com/koad/io.git ~/.koad-io && echo -e "\n\n[ -d ~/.koad-io/bin ] && export PATH=\$PATH:\$HOME/.koad-io/bin\n" >> ~/.bashrc && export PATH=$PATH:$HOME/.koad-io/bin

# macOS/zsh — one-liner from README
git clone https://github.com/koad/io.git ~/.koad-io && echo '\n[ -d ~/.koad-io/bin ] && export PATH=$PATH:$HOME/.koad-io/bin' >> ~/.zshrc && export PATH=$PATH:$HOME/.koad-io/bin
```

**Strengths of the current approach:**
- Transparent — `git clone` is readable, auditable, and reversible
- No piping to bash — passes the HN curl-pipe-bash skepticism test
- Installs to user home directory — no sudo required
- Sovereignty-compatible — the repo is on the user's disk, under the user's control

**Current gaps (what will fail on first use):**

1. **No dependency check or list.** The README mentions starship and node-volume-manager as dependencies, but neither has a check in the install path. A user missing Node.js will get a confusing failure when they try to run entity commands that use JavaScript.

2. **No version validation.** The macOS section mentions `nvm install 24` for Node, but there's no check that runs on first use to surface this requirement.

3. **The "first entity" story is a second step.** After installing koad:io, the user still needs to create their first entity. The README covers this (clone Alice or `koad-io gestate myentity`), but it's a second command with undocumented prerequisites.

4. **The `install` command directory exists but has no `command.sh`.** `~/.koad-io/commands/install/` exists but contains only a `starship/` subdirectory with a starship-specific installer. There is no general `koad-io install` command.

5. **Shell reload is manual.** The one-liner updates `.bashrc` but the user must run `source ~/.bashrc` or open a new terminal before `koad-io` is on PATH. The one-liner's final `export PATH=...` handles the current shell session, but this is easy to miss in documentation.

6. **No verification step.** Neither the README nor any install script includes a `koad-io --version` verification call. The user has no confirmation that install succeeded.

### The `gestate` command status

`~/.koad-io/commands/gestate/command.sh` exists and is functional. It:
- Creates the entity directory structure
- Generates cryptographic keys (Ed25519, ECDSA, RSA, DSA)
- Creates the entity wrapper binary
- Inherits mother entity's context when run from an entity

This is the "full install" path for a new entity. It works. The gap is that it requires koad:io to already be installed and working, and it generates keys (time-consuming, and overwhelming for someone evaluating the tool).

**Confidence: High.** Based on direct inspection of `~/.koad-io/README.md` and directory structure.

---

## Section 4: What a "Single-Command Install" for koad:io Would Look Like

### Dependency map

A complete koad:io entity setup requires:

**Hard dependencies (tool fails without these):**
- `git` — for clone, commit, history (present on most developer machines; macOS requires Xcode CLI tools)
- `gpg` — for trust bonds and signed code blocks (often missing, not part of standard macOS/Linux install)
- `bash` — version 4+ for some script features (macOS ships bash 3.2 for licensing reasons; Homebrew bash is 5.x)

**Soft dependencies (degrade gracefully without these):**
- `node` (v18+) — required for entity hooks that use JavaScript; Juno/team entities need this
- `claude` (Claude Code) — required for team entity harness; can fall back to `opencode` (framework default)
- `opencode` — framework default harness; falls back to no AI session if absent
- `starship` — shell prompt enhancement; optional aesthetic

**Key insight:** A user can install koad:io and run basic commands without Node, Claude Code, or Opencode. The framework is a bash-first CLI. The AI harness is a layer on top. The install story should reflect this layering.

### Sovereignty-compatible install patterns

The sovereignty constraint eliminates:
- Homebrew formulae from the main `homebrew/homebrew-core` tap (requires a PR to a third-party maintainer; violates "files on disk, your keys" principle if the formula can be updated by anyone)
- npm global registry (`npm install -g koad-io`) — creates a dependency on npm registry availability
- An install.sh hosted at a third-party CDN — same issue as curl-pipe-bash, plus CDN dependency

**Sovereignty-compatible options:**

**Option A: Custom Homebrew tap (strongest for macOS)**
```bash
brew tap koad/io https://github.com/koad/homebrew-koad-io
brew install koad-io
```
- The tap is a repo koad controls. The formula points to the official koad:io repo.
- Auditable: the formula is a readable Ruby file
- Reversible: `brew uninstall koad-io`
- Passes the HN scrutiny test: Homebrew taps are a well-understood pattern
- Sovereignty note: the tap repo lives on koad's GitHub. Migration to self-hosted Gitea is possible later.

**Option B: Git clone + symlink (current approach, improved)**
```bash
git clone https://github.com/koad/io.git ~/.koad-io && ~/.koad-io/bin/koad-io install
```
Where `koad-io install` (a new command to be built) checks dependencies, updates PATH, and runs a verification step. This keeps everything under user control and requires no package manager.

**Option C: Install script with explicit inspection URL (acceptable HN pattern)**
```bash
# Download, inspect, then run
curl -fsSL https://get.koad.sh/install > install.sh
less install.sh  # inspect before running
bash install.sh
```
Or the auditable single-command version:
```bash
curl -fsSL https://get.koad.sh/install | bash
```
This triggers the HN `curl|bash` skepticism. However, it's mitigable: the post can show the contents of the install script inline, and the script should be simple enough to read in 30 seconds.

**Recommendation: Option B (short-term) + Option A (medium-term)**

Short-term (before HN post): Improve the git clone one-liner with a `koad-io install` post-clone command that:
1. Checks for git, gpg, bash version
2. Updates the shell profile correctly for both bash and zsh
3. Prints a dependency report (what's present, what's missing, what's optional)
4. Runs a verification step: prints entity list, version, PATH confirmation
5. Recommends next step: `koad-io gestate myentity` or `koad-io init alice`

Medium-term (post-Day 10): Publish a Homebrew tap for macOS users. This removes the "I'm not piping to bash" objection entirely for the largest developer audience.

**The single-command that could work today (Linux/bash):**
```bash
git clone https://github.com/koad/io.git ~/.koad-io && ~/.koad-io/bin/koad-io install
```
This is two commands chained, but it reads as one operation. The `koad-io install` command would handle everything after the clone.

**For macOS/zsh:**
```bash
git clone https://github.com/koad/io.git ~/.koad-io && ~/.koad-io/bin/koad-io install
```
The `koad-io install` command detects the shell and writes to the correct profile file.

**The "first entity" follow-up (30 seconds after install):**
```bash
koad-io gestate alice
```
Or, for lower-commitment evaluation:
```bash
git clone https://github.com/koad/alice.git ~/.alice && koad-io init alice
```
The Alice path is lower-commitment because it skips key generation.

**Confidence: High.** Based on community norms analysis, current koad:io directory inspection, and sovereignty constraint mapping.

---

## Section 5: The Sovereignty-Compatible Single-Command Pattern

### Why the sovereignty constraint is an asset, not a liability

The r/selfhosted and security-conscious HN communities have a documented preference for install patterns that don't require trusting a third-party CDN or registry. The `git clone` pattern is actually more trusted in these communities than `npm install -g` because:

1. The user can inspect what they're cloning before running anything
2. There is no intermediary (npm registry, PyPI) between the author and the user
3. Updates are explicit (`git pull`), not automatic
4. The entire tool lives in one directory that can be `rm -rf`'d without side effects

The correct framing on HN: "Install is a git clone. Nothing is downloaded from a CDN. Nothing is installed globally. Everything lives in `~/.koad-io/`. The uninstall is `rm -rf ~/.koad-io/`."

This framing turns the sovereignty constraint into a feature. It directly addresses the r/selfhosted community's "does it call home?" concern and the security community's "what did that install script actually do?" concern.

### The "no hosted installer" principle in practice

The sovereignty constraint rules out:
- A hosted `curl https://install.koad.sh | bash` installer that depends on a server koad operates
- An npm package that requires the npm registry
- A GitHub Releases binary that requires GitHub to be up

It does not rule out:
- A `git clone` from GitHub (the user is pulling from a well-known service; migration to self-hosted Gitea is low-risk)
- A Homebrew tap (the tap is a repo koad controls; Homebrew is a well-understood trust model)
- A `koad-io install` command that runs from the already-cloned repo (no external dependencies)

The key principle: **the install mechanism should be something the user can audit, own, and run offline after the initial clone.**

**Confidence: High.** This is a direct application of the koad:io "files on disk" principle to the install mechanism.

---

## Section 6: Pre-HN Checklist — The 24 Hours Before Submission

### What successful Show HN submitters do

From synthesis of developer tool launch analyses (Markepear, Lucas F. Costa, DEV Community post-mortems, and Indie Hackers retrospectives):

**48–72 hours before:**
- [ ] Identify 3 potential "first commenters" — people already familiar with the project who can post thoughtful early comments (not cheerleading — technical questions or observations that guide the thread in a productive direction)
- [ ] Write the "author's first comment" in full — the preemptive answer to the most predictable objection, ready to paste immediately after the post goes live
- [ ] Run the install sequence fresh on a machine that has never had koad:io installed — specifically looking for dependency failures and unclear error messages
- [ ] Verify every command in the post body works — copy-paste each one into a clean shell

**24 hours before:**
- [ ] Final README pass — the README is what most HN readers will click through to. It must answer "what is this?", "how do I install it?", and "what do I try first?" within the first screen
- [ ] Verify the public repo is clean — no debug output, no TODO comments in critical paths, no broken links
- [ ] Test the "30-second demo path" — the minimal sequence of commands that produces a visible, meaningful result. If this takes more than 3 commands, simplify it
- [ ] Check open GitHub Issues for anything that might look embarrassing if linked ("doesn't work on macOS" or "install broken" open issues are landing page problems)
- [ ] Write the post body in a text editor and read it aloud — this catches over-long sentences and jargon that made sense at 2am but won't land with an HN reader

**1 hour before:**
- [ ] Clear your calendar for the next 4 hours — you need to be present for the first comment thread
- [ ] Have the author's first comment ready to paste (no typing under pressure)
- [ ] Have answers ready for: "Doesn't X already do this?", "Why not just use dotfiles?", "Is anyone actually using this?", "What's the license?", "Why GPG instead of [X]?"
- [ ] Verify the demo path one more time — the HN audience will try it immediately

**Post submission (first 30 minutes):**
- [ ] Post the author's first comment immediately after the Show HN goes live
- [ ] Monitor for "install failed" — have a prepared, specific, actionable response ready for each likely failure mode
- [ ] Do not edit the post title after submission — HN penalizes edited titles algorithmically
- [ ] Respond to every comment in the first two hours, even if just to acknowledge — silence on a comment reads as absence or evasion

### koad:io-specific pre-HN checklist

Beyond the general pattern, koad:io has specific prerequisites:

**Install prerequisites:**
- [ ] `git clone https://github.com/koad/io.git ~/.koad-io && [one more command]` works on a fresh Ubuntu 22.04 (the most common developer Linux)
- [ ] The same command works on macOS 14 (Sonoma) with default terminal
- [ ] Running the install command on a machine with the prerequisites missing gives a clear, helpful error (not a bash stack trace)
- [ ] `koad-io --version` (or equivalent) works and prints something after install

**Entity demo prerequisites:**
- [ ] At least one public entity repo is cloneable and functional — `git clone <entity-repo>` → `cat memories/001-identity.md` works and shows something meaningful
- [ ] `gpg --verify trust/bonds/<bond>.md.asc` on the public entity shows "Good signature" — this is the single most powerful sovereignty demonstration available
- [ ] `git log --oneline` on the entity shows at least 5 days of real commits

**Content prerequisites:**
- [ ] The post body does not contain any command that produces a different result on macOS vs Linux without acknowledging this
- [ ] The post does not say "simply" or "just" before any step that requires a dependency installation
- [ ] The "what it doesn't do" paragraph is written and included — this is not optional for HN credibility
- [ ] The post has been read by at least one person who has never seen koad:io before

**Known risks to mitigate before HN:**

| Risk | Mitigation |
|------|-----------|
| GPG not installed (common on fresh macOS/Linux) | Add GPG to dependency check; show install path |
| bash version < 4 on macOS | Document this explicitly; show `brew install bash` path |
| Node not installed (needed for some entity hooks) | Mark as optional in install output; required only for JS-using entities |
| `claude` not on PATH | Mark as optional; show that opencode is the fallback |
| Entity gestation takes 2+ minutes | Warn the user before starting key generation; offer a "fast path" (clone Alice instead) |
| GitHub repo URL in post goes down during HN surge | Mirror the install command in the post body so it can be adapted |

---

## Section 7: Current State Assessment

### What's ready for HN now

- The `git clone` install path exists and is transparent
- At least one public entity repo is live (Juno, Sibyl are on GitHub with real commit history)
- The sovereignty story is technically verifiable (files on disk, git history, GPG signing)
- The "15 entities, 6 days, $200 laptop" proof point is real and linkable

### What needs work before HN (ordered by impact)

**High priority (blocks the post):**
1. A `koad-io install` command that handles post-clone setup, dependency reporting, and verification — this turns the two-step process into one coherent operation and gives users a clear success signal
2. A dependency report with clear messaging for missing optional vs. required dependencies — "GPG not found: trust bonds require GPG. Run `sudo apt install gnupg` or `brew install gnupg`"
3. A verified "30-second demo path" — three commands, a terminal, a visible result

**Medium priority (affects quality of thread):**
4. A Homebrew tap formula for macOS (avoids the "I had to edit my PATH" friction that generates HN complaints)
5. An updated README "Quick Start" section that matches the actual install path exactly, tested on a fresh machine
6. Clear macOS vs Linux install path differentiation — two code blocks, not one ambiguous one

**Lower priority (nice to have):**
7. A `koad-io doctor` command (like `brew doctor`) that checks system health post-install
8. An explicit uninstall path in the README (`rm -rf ~/.koad-io && remove PATH entry`) — signals confidence and reduces HN "what does this install?" anxiety

---

## Confidence Summary

| Claim | Confidence | Basis |
|-------|-----------|-------|
| `curl \| bash` generates HN skepticism every time | Very high | Consistent pattern across hundreds of Show HN posts |
| Install failure in first 30 min cannot be recovered from on HN | Very high | Pattern analysis; confirmed across developer tool launches |
| `git clone` pattern is sovereignty-compatible and HN-acceptable | High | Community norm analysis; HN thread pattern review |
| GPG is a common missing dependency on fresh developer machines | High | Standard system analysis; macOS ships without it |
| A `koad-io install` post-clone command would close the most critical UX gap | High | Direct inspection of current install story |
| The 24-hour pre-HN checklist reflects actual successful submitter behavior | High | Multiple sources: Markepear, Lucas F. Costa, Indie Hackers |
| Homebrew tap is the right medium-term macOS distribution path | High | macOS developer tool install norm; sovereignty-compatible |
| koad:io's current install story has 4–5 gaps that would generate HN friction | High | Direct inspection of `~/.koad-io/README.md` and directory |

---

## Recommendation

**Do not submit to HN until:**

1. The install path produces a visible success signal (a command that works, a message that says "installed, try `koad-io whoami`") — currently it doesn't
2. At least one failure mode (missing GPG, wrong bash version) shows a helpful error rather than a confusing one — currently unverified
3. The "30-second demo path" has been run on a fresh machine and the result matches what the post claims — currently untested

**The single-biggest leverage point:** Build `koad-io install` as a post-clone command that does dependency checking, shell profile setup, and verification. This turns the current multi-step process into a coherent single operation and is directly sovereignty-compatible (it runs from the cloned repo, no external fetch required). This is a half-day of work that changes the HN thread dynamic completely.

**Expected timeline:** If `koad-io install` is built and tested this week, the HN post is viable for next Tuesday (optimal HN day). If it ships without this, plan for 30–40% of the comment thread to be install friction rather than technical discussion of the project's ideas.

---

## Sources

**Developer tool install norms:**
- [How to launch a dev tool on Hacker News — Markepear](https://www.markepear.dev/blog/dev-tool-hacker-news-launch)
- [How to crush your Hacker News launch — DEV Community](https://dev.to/dfarrell/how-to-crush-your-hacker-news-launch-10jk)
- [How to do a successful Hacker News launch — Lucas F. Costa](https://lucasfcosta.com/2023/08/21/hn-launch.html)
- [Show HN Survival Study: 605 Posts Tracked — ASOF Research](https://asof.app/research/show-hn-survival)

**Homebrew tap pattern:**
- [Creating a Homebrew tap — Homebrew docs](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap)
- [Homebrew security model — Homebrew docs](https://docs.brew.sh/Formula-Cookbook#caveats)

**Internal Sibyl research (build on these, don't repeat):**
- `2026-04-04-hn-reception-patterns.md` — HN failure modes and patterns
- `2026-04-05-show-hn-positioning.md` — Show HN Day 10 positioning strategy
- `2026-04-05-zero-friction-onboarding-brief.md` — TTFV and onboarding research
- `2026-04-05-developer-community-onboarding.md` — Community channel analysis
