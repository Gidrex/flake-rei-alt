---
description: Add a Neovim feature to this home-manager flake (plugins, LSP, keybinds via Nix only).
---

Add this Neovim feature: $ARGUMENTS

Scope: `hm-modules/termTools/neovim/` (`default.nix` + `lua/init.lua`, `lua/keys.lua`, `lua/lsp.lua`).
Read those files plus `hm-modules/termTools/helix/` (feature parity reference) before editing.

Load these skills first: `nix-hm`, `add-hm-module`, `verify-hm-change`, `lua-shell`
(plus `sops-add-secret` if the feature needs a secret).

Hard rules:

- Everything strictly via Nix: plugins go to `programs.neovim.plugins` (`pkgs.vimPlugins`),
  binaries to `programs.neovim.extraPackages`. No mason.nvim, no lazy.nvim, nothing downloaded at runtime.
- Leader is space. Do not remap Vim defaults;
  plugin hotkeys stay as configured (`ms`/`md`/`mr`, `gc`) — do not remap them either.
- Secrets: never bake values into the repo; reference `config.sops.secrets.<name>.path` and read it at runtime.
- If the feature adds or changes keybinds, you MUST update `doc/nvim/binds.md` in the same change:
  read it first, add/update entries under the matching `##` category (or new category if needed),
  same style (`-` lists, `` `keys` — description ``, English, brief). No keybind change without doc update.

Verify before finishing: `nixfmt --check --width 120` on touched `.nix` files,
`luac -p` on touched `.lua` files, `FLAKE_MACHINE=<machine> just nvim-smoke`
(headless startup test, catches E-codes like E5113), `just qa`, `just check` (both machines).
Never run `just hm` unless explicitly asked.
