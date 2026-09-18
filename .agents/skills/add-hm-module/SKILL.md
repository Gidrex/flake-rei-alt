---
name: add-hm-module
description: Use when adding or changing a home-manager module, fish function, yazi plugin/config, package set, or theme setting in this repo.
---

# How to edit this flake's modules

Layout: `home.nix` is the shared base (programs, packages, theme, session vars);
`hm-modules/` holds modules by area (`termTools/{fish,helix,neovim,yazi}`, `security/`,
`wayland/`, `themes/`, `sound/`); `machines/<name>/default.nix` is the machine delta.
A new module must be **wired into `flake.nix:65-95`** (`commonModules`), otherwise it
is not part of the build.

## Placement rules

- Shared across machines goes to `home.nix` / `hm-modules/`. `machines/` holds only
  what truly differs (packages, fonts, `FLAKE_MACHINE`).
- Guard a wrapper around an upstream HM option (`programs.<name>.*`) with
  `lib.mkIf config.programs.<name>.enable` — see the eza/helix/neovim blocks in
  `hm-modules/termTools/fish/default.nix:57-82`.
- Custom module arguments (`yazi-plugins` etc.) exist only because `flake.nix:94`
  injects them via `_module.args` (values from `moduleArgs`, flake.nix:53-62).
  A new global argument means editing `flake.nix`, not scope magic.

## Fish functions (`hm-modules/termTools/fish/default.nix:13-28`, the `mkFunc` mapper)

- Short ones go inline in the `functions` map; long ones get a separate
  `<name>_function.fish` + `builtins.readFile` (examples: `gd`, `y`).
- If the body contains no `$argv`, the mapper **auto-appends ` $argv`**. Keep that
  in mind, or arguments arrive twice.
- `mkFuncWrap "<cmd>" "<body>"` sets `wraps`; dotted names (`..`, `...`)
  automatically get `wraps = "cd"`.
- Name clashes with shell integrations break eval (two definitions of one attribute).
  Precedent: the custom `y` replaced `yazi.enableFishIntegration` (disabled in the
  same file), because the integration defined exactly the `y` function
  (`shellWrapperName`, `hm-modules/termTools/yazi/default.nix:34`).

## Yazi (`hm-modules/termTools/yazi/`)

- nixpkgs plugins via `inherit (pkgs.yaziPlugins) ...`; external ones are flake inputs
  with `flake = false` (flake.nix:17-21) passed through the `yazi-plugins` argument,
  with junk stripped by `cleanPlugin` (flake.nix:28-50). A new external plugin means:
  input + entry in `moduleArgs.yazi-plugins` + `inherit (yazi-plugins) ...` in `plugins`.
- Plugins with `setup()` need a call in `initLua`; previewers/preloaders need entries
  in `prepend_previewers`/`prepend_preloaders` via `mkPreviewer`/`mkPreloader`.
- Keybinds live in `keymaps.nix`, not `default.nix`.

## Packages, unfree, theme

- Regular packages go to `home.packages` (`home.nix:194`), machine-specific ones to
  `machines/<name>`.
- A non-free package beyond `unrar`/`obsidian` means editing `allowUnfreePredicate`
  (flake.nix:100-108) while `allowUnfree = false`.
- The theme is global: catppuccin `mocha`, `autoEnable = true` (home.nix:179-189).
  Do not hand-roll colors per app.
- Do not bump `home.stateVersion = "26.05"` (home.nix:302) without a migration.
  On a real NixOS host, turn off `targets.genericLinux.enable` (home.nix:320).

## Verification

Follow the `verify-hm-change` skill: `just qa`, targeted `nix eval`, and for new
files move `main` onto `@` first, or eval will not see them.
