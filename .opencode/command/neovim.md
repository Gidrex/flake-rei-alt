---
description: Add a Neovim feature via the standalone nixvim-rei flake (plugins, LSP, keybinds via Nix only).
---

Add this Neovim feature: $ARGUMENTS

Scope: the Neovim config no longer lives here. It is the standalone flake at
`/home/gidrex/Projects/nixvim-rei` (`modules/`; keybind docs in `doc/binds.md`;
own `.opencode/command/neovim.md` with the full rules). This repo only enables it:
`hm-modules/termTools/nixvim-rei.nix` (`programs.nixvim-rei.enable = true`).

Work in `/home/gidrex/Projects/nixvim-rei` following its neovim command
(hard rules, `doc/binds.md` update, `just qa` / `just check` / `just nvim-smoke` there).
Then return here and verify the wiring still holds: `just qa`, `just check`
(both machines). If the feature changes startup-relevant Lua:
`FLAKE_MACHINE=<machine> just nvim-smoke` here too (integration check).
Never run `just hm` unless explicitly asked.
