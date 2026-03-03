# Shell

Write POSIX sh from the start. Shebang is `#!/bin/sh` — no bashisms.

- **Builtins first**: Prefer shell builtins over external commands.
- **Minimize subprocesses**: Especially heavy ones like `python`, `ruby`, `perl`. Avoid useless `cat`, `echo | pipe`, and other anti-patterns.
- **POSIX utilities only**: No GNU-isms or non-portable flags.
- **Verify**: Must pass `shellcheck --norc -s sh`.
