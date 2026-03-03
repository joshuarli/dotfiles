# Coding Style

Prefer the simplest correct solution. No premature abstraction, no unnecessary dependencies.
Vet every dependency before adding — fewer is always better.
Formatting and linting enforced by pre-commit hooks.

## Testing

Test behavior at boundaries, not implementation details.

- **Integration over unit**: Prefer tests that exercise real codepaths end-to-end. Don't test getters, trivial delegation, or code that just reshuffles data. If removing a test wouldn't reduce confidence, remove it.
- **Isolation**: Each test owns its state. No shared mutable fixtures, no dependency on execution order. Tests must pass alone and in any order.
- **Parallelizable by default**: No global state, no fixed ports, no shared temp dirs without unique names. Design every test to run concurrently.
- **Test the contract**: Assert on outputs and observable side effects, not on which internal methods were called. Mock only at system boundaries (network, filesystem, clock).

## Language Rules

See `~/.claude/lang/{shell,python,typescript,rust}.md`

# CLI Tool Mandate

**When an agent has built-in search/glob tools, prefer those for basic queries.**

Always use these tools instead of their POSIX/legacy equivalents. No exceptions.

For detailed flags, patterns, and examples see `~/.claude/TOOLS.md`.

## Substitution Rules

| Instead of | Use |
|---|---|
| `grep`, `grep -r` | `rg` |
| `find` | `fd` |
| `ls`, `tree` | `eza` |
| `sed` | `sd` |
| `jq` | `jaq` |
| `curl`, `httpie` | `xh` |
| `ps`, `ps aux \| grep` | `procs` |
| `du`, `du -sh` | `dua` (never `dua i` — it deletes files) |

## Defaults

Apply to every invocation: `--color=never` (or `NO_COLOR=1`), `--` before positional args, quote all patterns.

| Tool | Default flags |
|---|---|
| `rg` | `--color=never --no-heading --line-number` |
| `fd` | `--color=never` |
| `eza` | `--no-user --no-time --no-permissions --color=never` |
| `jaq` | `-r` (raw output) |
| `yq` | `--no-colors` |
| `sg` | `--color=never --lang LANG` (`-l` is required) |
| `xh` | `--style=plain` |
| `procs` | `--color=never` |

## Gotchas

These will silently bite you if you forget them:

- **sd**: Capture groups are `$1`, `${name}` — NOT `\1`. Escape literal `$` with `$$`. In-place is the default (no `-i` flag).
- **sd**: `rg --replace` is preview-only — pipe to `sd` for actual writes. Bulk: `fd -e ext -X sd 'old' 'new'`.
- **jaq**: Not 100% jq-compatible. `limit`, `first`, `last`, `@format` may differ.
- **yq**: This is mikefarah/yq (Go). NOT kislyuk/yq (Python). They are not interchangeable.
- **sg**: `-l LANG` is required — no auto-detection. `$X` = one node, `$$$X` = variadic (args, bodies).
- **xh**: Value types by punctuation: `key=string`, `key:=json`, `key==query`, `key:header`. Method inferred from body presence.
- **git diff**: `main...HEAD` (three dots) = since fork. `main..HEAD` (two dots) includes main's changes — usually wrong.
- **git log -S**: Searches diffs not file content. Use for "when was this introduced?" not "where is this now?"
- **dua**: NEVER use `dua i` or `dua interactive`. It can delete files. Non-interactive only.
- **watchexec**: `-r` (restart) is essential for servers — without it, processes stack on every change.
- **eza**: `--git-ignore` is the key flag — respects `.gitignore` unlike `tree`.

# Committing

- All changes must pass pre-commit hooks. Never bypass with `--no-verify`.
- If a hook fails, fix the underlying issue — don't suppress it.
- Never push to a remote. No `git push`, no `--force`. Leave pushing to the user.
