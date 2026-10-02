---
description: Add a Neovim feature to this home-manager flake (plugins, LSP, keybinds via Nix only).
---

Add this Neovim feature: $ARGUMENTS

Scope: `hm-modules/termTools/nixvim/` (`default.nix` only wires imports; `core.nix`
base, `keymaps.nix`, `autocmd.nix`, `ui`/`pickers`/`dev`/`lsp.nix` plugin groups,
`packages.nix` binaries, `runtime.nix` lua wiring, `helpers.nix` shared builders;
runtime Lua in `lua/`, init is generated).

Load these skills first: `nix-hm`, `add-hm-module`, `verify-hm-change`, `lua-shell`
(plus `sops-add-secret` if the feature needs a secret).

Hard rules:

- Everything strictly via Nix: nixvim plugin modules (or `extraPlugins` from
  `pkgs.vimPlugins` when no module exists), binaries in `extraPackages`.
  No mason.nvim, no LazyVim/lazy.nvim, nothing downloaded at runtime.
  Lazy-load heavy plugins through `plugins.lz-n` (`lazyLoad.settings`: keys/cmd/ft/event).
- Leader is space. Do not remap Vim defaults;
  plugin hotkeys stay as configured (`ms`/`md`/`mr`, `gc`) — do not remap them either.
- Secrets: never bake values into the repo; reference `config.sops.secrets.<name>.path` and read it at runtime.
- If the feature adds or changes keybinds, you MUST update `doc/nvim/binds.md` in the same change:
  read it first, add/update entries under the matching `##` category (or new category if needed),
  same style (`-` lists, `` `keys` — description ``, English, brief). No keybind change without doc update.

Verify before finishing: `nixfmt --check --width 120` on touched `.nix` files,
`just qa`, `just check` (both machines).
Never run `just hm` unless explicitly asked.
