---
name: add-hm-module
description: Use when adding or changing a home-manager module, fish function, yazi plugin/config, package set, or theme setting in this repo.
---

# How to edit this flake's modules

Layout: `hm-modules/default.nix` is the single wiring point; shared code lives in
`hm-modules/` grouped by area (`core/{nix,identity,packages,theme}`, `shell/{vcs,search,system}`,
`docs.nix`, `termTools/{fish,helix,nixvim-rei,yazi}`, `security/`, `wayland/`, `themes/`, `sound/`);
`machines/<name>/default.nix` is the machine delta. A new shared module must be
**added to the `imports` in `hm-modules/default.nix`**, otherwise it is not part of the build.

## Placement rules

- Shared across machines goes to `hm-modules/`. `machines/` holds only
  what truly differs (foot font size, `FLAKE_MACHINE`, extra packages).
- Guard a wrapper around an upstream HM option (`programs.<name>.*`) with
  `lib.mkIf config.programs.<name>.enable` — see the eza/helix/neovim blocks in
  `hm-modules/termTools/fish/default.nix`.
- Custom module arguments (`vars`, `inputs`, `yazi-plugins`) exist only because
  `flake.nix:61` injects them via `extraSpecialArgs`. A new global argument means
  editing `flake.nix`, not scope magic. User/machine constants belong to `nix/vars.nix`.

## Fish functions (`hm-modules/termTools/fish/default.nix`, plain `functions` map)

- Short ones go inline in the `functions` map; long ones get a separate
  `<name>_function.fish` + `builtins.readFile` (example: `gd`).
- Every body takes `$argv` explicitly — write it out, or arguments never arrive.
- `wraps` sets fish completions for the wrapped command; dotted names
  (`..`, `...`, ...) wrap `cd`.
- Name clashes with shell integrations break eval (two definitions of one attribute).
  Precedent: the custom `y` replaced `yazi.enableFishIntegration` (disabled in the
  same file), because the integration defined exactly the `y` function
  (`shellWrapperName`, `hm-modules/termTools/yazi/default.nix:35`).

## Yazi (`hm-modules/termTools/yazi/`)

- nixpkgs plugins via `inherit (pkgs.yaziPlugins) ...`; external ones are flake inputs
  with `flake = false` (flake.nix:20-25) passed through the `yazi-plugins` argument,
  with junk stripped by `nix/yazi-plugins.nix`. A new external plugin means:
  input + entry in `nix/yazi-plugins.nix` + `inherit (yazi-plugins) ...` in `plugins`.
- Plugins with `setup()` need a call in `initLua`; previewers/preloaders need entries
  in `prepend_previewers`/`prepend_preloaders` via `mkPreviewer`/`mkPreloader`.
- Keybinds live in `keymaps.nix`, not `default.nix`.
- `rip` completions are handwritten at `hm-modules/termTools/fish/completions_rip.fish`
  (flat `complete` lines, no `rip completions fish` helpers); never use `pkgs.runCommand` (IFD) in modules.

## Packages, unfree, theme

- Regular packages go to `hm-modules/core/packages.nix`, machine-specific ones to
  `machines/<name>`.
- A non-free package beyond `unrar`/`obsidian` means editing `nix/vars.nix:allowUnfree`
  while `allowUnfree = false` (see `nix/pkgs.nix`).
- The theme is global: catppuccin `mocha`, `autoEnable = true` (`hm-modules/core/theme.nix`).
  Do not hand-roll colors per app.
- Do not bump `stateVersion` (`nix/vars.nix`) without a migration.
  On a real NixOS host, turn off `targets.genericLinux.enable` (`hm-modules/core/identity.nix`).

## Verification

Follow the `verify-hm-change` skill: `just qa`, targeted `nix eval`, and for new
files move `main` onto `@` first, or eval will not see them.
