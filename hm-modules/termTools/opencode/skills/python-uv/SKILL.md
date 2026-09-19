---
name: python-uv
description: Use when writing, fixing, or reviewing Python code, managing deps with uv, or handling ruff, ty/mypy, pytest failures.
---

# Python dev cycle (uv + Ruff + ty + pytest)

## 0. Setup (once per project)

```bash
uv sync              # create .venv + install locked deps
uv add <package>     # add dep (never pip install outside uv)
```

Ruff + ty are the default pair (Astral). If repo pins `mypy`/`pyright`, use that instead of `ty`.

## 1. Full cycle (every change)

```
1. Explore → read touched modules + existing tests first
2. Implement → smallest change, explicit annotations on boundaries
3. Fix loop → ruff fix + format, then typecheck, then tests
4. Verify → all four gates below green, in order
```

## 2. QA gates (format → lint → typecheck → test, in this order)

```bash
uv run ruff check --fix .     # lint fix (during work)
uv run ruff format .          # format write (during work)
uv run ruff check .           # CI lint gate — must pass
uv run ruff format --check .  # CI format gate — must pass
uv run ty check               # type gate (or repo's mypy/pyright config)
uv run pytest                 # test gate
```

Fix all issues, never suppress (`type: ignore`, `noqa`) except a pre-approved repo
exception with justification comment.

## 3. Rules

- Run everything via `uv run` / `uvx` (`uv run pytest`, `uv run python -m ...`). Bare `pytest`/`python` = wrong env.
- Zero `Any`: `TypedDict`/`dataclass`/`pydantic` on boundaries, `Unknown`-style narrowing inside.
- No `TODO`/`FIXME`, placeholders, mock stubs, hardcoded secrets in final code.
- New behavior needs a test; bugfix needs a reproducing test first.
