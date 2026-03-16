---
name: commit
description: Commit staged and unstaged changes efficiently
disable-model-invocation: true
---

You already know what you changed. Do NOT run git status, git diff, or git log to "discover" changes — you have full context from this conversation.

Commit in a single tool call:

1. Stage the specific files you modified (never `git add -A` or `git add .`)
2. Write a concise commit message: one line summarizing the *why*, not the *what*
3. End with the co-authored-by trailer

```bash
git add file1 file2 ... && git commit -m "$(cat <<'EOF'
message here
EOF
)"
```

If `$ARGUMENTS` is provided, use it as the commit message (still add the trailer).

Rules:
- One bash call. Not three. Not five.
- Never `--no-verify`. If hooks fail, fix the issue and commit again.
- Never push. Leave that to the user.
- If there's nothing to commit, say so. Don't run commands to confirm.
