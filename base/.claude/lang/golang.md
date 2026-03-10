# Go

Write straightforward Go. Accept the language's conventions — don't fight them.

- **Standard library first**: `net/http`, `html/template`, `log/slog`, `crypto/*`, `database/sql`, `encoding/json`. A new dependency needs a strong reason.
- **Errors are values**: Return `error`, check it immediately. No `panic` for recoverable situations. Wrap with `fmt.Errorf("context: %w", err)` to build a trace.
- **Interfaces at the consumer**: Define small interfaces where they're used, not where they're implemented. Accept interfaces, return structs.
- **No premature interfaces**: A concrete type is fine until a second implementation exists. `*sql.DB` is not shameful.
- **Structs over maps**: If the shape is known, use a struct. `map[string]any` is a code smell outside of JSON handling.
- **Context plumbing**: Pass `context.Context` as the first parameter. Never store it in a struct.
- **Table-driven tests**: Use `[]struct{ name string; ... }` with `t.Run`. Every test case gets a name.
- **`t.Parallel()`**: Call it in every test and subtest unless there's a documented reason not to.
- **No `init()`**: Wire dependencies explicitly in `main`. Global mutable state is a bug waiting to happen.
- **Embed over external files**: Use `//go:embed` for migrations, templates, and static assets. Keep binaries self-contained.
- **`internal/` by default**: Unless you're building a library for external consumption, keep packages in `internal/`.
