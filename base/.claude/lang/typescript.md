# TypeScript

Target Node 24+. ESM only — no CommonJS, no `require()`.

- **`node:` prefix**: Always use `node:fs`, `node:path`, etc. No bare built-in imports.
- **Standard library first**: Use `node:` builtins before npm packages. `fetch` is global — no `node-fetch`.
- **Functions over classes**: Plain functions and objects. Classes only for genuine stateful abstractions.
- **No `any`, no `as` casts**: Use `unknown` and narrow with type guards. Treat `as` like Rust's `unsafe` — a last resort, not a convenience.
- **Discriminated unions**: Use a literal `type`/`kind` field to narrow, not `instanceof` chains.
- **`readonly` by default**: Prefer `Readonly<T>`, `readonly` arrays, and immutable data. Mutate only when there's a clear reason.
- **No enums**: Use `as const` objects or union types instead.
