---
name: rust-cargo
description: Use when writing, fixing, or reviewing Rust code or Cargo.toml, or handling rustfmt, clippy, cargo test/nextest failures.
---

# Rust dev cycle (cargo fmt + clippy + test)

Distilled from community templates (opencode-agent-kit `rust-patterns`, oh-my-opencode
`cargo-strict`, terraphim `rust-development`, Apollo `rust-best-practices`).

## 1. Full cycle (every change)

```
1. Explore → read touched crate + existing tests first
2. Implement → smallest change, narrowest pub surface
3. Fix loop → fmt, then clippy deny-warnings, then tests
4. Verify → gate below green, in order
```

## 2. QA gate (single chain, in this order)

```bash
cargo fmt --all -- --check                                  # format gate
cargo clippy --all-targets --all-features -- -D warnings    # lint gate
cargo test                                                  # test gate (or: cargo nextest run)
```

With `unsafe` involved, additionally: `cargo +nightly miri nextest run`.
Supply-chain on demand: `cargo audit`, `cargo deny check`.

## 3. Rules

- Correctness → safety → idioms → zero-cost. Prove it runs before optimizing.
- Errors: `Result<T, E>` + `?` everywhere fallible. `thiserror` for libraries,
  `anyhow` (+ `.context()`) for binaries. No `panic!`/`unwrap()`/`expect()` outside tests.
- Borrowing: `&str` over `String`, `&[T]` over `Vec<T>` in params; `Cow` when ambiguous.
- Types: enums + exhaustive `match` (no `_ =>` on owned enums), newtypes for distinct units,
  `#[must_use]` on value-returning fns, rustdoc on all `pub` items.
- Lint suppressions need a `// Justified:` comment; without a good reason, fix instead.
  Never `#![deny(warnings)]` in source — warnings-as-errors belongs in the CLI flag/CI.
- Fast check during work: `cargo check` (no codegen) before full `cargo test`.
