---
name: niri-machine-config
description: Use when editing niri compositor config — keybinds, layout, outputs, autostart, rules — in dotfiles/niri generic or per-machine files.
---

# Editing the niri config

The live config `~/.config/niri/config.kdl` is a **symlink** into
`dotfiles/niri/config_<FLAKE_MACHINE>.kdl`. Edit only repo files,
never `~/.config/niri` directly.

## Include order (later wins)

`dotfiles/niri/config_<machine>.kdl` (example: `config_tigerlake.kdl:1-15`):

1. `./generic/*.kdl` first — shared across machines.
2. `./<machine>/*.kdl` after — machine overrides.

New rule/bind: shared stuff goes to `generic/`, machine-specific to `<machine>/`
under the same file name. A new file must also be added to `config_<machine>.kdl` —
there are no globs, an un-included file is dead.

## The three mandatory symlinks

`scripts/setup_niri.sh` (checks all three exist, 22-29; backs the current config up
to `~/.config/niri.bak.<timestamp>`, 32-36) links:

- `config.kdl` → `config_<FLAKE_MACHINE>.kdl`
- `generic` → `dotfiles/niri/generic`
- `<FLAKE_MACHINE>` → `dotfiles/niri/<FLAKE_MACHINE>` (needed for relative includes)

Run: `export FLAKE_MACHINE=<name>; ./scripts/setup_niri.sh`.
Without the `<machine>/` link, relative `include "./<machine>/..."` lines break.

## Verification

```sh
niri validate        # same as what just qa runs
```

Changing outputs/monitors (`outputs.kdl`) without access to the hardware — only on
explicit request and marked "unverified on hardware".
