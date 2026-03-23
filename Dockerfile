FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ── System packages ──────────────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
        apt-utils git curl ca-certificates sudo \
        build-essential \
        locales \
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    && locale-gen \
    && rm -rf /var/lib/apt/lists/*

ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# ── Go ──────────────────────────────────────────────────────────
ARG GO_VERSION=1.24.1
RUN arch=$(dpkg --print-architecture) \
    && curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${arch}.tar.gz" \
       | tar -C /usr/local -xz

ENV PATH="/usr/local/go/bin:${PATH}"

# ── just ─────────────────────────────────────────────────────────
RUN curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin

# ── Non-root user with passwordless sudo ─────────────────────────
ARG USER_UID=501
ARG USER_GID=20
RUN groupadd -g ${USER_GID} -o coder \
    && useradd -m -s /bin/bash -u ${USER_UID} -g coder coder \
    && echo "coder ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/coder

USER coder
WORKDIR /home/coder

# ── Git safe directory for bind mounts ───────────────────────────
RUN git config --global --add safe.directory /workspace

# ── uv (Python package manager) ─────────────────────────────────
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/coder/.local/bin:${PATH}"

# ── Claude Code CLI ──────────────────────────────────────────────
RUN curl -fsSL https://claude.ai/install.sh | bash

# ── Config files ─────────────────────────────────────────────────
RUN mkdir -p /home/coder/.claude
COPY --chown=coder:coder config/claude-settings.json /home/coder/.claude/settings.json
COPY --chown=coder:coder config/CLAUDE.md /home/coder/.claude/CLAUDE.md

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
