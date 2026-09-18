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
  unless you commit them or pass `--impure`. `scripts/flake_rebuild.sh` passes `--impure`; `just hm` does not.
- **`FLAKE_MACHINE` env var is required** by `just hm` and `scripts/flake_rebuild.sh` (values: `icelake` or `tigerlake`).
  The Nix modules set it per-machine too (`home.sessionVariables.FLAKE_MACHINE`).

## Commands

- Format + validate (Nix width 120, `niri validate`): `just qa`
- Apply home-manager (new generation, backup previous): `just hm`
- Format + auto-git-backup + rebuild: `scripts/flake_rebuild.sh` — **CAUTION**: by default it `git add -A`,
  commits with `--no-verify`, and **force-pushes to origin**. Set `FLAKE_BACKUP=0` to skip the push step. Requires `gum`.
- There is no `devShell`/`packages` output and no test runner; only `homeConfigurations.<machine>` exists, so
  `nix flake check` is not the meaningful verification — `just qa` then `just hm` (dry eval) is.
- `nixfmt` is not installed by default here; the `just qa` formatter is guarded by `command -v nixfmt`.

## Structure

- `flake.nix` → composes `commonModules` (`home.nix` + everything under `hm-modules/`) with `machines/<name>/default.nix`.
  Machines are an **explicit map** (`flake.nix:112-115`) that `genAttrs` turns into `homeConfigurations`
  (flake.nix:121) — adding a machine needs a flake edit, see `.agents/skills/add-machine/`.
- `home.nix` = shared base (programs, packages, theme, session vars/path).
- `hm-modules/` grouped by area: `termTools/{fish,helix,neovim,yazi}`, `security/`, `wayland/`, `themes/`, `sound/`.
- Modules may depend on custom args injected via `_module.args` in `flake.nix` (flake.nix:53). Example: a module
  declaring `yazi-plugins` in its function args (only works because `flake.nix` supplies it) — don't assume args are global.
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

- Unfree packages are allow-listed via `allowUnfreePredicate` (only `unrar`, `obsidian`) — adding another non-free
  pkg means editing `flake.nix:102`.
- `targets.genericLinux.enable = true` in `home.nix` — **disable on an actual NixOS host**.
- Global theme: catppuccin `mocha`, `autoEnable = true`. `home.stateVersion = "26.05"`; nixpkgs is ~`26.11pre`.
- Neovim Lua lives in `hm-modules/termTools/neovim/lua/`; `.luarc.json` disables `undefined-global` diagnostics
  (Neovim provides those globals — not a real bug).
