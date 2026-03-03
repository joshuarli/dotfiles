# Rust

Write lean, idiomatic Rust. Prefer the simplest solution that works.

- **Ownership**: Accept borrows (`&str`, `&[T]`, `&Path`) unless you need ownership. Avoid gratuitous `.clone()`.
- **Iterators over loops**: Prefer iterator chains over manual `for`/`while` with mutable accumulators.
- **Enums over trait objects**: Use enums for closed sets of variants. Reserve `dyn Trait` for genuine runtime polymorphism.
- **No premature abstraction**: A concrete function beats a generic one unless genericity is exercised by multiple callers today.
- **Error handling**: Use `anyhow` in binaries, typed errors in libraries. No `.unwrap()` on fallible paths — `?` or `expect("reason")`.
- **Minimize allocations**: Reuse buffers, prefer `&str`/`Cow` over `String`, stack arrays or `SmallVec` over `Vec` for small fixed-size collections.
- **Lifetimes**: Don't annotate when elision works. If a signature needs 3+ lifetime params, rethink the design.
- **Unsafe**: Only with a `// SAFETY:` comment explaining the invariant. Prefer safe abstractions from well-known crates.
