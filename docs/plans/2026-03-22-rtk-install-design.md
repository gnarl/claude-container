# RTK (Rust Token Killer) Installation Design

**Status:** APPROVED — implementation in progress (see 2026-03-22-rtk-install.md)

## Overview

Install and configure [rtk](https://github.com/rtk-ai/rtk) inside the claude-container Docker image to reduce token usage when Claude Code runs shell commands.

## Changes

### Dockerfile

Add an rtk install step at the end of the file, after the config COPY steps. Order is required: `rtk init -g --auto-patch` patches the already-copied `settings.json` and appends `@RTK.md` to the already-copied `CLAUDE.md`.

```dockerfile
# ── RTK (Rust Token Killer) ───────────────────────────────────────
# NOTE: Must run AFTER config COPY steps above — rtk init patches
#       /home/coder/.claude/settings.json in place.
RUN curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh \
    && rtk init -g --auto-patch
```

The binary lands in `~/.local/bin`, already on PATH (set for uv).

`rtk init -g --auto-patch` automatically:
- Installs `~/.claude/hooks/rtk-rewrite.sh`
- Creates `~/.claude/RTK.md`
- Appends `@RTK.md` to `~/.claude/CLAUDE.md`
- Patches `~/.claude/settings.json` with the hook

### Justfile

Add a `test` recipe that runs verification commands inside a throwaway container. Assumes the image is already built (`just build` first).

```just
# Test that rtk is installed and configured correctly
test:
    #!/usr/bin/env bash
    set -euo pipefail
    docker run --rm {{image}} bash -c "
        echo '=== rtk version ===' && rtk --version &&
        echo '=== rtk gain ===' && rtk gain &&
        echo '=== rtk init --show ===' && rtk init --show
    "
```

### config/CLAUDE.md

Add `rtk` row to the tools table so Claude inside the container knows it's available.

## How rtk works at runtime

Claude Code's hook in `settings.json` rewrites shell commands transparently (e.g. `git status` → `rtk git status`), filtering verbose output to reduce token usage. Claude sees `@RTK.md` in CLAUDE.md, which provides usage context.

## Verification

`rtk init --show` inside the container should produce:
- `[ok] Hook: ~/.claude/hooks/rtk-rewrite.sh`
- `[ok] RTK.md: ~/.claude/RTK.md`
- `[ok] Global (~/.claude/CLAUDE.md): @RTK.md reference`
- `[ok] settings.json: RTK hook configured`
