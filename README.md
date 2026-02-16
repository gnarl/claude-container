# claude-container

Isolated Docker containers for running [Claude Code](https://docs.anthropic.com/en/docs/claude-code) in YOLO mode (`--dangerously-skip-permissions`) without affecting your host machine.

Project files are bind-mounted so they persist on the host. Containers are long-lived (stop/start). Everything is managed through a Justfile.

## Project origin
This is a modified fork of the [claude-container](https://github.com/paulgp/claude-container) project.

## Prerequisites

- macOS (Apple Silicon)
- [Homebrew](https://brew.sh)
- [just](https://github.com/casey/just) — `brew install just`
- A [Claude Pro or Max subscription](https://claude.ai), **or** an [Anthropic API key](https://console.anthropic.com/)

## Quick Start

```bash
# 1. Install Colima + Docker
just setup

# 2. Build the image
just build

# 3. Create a project
just create my-project                     # or: just create my-project /path/to/dir

# 4a. Subscription users: log in once per container
just login my-project

# 4b. API key users: set your key
cp .env.example .env
# Edit .env with your ANTHROPIC_API_KEY, then recreate the container

# 5. Start Claude
just claude my-project
```

## Tools Inside the Container

git, uv (Python), just, build-essential, Claude Code CLI.

## Recipes

| Recipe | Purpose |
|--------|---------|
| `just setup` | Install Colima + Docker CLI, start VM |
| `just build` | Build the container image |
| `just rebuild` | Build without cache |
| `just create <name> [path] [-- DOCKER_ARGS]` | Create container with bind-mounted project dir |
| `just start/stop/restart <name>` | Container lifecycle |
| `just login <name>` | Log in with Claude subscription (once per container) |
| `just shell <name>` | Open a bash shell (auto-starts) |
| `just claude <name> [prompt]` | Run Claude in YOLO mode (auto-starts) |
| `just claude-safe <name> [prompt]` | Run Claude with permission prompts |
| `just destroy <name>` | Remove container (project files kept) |
| `just list` | Show all claude containers |
| `just logs <name>` | Show container logs |
| `just stats` | Resource usage for all containers |
| `just colima-start/stop/status` | Manage the Colima VM |

## Extra Docker Options

Pass additional mounts, ports, or env vars when creating a container:

```bash
just create my-project /path/to/my-project -- -p 8080:8080 -e SECRET=val --mount type=bind,src=/data,dst=/data
```

## Using `ccr` From Anywhere

The `ccr` (Claude Container Runner) script lets you run any recipe from any directory without `cd`-ing into this repo. To set it up:

```bash
# Copy the script to somewhere on your PATH
cp ccr ~/bin/ccr    # or /usr/local/bin/ccr
chmod +x ~/bin/ccr
```

If you cloned this repo somewhere other than `~/projects/claude-container`, set the path:

```bash
# In your ~/.zshrc
export CLAUDE_CONTAINER_DIR="$HOME/path/to/claude-container"
```

Then use `ccr` instead of `just` from anywhere:

```bash
ccr build
ccr create my-project      # uses cwd as project path
ccr claude my-project
ccr list
ccr --recipes          # show all available recipes
```

## How It Works

- **Colima** provides the Docker runtime (free, uses Apple Virtualization.framework)
- Containers run `sleep infinity` and you `exec` into them
- `/workspace` inside the container is bind-mounted to the project directory you specify
- **Subscription auth:** `just login <name>` runs `claude login` inside the container (once per container)
- **API key auth:** the key flows from `.env` → just → `docker create -e ANTHROPIC_API_KEY`
- `just destroy` removes the container but project files stay on the host
