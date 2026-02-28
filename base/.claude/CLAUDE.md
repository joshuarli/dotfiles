# CLI Tool Mandate

Always use these tools instead of their POSIX/legacy equivalents. No exceptions.

**Exception: for code exploration and navigation, roam supersedes rg/fd — see "Exploring Codebases" below.**

For detailed flags, patterns, and examples see `~/dev/tools/TOOLS.md`

## Substitution Rules

| Instead of | Use |
|---|---|
| `grep`, `grep -r` | `rg` (text/regex); `roam` (code navigation) |
| `find` | `fd` (files by name/path); `roam file` (code structure) |
| `ls`, `tree` | `eza` |
| `sed` | `sd` |
| `jq` | `jaq` |
| `curl`, `httpie` | `xh` |
| `ps`, `ps aux \| grep` | `procs` |
| `du`, `du -sh` | `dua` (never `dua i` — it deletes files) |

When an agent has built-in search/glob tools, prefer those for basic queries.
Use CLI `rg`/`fd` when piping, using `--json`, or needing advanced flags.

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

