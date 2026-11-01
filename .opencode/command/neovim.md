---
description: Add a Neovim feature in the local nixvim-rei module (plugins, LSP, keybinds via Nix only).
---

Add this Neovim feature: $ARGUMENTS

Scope: `hm-modules/termTools/nixvim-rei/` contains the full configuration;
`hm-modules/termTools/nixvim-rei.nix` imports NixVim and enables it.

Hard rules:

- Everything strictly via Nix: nixvim plugin modules (or `extraPlugins` from
  `pkgs.vimPlugins`), binaries in `extraPackages`. No mason.nvim, no lazy.nvim,
  nothing downloaded at runtime. Lazy-load heavy plugins via `plugins.lz-n`.
- Leader is space. Update `hm-modules/termTools/nixvim-rei/doc/binds.md` with
  every keybind change.
- Run `just qa` and `just check` for both machines. If startup-relevant Lua
  changed, also run `FLAKE_MACHINE=<machine> just nvim-smoke`.
- Never run `just hm` unless explicitly asked.
