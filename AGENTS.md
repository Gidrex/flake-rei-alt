# AGENTS.md

Personal Nix **home-manager dotfiles/config flake** (not an app/library — no build or test suite).
Everything is applied to the host, so treat edits as config changes to a live system.

Agent steering (how to task the agent + skills): `.agents/README.md`.

## Critical gotchas (easy to get wrong)

- **VCS is Jujutsu (`jj`) colocated on git.** Commit with `jj`, not raw `git` (git is only the backend).
  `trunk()` = `main@origin`. Git remote is **Codeberg** (`git@codeberg.org:Gidrex/flake-rei.git`);
  the GitLab URL in `README.md` is stale.
- **Nix reads the committed `main` revision, not your working tree.** `nix flake metadata ./` resolves to
  `git+file://...?ref=refs/heads/main&rev=<sha>`, so uncommitted edits are invisible to `nix`/`home-manager`
  unless you commit them or pass `--impure` (`just check` uses `--impure`; `just hm` does not).
- **`FLAKE_MACHINE` env var is required** by `just hm` (values: `icelake` or `tigerlake`).
  The Nix modules set it per-machine too (`home.sessionVariables.FLAKE_MACHINE`).

## Commands

- Format Nix files (width 120): `just fmt`; check only: `just fmt-check`
- QA = format check + `niri validate`: `just qa`
- Dry-run eval (no system changes), one or all machines: `just check [machine]`
- Regenerate checked-in completions: `just update-completions`
- Apply home-manager (new generation, backup previous): `just hm` (needs `FLAKE_MACHINE`)
- There is no `devShell`/`packages` output and no test runner; only `homeConfigurations.<machine>` exists, so
  `nix flake check` is not the meaningful verification — `just qa` then `just check` is.
- `nixpkgs` tracks the `nixos-unstable` branch (`flake.nix:7`); update deliberately via
  `nix flake update nixpkgs` — it rebuilds the world on next `just hm`.

## Structure

- `flake.nix` → slim outputs: `nix/vars.nix` (user/keys/theme constants) + `nix/pkgs.nix`
  (locked nixpkgs instantiation) + `nix/yazi-plugins.nix` (cleaned external plugins) compose
  `commonModules` (`hm-modules/` + sops-nix + catppuccin + nixvim-rei) with `machines/<name>/default.nix`.
  Machines are an **explicit map** (`flake.nix:48-51`) that `genAttrs` turns into `homeConfigurations`
  (flake.nix:54) — adding a machine needs a flake edit, see `.agents/skills/add-machine/`.
- `hm-modules/default.nix` = single wiring point for shared modules (add new modules there, not in `flake.nix`).
- `hm-modules/` grouped by area: `core/{nix,identity,packages,theme}`, `shell/{vcs,search,system}`,
  `docs.nix`, `termTools/{fish,helix,nixvim-rei,yazi}`, `security/`, `wayland/`, `themes/`, `sound/`.
- Modules get `vars`, `inputs`, `yazi-plugins`, `machineName` via `extraSpecialArgs` in `flake.nix` — declare them
  as function args where needed (e.g. yazi plugins); no `_module.args` magic.
- Machine deltas are minimal and self-contained: per-machine foot font size,
  `FLAKE_MACHINE` (from `machineName`), extra packages. Terminals etc. self-enable in `hm-modules/`.
- Adding a machine also needs a niri setup (below).

## Niri (only for `icelake` + `tigerlake`)

- `~/.config/niri/config.kdl` is a **symlink** to `dotfiles/niri/config_<FLAKE_MACHINE>.kdl`, which `include`s
  `./generic/*.kdl` then `./<machine>/*.kdl`. The `generic/` and `<machine>/` dirs must be symlinked in too
  (relative includes break otherwise — see README "Setup niri"). Machine files override generic ones by being included last.

## Secrets (sops-nix + age)

- Encrypted store: `secrets/secrets.yaml`; policy in `.sops.yaml` (single age recipient for `secrets/*.yaml`).
  Decrypt target is `$XDG_CONFIG_HOME/sops/...`; identity key must live at `~/.config/sops/age/keys.txt`.
  Convert a public ssh key to age: `ssh-to-age < ~/.ssh/id_ed25519.pub`. Edit/re-encrypt with `sops secrets/secrets.yaml`.
  Declare a new secret in `hm-modules/security/sops.nix`. Never write plaintext secret values into the repo.

## Quirks

- Unfree packages are allow-listed via `allowUnfree` in `nix/vars.nix` (only `unrar`, `obsidian`) —
  adding another non-free pkg means editing that list (enforced in `nix/pkgs.nix`).
- `targets.genericLinux.enable = true` in `hm-modules/core/identity.nix` — **disable on an actual NixOS host**.
- Global theme: catppuccin `mocha`, `autoEnable = true`. `home.stateVersion = "26.05"`; nixpkgs is ~`26.11pre`.
- Neovim config lives in the standalone `nixvim-rei` flake (`/home/gidrex/Projects/nixvim-rei`,
  input in `flake.nix`); this repo only sets `programs.nixvim-rei.enable = true`
  (`hm-modules/termTools/nixvim-rei.nix`). Its Lua + `.luarc.json` (`undefined-global`
  disabled — Neovim provides those globals, not a bug) live there too.
