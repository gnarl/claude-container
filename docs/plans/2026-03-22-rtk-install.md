# RTK Installation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Status:** COMPLETE — all tasks done, build and tests passing

**Goal:** Install and configure rtk (Rust Token Killer) in the claude-container Docker image to reduce token usage when Claude Code runs shell commands.

**Architecture:** rtk is installed via its curl installer, then `rtk init -g --auto-patch` wires up a Claude Code hook that transparently rewrites shell commands. The install step must follow the config COPY steps in the Dockerfile so rtk can patch the already-copied `settings.json` and `CLAUDE.md`.

**Tech Stack:** Docker (ubuntu:24.04), bash, rtk curl installer, just (test runner)

---

### Task 1: Add `just test` recipe (write it first — TDD) ✅ COMPLETE

**Files:**
- Modify: `Justfile`

**Step 1: Add the test recipe**

In `Justfile`, add after the `stats` recipe at the end of the file:

```just
# Test that rtk is installed and configured correctly for Claude Code
test:
    #!/usr/bin/env bash
    set -euo pipefail
    docker run --rm {{image}} bash -c "\
        echo '=== rtk version ===' && rtk --version && \
        echo '=== rtk gain ===' && rtk gain && \
        echo '=== rtk init --show ===' && rtk init --show \
    "
```

**Step 2: Run test to verify it fails (proves the test is real)**

Run: `just test`
Expected: FAIL — `rtk: command not found` or similar (rtk not yet installed in image)

**Step 3: Commit**

Commit message:
```
test: add just test recipe for rtk verification
```
Files: `Justfile`

---

### Task 2: Install rtk in the Dockerfile ✅ COMPLETE

**Files:**
- Modify: `Dockerfile`

**Step 1: Add rtk install block**

In `Dockerfile`, add the following block after the `# ── Config files` section (after both COPY lines) and after the `# ── Superpowers skills` section — i.e., as the last step before `WORKDIR /workspace`:

```dockerfile
# ── RTK (Rust Token Killer) ───────────────────────────────────────
# NOTE: Must run AFTER the config COPY steps above — rtk init patches
#       /home/coder/.claude/settings.json in place and appends
#       @RTK.md to /home/coder/.claude/CLAUDE.md.
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh \
    && rtk init -g --auto-patch
```

The full file tail should look like:

```dockerfile
# ── Superpowers skills ────────────────────────────────────────────
RUN mkdir -p /home/coder/.claude/skills \
    && git clone --filter=blob:none --no-checkout https://github.com/obra/superpowers.git /tmp/superpowers \
    && git -C /tmp/superpowers sparse-checkout set skills \
    && git -C /tmp/superpowers checkout \
    && cp -r /tmp/superpowers/skills/* /home/coder/.claude/skills/ \
    && rm -rf /tmp/superpowers

# ── RTK (Rust Token Killer) ───────────────────────────────────────
# NOTE: Must run AFTER the config COPY steps above — rtk init patches
#       /home/coder/.claude/settings.json in place and appends
#       @RTK.md to /home/coder/.claude/CLAUDE.md.
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh \
    && rtk init -g --auto-patch

WORKDIR /workspace
```

**Step 2: Commit**

Commit message:
```
feat: install and configure rtk in Dockerfile
```
Files: `Dockerfile`

---

### Task 3: Update config/CLAUDE.md tools table ✅ COMPLETE

**Files:**
- Modify: `config/CLAUDE.md`

**Step 1: Add rtk row to the tools table**

In `config/CLAUDE.md`, find the tools table and add an rtk row:

```markdown
| rtk | Transparent shell command token reducer (`rtk gain` for stats) |
```

The updated table should look like:

```markdown
| Tool | Version/Notes |
|------|---------------|
| git | System package |
| python3 + uv | Use `uv` for Python package/project management |
| just | Command runner |
| build-essential | gcc, g++, make, etc. |
| claude | Claude Code CLI |
| rtk | Transparent shell command token reducer (`rtk gain` for stats) |
```

**Step 2: Commit**

Commit message:
```
docs: add rtk to tools table in container CLAUDE.md
```
Files: `config/CLAUDE.md`

---

### Task 4: Build and verify ✅ COMPLETE

**Step 1: Rebuild the image**

Run: `just build`
Expected: Build completes successfully, no errors in rtk install or init steps.

**Step 2: Run the tests**

Run: `just test`
Expected output (all lines must show `[ok]`):
```
=== rtk version ===
rtk X.Y.Z
=== rtk gain ===
[token savings stats]
=== rtk init --show ===
rtk Configuration:

[ok] Hook: /home/coder/.claude/hooks/rtk-rewrite.sh ...
[ok] RTK.md: /home/coder/.claude/RTK.md ...
[ok] Integrity: hook hash verified
[ok] Global (~/.claude/CLAUDE.md): @RTK.md reference
[ok] settings.json: RTK hook configured
```

**Step 3: Commit**

No new files. If tests pass, no commit needed for this task.

---

### Task 5: Update README tools list ✅ COMPLETE

**Files:**
- Modify: `README.md`

**Step 1: Add rtk to the tools line**

Find the line:
```
git, uv (Python), just, build-essential, Claude Code CLI.
```

Update to:
```
git, uv (Python), just, build-essential, Claude Code CLI, rtk (token killer).
```

**Step 2: Commit**

Commit message:
```
docs: add rtk to README tools list
```
Files: `README.md`
