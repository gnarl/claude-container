# Known Issues

## 1. No container upgrade workflow

**Status:** Open

When the Docker image is rebuilt (`just build`), existing containers continue running the old image. There is no recipe to update all containers to the latest image. Users must manually `just destroy <name>` + `just create <name>` for each container, which also loses any login state for subscription users.

A `just upgrade` recipe (or similar) could automate this, but has edge cases to consider: running containers, login state, multiple containers, etc. Should be addressed as a separate brainstorm.

---

## 2. `ccr` usage help is incomplete

**Status:** Open

The `ccr` script's usage text (lines 20-33 of `ccr`) lists a subset of available recipes. The following Justfile recipes are missing from the help output:

| Missing recipe | Notes |
|---|---|
| `rebuild` | Build without cache |
| `start` | Start a stopped container |
| `restart` | Restart a container |
| `logs` | Show container logs |
| `colima-start` | Start the Colima VM |
| `colima-stop` | Stop the Colima VM |
| `colima-status` | Show Colima VM status |
| `test` | Verify rtk is installed and configured |

Note: `ccr --recipes` already shows all recipes via `just --list`, so this is a cosmetic gap in the inline help text only.

---

## 3. `getting-started.md` references non-existent recipes

**Status:** Open

The recipes table in `docs/getting-started.md` (lines 635-636) references two recipes that do not exist in the Justfile:

- `just cp-to <name> <src> <dest>`
- `just cp-from <name> <src> <dest>`

These appear to be leftover from the upstream fork ([paulgp/claude-container](https://github.com/paulgp/claude-container)). They should either be implemented in the Justfile or removed from the docs.
