---
name: typescript-biome
description: Use when writing, fixing, or reviewing TypeScript/JavaScript code, or handling Biome or tsc failures.
---

# TypeScript dev cycle (Biome + tsc)

## 0. Rule

Biome exclusively for format+lint. No ESLint/Prettier mixing.

## 1. Full cycle (every change)

```
1. Explore → read touched modules + types first
2. Implement → smallest change, explicit interfaces on boundaries
3. Fix loop → biome write, then tsc, then tests
4. Verify → both gates below green (+ tests if present)
```

## 2. QA gates (format+lint → typecheck → test)

```bash
biome check --write <paths>   # fix + format (during work)
biome check <paths>           # CI gate — must pass at end
tsc --noEmit                  # type gate — must pass at end
```

Repo test runner as configured (`npm test`, `bun test`, `vitest`, …).

## 3. Rules

- Zero `any`: prohibited. Use `unknown` + narrowing, discriminated unions, explicit interfaces.
- Never suppress with `biome-ignore` / `lint-ignore`. Write the type instead.
- DRY up duplicated logic into small domain modules. No placeholders, mock stubs,
  dummy URLs, or hardcoded test strings in final code.
- Config values: validate strictly at boot (`validateStrict()`), fail fast with a clear message.
