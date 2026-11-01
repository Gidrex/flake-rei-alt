---
name: rtk
description: >-
  Use before running any non-interactive shell command from an AI coding agent:
  route it through the rtk token-saving proxy instead of the bare command.
  Fall back to the bare command only when rtk has no proxy for it.
---

# rtk — token-saving shell proxy

`rtk` wraps common CLIs and returns compact output (verified against
`rtk --help`, v0.50.0: subcommand first, the rest passes through untouched,
e.g. `rtk git status`, `rtk rg -n "pat" .`). Prefer the proxy form for every
non-interactive command that has one:

- repo: `rtk git ...`, `rtk diff`, `rtk gh ...`
- search/read: `rtk rg ...`, `rtk grep ...`, `rtk find ...`, `rtk ls`,
  `rtk tree`, `rtk read <file>`
- data: `rtk json ...`, `rtk log ...`
- runs: `rtk err <cmd>` (errors only), `rtk test ...`, `rtk pytest ...`,
  `rtk ruff ...`, `rtk mypy ...`, `rtk cargo ...`, `rtk go ...`,
  `rtk tsc ...`, `rtk docker ...`
- no dedicated proxy: `rtk summary <cmd>` or `<cmd> | rtk pipe`

Rules:

- Interactive commands (editors, `lazygit`, `yazi`, anything prompting)
  run bare — never through rtk.
- If the output looks wrong or truncated, rerun bare. A wrong answer
  costs more than the tokens saved.
- `rtk gain` shows the measured savings.
