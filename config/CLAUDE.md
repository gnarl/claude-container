# Container Environment

You are running inside an isolated Docker container (ubuntu:24.04). You have full root-equivalent access via passwordless sudo.

## Directory Layout

- `/workspace` — **Persistent project files** (bind-mounted from the host). All work should happen here.
- `/home/coder` — Your home directory. Ephemeral — lost when the container is destroyed.

## Available Tools

| Tool | Version/Notes |
|------|---------------|
| git | System package |
| python3 + uv | Use `uv` for Python package/project management |
| just | Command runner |
| build-essential | gcc, g++, make, etc. |
| claude | Claude Code CLI |

## Installing Extra Packages

```bash
# System packages
sudo apt-get update && sudo apt-get install -y <package>

# Python packages (prefer uv)
uv pip install <package>

```

## Tips

- The container is yours to break. Install anything, change any config.
- If something goes wrong, the host can destroy and recreate the container without losing `/workspace` files.
- Authentication is handled either via `claude login` (subscription) or the `ANTHROPIC_API_KEY` environment variable (API key).
