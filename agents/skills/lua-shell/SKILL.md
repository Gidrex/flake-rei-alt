---
name: lua-shell
description: Use when writing, fixing, or reviewing Lua (Neovim config) or shell scripts, or handling stylua, shellcheck, shfmt failures.
---

# Lua / Shell dev cycle

## QA gates

```bash
stylua --check .     # Lua gate (write mode: stylua .)
shellcheck <script>  # shell lint gate
shfmt -d <script>    # shell format check (write mode: shfmt -w <script>)
```

Fish functions (`hm-modules/termTools/fish/*.fish`): syntax-check without nix first:

```bash
{ printf 'function y\n'; cat <file>; printf 'end\n'; } > /tmp/check.fish
fish -n /tmp/check.fish && echo FISH_SYNTAX_OK
```

## Rules

- Neovim Lua lives in `hm-modules/termTools/nixvim-rei/lua/`;
  its `.luarc.json` disables `undefined-global` — Neovim provides those globals, not a bug.
- Shell: `set -euo pipefail`, quoted paths, no bashisms in `sh` scripts.
