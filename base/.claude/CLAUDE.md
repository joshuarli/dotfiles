# Reference Library

A curated coding reference lives at **`~/d/library`**. Read the relevant files before writing code.

- **Before coding in any language**: read `~/d/library/languages/{lang}/style.md`
- **Before choosing a language**: read `~/d/library/languages/USAGE.md`
- **Before adding a dependency**: read `~/d/library/philosophy/dependencies.md`
- **For CLI tool usage** (search, git, processes, etc.): read `~/d/library/tools/`
- **Full index**: `~/d/library/INDEX.md`

Start with `~/d/library/WORKFLOW.md` — minimize output, fail fast, read before writing.

# Coding Style

Prefer the simplest correct solution. No premature abstraction, no unnecessary dependencies.
Vet every dependency before adding — fewer is always better.
Formatting and linting enforced by pre-commit hooks.

# CLI Tools

**When an agent has built-in search/glob tools, prefer those for basic queries.**

Use modern tools instead of POSIX equivalents. No exceptions. For detailed usage, see `~/d/library/tools/`.

| Instead of | Use |
|---|---|
| `grep` | `rg` |
| `find` | `fd` |
| `ls`, `tree` | `eza` |
| `sed` | `sd` |
| `jq` | `jaq` |
| `curl` | `xh` |
| `ps` | `procs` |
| `du` | `dua` (never `dua i`) |

# Committing

- All changes must pass pre-commit hooks. Never bypass with `--no-verify`.
- If a hook fails, fix the underlying issue — don't suppress it.
- Never push to a remote. No `git push`, no `--force`. Leave pushing to the user.
