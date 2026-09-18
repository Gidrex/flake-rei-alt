---
name: add-machine
description: Use when adding a new machine (new homeConfigurations entry under machines/) with its niri setup to this flake.
---

# Adding a new machine

Machines are **NOT** auto-discovered from directories: they form an explicit `machines`
map in `flake.nix:48-51`, which `genAttrs` turns into `homeConfigurations`
(flake.nix:54). A new machine takes 4 steps.

## 1. `machines/<name>/default.nix`

Minimal template (compare with `machines/tigerlake/default.nix`):

```nix
{ pkgs, vars, ... }:
{
  # foot, fish and friends self-enable in hm-modules — only deltas here.
  programs.foot.settings.main.font = "GeistMonoNerdFontMono:size=${toString vars.footFontSize.<name>}";

  home.packages = with pkgs; [ ];

  home.sessionVariables.FLAKE_MACHINE = "<name>"; # must match the directory name
}
```

Shared stuff does not belong here — it goes to `hm-modules`
(see the `add-hm-module` skill). `stateVersion` is global (`nix/vars.nix`); foot font
sizes live in `nix/vars.nix:footFontSize` (add the new machine's size there).

## 2. Register in `flake.nix`

```nix
machines = {
  icelake = ./machines/icelake;
  tigerlake = ./machines/tigerlake;
  <name> = ./machines/<name>;
};
```

## 3. Niri for the machine (see the `niri-machine-config` skill)

- `dotfiles/niri/config_<name>.kdl` — copy the structure of `config_tigerlake.kdl`:
  `./generic/*` includes first, then `./<name>/*`.
- `dotfiles/niri/<name>/` — at minimum `outputs.kdl` for the machine's hardware (plus
  whatever is overridden: `input`, `layout`, `binds`, `rules`, `autostart`, `environment`).
- Apply: `export FLAKE_MACHINE=<name>; ./scripts/setup_niri.sh`.

## 4. Verification and docs

- `nix eval --impure ".#homeConfigurations.<name>.config.home.username"` (plus the
  full eval from the `verify-hm-change` skill).
- `niri validate` after linking.
- Update the machine lists: `README.md` ("Machines") and the niri section of `AGENTS.md`
  (currently `icelake` + `tigerlake` only).
