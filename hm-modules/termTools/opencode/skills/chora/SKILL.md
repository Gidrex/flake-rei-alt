---
name: chora
description: >-
  Use when working with markdown notes or day events: load the live chora
  reference first, then use only its non-interactive commands.
---

# chora — notes and day events

`chora` is a local CLI organizer (markdown notes + day events, git-synced).
Its usage evolves with the binary, so never rely on memory: load the live
reference at session start when notes or events are needed:

```sh
chora skill
```

Follow that output exactly. Load-bearing rules:

- Non-interactive commands only (`note add/override/show/headers`,
  `event --title ...`, `event show`, `index`). Never `open`, `calendar`,
  `settings`, `init`, bare `event`, or `--confirm`.
- `index.md` is human-owned; agents never write it.
- Note bodies go via stdin pipe, e.g.
  `printf '# T\n' | chora note override <DIR> --path <FILE>`.
- Default clearance is `restricted`; pass `--max-access` only to narrow it.
