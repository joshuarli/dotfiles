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

## Shell

Write POSIX sh from the start. Shebang is `#!/bin/sh` — no bashisms.

- **Builtins first**: Prefer shell builtins over external commands.
- **Minimize subprocesses**: Especially heavy ones like `python`, `ruby`, `perl`. Avoid useless `cat`, `echo | pipe`, and other anti-patterns.
- **POSIX utilities only**: No GNU-isms or non-portable flags.
- **Verify**: Must pass `shellcheck --norc -s sh`.

## Python

Write plain, direct Python. Functions over classes unless state is genuinely needed.

- **Standard library first**: Don't reach for a dependency when `os`, `pathlib`, `itertools`, or `collections` already suffices.
- **Type hints**: Annotate function signatures. Use built-in generics (`list[str]`, `dict[str, int]`) over `typing` imports.
- **No class ceremony**: A module with functions is fine. Use a class only for encapsulated mutable state or a protocol.
- **Comprehensions over map/filter**: Avoid `lambda` outside of trivial `key=` arguments.
- **Explicit errors**: No bare `except:`. Catch specific exceptions. Let unexpected errors propagate.

## TypeScript

Target Node 24+. ESM only — no CommonJS, no `require()`.

- **`node:` prefix**: Always use `node:fs`, `node:path`, etc. No bare built-in imports.
- **Standard library first**: Use `node:` builtins before npm packages. `fetch` is global — no `node-fetch`.
- **Functions over classes**: Plain functions and objects. Classes only for genuine stateful abstractions.
- **No `any`, no `as` casts**: Use `unknown` and narrow with type guards. Treat `as` like Rust's `unsafe` — a last resort, not a convenience.
- **Discriminated unions**: Use a literal `type`/`kind` field to narrow, not `instanceof` chains.
- **`readonly` by default**: Prefer `Readonly<T>`, `readonly` arrays, and immutable data. Mutate only when there's a clear reason.
- **No enums**: Use `as const` objects or union types instead.

## Rust

Write lean, idiomatic Rust. Prefer the simplest solution that works.

- **Ownership**: Accept borrows (`&str`, `&[T]`, `&Path`) unless you need ownership. Avoid gratuitous `.clone()`.
- **Iterators over loops**: Prefer iterator chains over manual `for`/`while` with mutable accumulators.
- **Enums over trait objects**: Use enums for closed sets of variants. Reserve `dyn Trait` for genuine runtime polymorphism.
- **No premature abstraction**: A concrete function beats a generic one unless genericity is exercised by multiple callers today.
- **Error handling**: Use `anyhow` in binaries, typed errors in libraries. No `.unwrap()` on fallible paths — `?` or `expect("reason")`.
- **Minimize allocations**: Reuse buffers, prefer `&str`/`Cow` over `String`, stack arrays or `SmallVec` over `Vec` for small fixed-size collections.
- **Lifetimes**: Don't annotate when elision works. If a signature needs 3+ lifetime params, rethink the design.
- **Unsafe**: Only with a `// SAFETY:` comment explaining the invariant. Prefer safe abstractions from well-known crates.

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
