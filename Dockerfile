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

WORKDIR /workspace
