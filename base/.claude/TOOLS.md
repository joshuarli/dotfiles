# CLI Tools Reference

Detailed flags, patterns, and examples. See `CLAUDE.md` for substitution rules, defaults, and gotchas.

---

## rg — content search

| Flag | Purpose |
|---|---|
| `-t py` | Filter by file type (`--type-list` for all) |
| `-F` | Literal string, no regex |
| `-uuu` | Progressive: `-u` gitignored, `-uu` +hidden, `-uuu` +binary |
| `-U` | Multiline matching |
| `-g '!*.min.js'` | Glob filter with negation |
| `--json` | Structured output for piping to `jaq` |
| `--replace` | Preview replacements (does NOT write files) |

```bash
rg --json 'pattern' | jaq -r 'select(.type == "match") | .data.path.text'
rg 'foo(\d+)' --replace 'bar$1'        # preview only — pipe to sd to apply
rg -uuu 'API_KEY'                       # search ignored/vendor dirs
rg 'class User' -g '!tests/**' -g '*.py'
```

---

## fd — find files

| Flag | Purpose |
|---|---|
| `-e rs` | Filter by extension |
| `-t d` / `-t f` | Directories / files only |
| `-x CMD {}` | Execute per result (parallel) |
| `-X CMD {}` | Execute once with all results as args (like `xargs`) |
| `-HI` | Include hidden + gitignored |
| `--changed-within 1h` | Time-based filtering |
| `-g` | Glob mode instead of regex |

Placeholders for `-x`/`-X`: `{}` path, `{.}` no ext, `{/}` basename, `{//}` parent, `{/.}` basename no ext.

```bash
fd -e json -X prettier --write {}
fd -e ts -X sd 'OldName' 'NewName'
fd --changed-within 1h
```

---

## eza — list files & tree view

```bash
eza --tree --level=3 --git-ignore              # project structure
eza --tree --level=2 --git-ignore -l --no-user --no-time --no-permissions  # with sizes
eza --tree --git-ignore -I '*.pyc|__pycache__' # custom exclusions
eza -l --sort=modified --reverse               # by modification time
```

---

## sd — find and replace

Syntax: `sd 'PATTERN' 'REPLACEMENT' [FILES...]` — no delimiters, global by default, in-place by default.

| Flag | Purpose |
|---|---|
| `-F` | Literal string, no regex |
| `-p` | Preview / dry run |
| `-A` | Multiline matching |

```bash
sd 'fn (\w+)\(' 'fn ${1}_v2(' src/*.rs     # capture groups use $1 not \1
fd -e ts -X sd 'OldComponent' 'NewComponent' # bulk rename across codebase
sd -p 'foo' 'bar' config.yaml               # preview first
```

---

## jaq — JSON processing

Nearly identical to `jq` — most filters work unchanged.

```bash
jaq '.[] | select(.status == "active")' users.json
jaq '{name: .metadata.name, ns: .metadata.namespace}' resource.yaml
cat *.json | jaq -s '.'                     # slurp into array
jaq -n '{name: "test", version: "1.0"}'     # build from scratch
jaq --fmt yaml '.' config.yaml              # YAML input
if jaq -e '.enabled' config.json; then ...  # exit code on truthiness
```

---

## yq — YAML processing

This is [mikefarah/yq](https://github.com/mikefarah/yq) (Go). Preserves comments and formatting on in-place (`-i`) edits.

```bash
yq '.metadata.name' deployment.yaml
yq -i '.spec.replicas = 3' deployment.yaml
yq -i 'del(.metadata.annotations)' resource.yaml
yq -o json deployment.yaml                  # YAML → JSON
yq -p json -o yaml config.json              # JSON → YAML
yq ea 'select(.kind == "Deployment")' manifests.yaml  # multi-doc
yq ea '. as $item ireduce ({}; . * $item)' base.yaml override.yaml  # merge
MY_TAG=v1.2.3 yq -i '.image.tag = strenv(MY_TAG)' values.yaml
```

`eval-all` (`ea`) processes all documents as a single stream — required for multi-doc files and merges.

---

## sg — structural code search & rewrite

AST-based. Use over `rg` when you need structural precision — skips comments/strings, ignores formatting.

Language (`-l`) is **required**, no auto-detection. Binary may be `ast-grep` or `sg` depending on install.

| Metavariable | Matches |
|---|---|
| `$NAME` | Single AST node (identifier, expression) |
| `$$$NAME` | Zero or more nodes (variadic — args, statement bodies) |

```bash
# Search
sg -p 'console.log($$$ARGS)' -l js
sg -p 'const [$STATE, $SETTER] = useState($INIT)' -l tsx
sg -p 'import $X from $Y' -l js --json | jaq '...'

# Rewrite (-r pattern, -i to apply)
sg -p 'var $X = $Y' -r 'let $X = $Y' -l js -i
sg -p '$A && $A()' -r '$A?.()' -l ts -i
sg -p 'print($$$ARGS)' -r 'logger.info($$$ARGS)' -l py -i
```

For complex refactors, use YAML rule files with `sg scan`.

---

## xh — HTTP requests

Value syntax: `key=string`, `key:=raw_json`, `key==query_param`, `key:header`. Method inferred: body → POST, no body → GET.

```bash
xh get api.example.com/users id==5 sort==true
xh api.example.com/data name=test count:=42  # POST inferred
xh get api.example.com x-api-key:secret      # header
xh -b get api.example.com/users | jaq '.[0]' # body only (for piping)
xh -h api.example.com/health                 # headers only (status check)
xh -f post api.example.com field=value       # form data
xh -d api.example.com/file -o output.bin     # download
```

`xhs` is shorthand for `xh --https`.

---

## watchexec — watch & re-run

Respects `.gitignore` automatically. Changed paths available via `$WATCHEXEC_COMMON_PATH`, `$WATCHEXEC_WRITTEN_PATH`.

```bash
watchexec -e rs,toml -- cargo build
watchexec -r -e py -- python server.py       # -r kills previous process
watchexec -w src/ -e rs -- cargo test        # watch specific dir
watchexec --debounce 300 -e go -- go test ./...
watchexec -i '*.log' -i 'tmp/**' -e rb -- bundle exec rspec
```

---

## git — version control patterns

**Searching history:**

```bash
git log -S 'functionName' --oneline          # pickaxe: when was string added/removed
git log -G 'def\s+process_' --oneline        # regex variant
git log --grep='fix.*auth' --oneline -i      # search commit messages
git log --oneline --follow -- src/file.py    # history through renames
git blame --ignore-revs-file .git-blame-ignore-revs src/main.rs
```

**Understanding changes:**

```bash
git diff --stat                              # compact summary
git diff main...HEAD                         # PR contents (three dots = since fork)
git diff --name-only main...HEAD             # just filenames
git diff --word-diff                         # word-level (prose/config)
git diff --cached                            # staged only
git log -3 -p --stat                         # last 3 commits with diffs
```

**Undoing and recovering:**

```bash
git reset --soft HEAD~1                      # undo commit, keep staged
git reflog                                   # find lost commits (90 day retention)
git checkout -b recovered abc1234            # recover from reflog
git restore --source=main -- src/config.yaml # file from another branch
git add -p                                   # stage hunks interactively
git stash push -m "wip: auth refactor"       # named stash
```

Recommended config: `merge.conflictstyle=zdiff3`, `branch.sort=-committerdate`, `rebase.autoStash=true`.

---

## procs — process inspection

```bash
procs node                                   # keyword search (cmd, args, user, PID)
procs --tree                                 # parent-child hierarchy
procs --sortd cpu                            # sort by CPU desc
procs --sortd mem                            # sort by memory desc
```

---

## dua — disk usage

Parallel scanning, sorted by size (largest first).

```bash
dua                                          # scan current directory
dua src/ node_modules/ target/               # scan specific paths
```

---

## Escape Hatches

POSIX tools for unstructured tabular text without `--json`. If the source supports `--json`, prefer that + `jaq`.

| Tool | When | Example |
|---|---|---|
| `awk` | Column extraction, arithmetic, aggregation | `awk '{sum += $1} END {print sum}'` |
| `cut` | Fixed-delimiter column slicing | `cut -d: -f1,3 /etc/passwd` |
| `sort` + `uniq` | Sort, dedup, count | `sort log \| uniq -c \| sort -rn` |
| `head`/`tail` | First/last N lines, follow streams | `tail -f /var/log/app.log` |
| `wc` | Count lines, words, bytes | `wc -l *.py` |
| `tee` | Split output to stdout + file | `make 2>&1 \| tee build.log` |
