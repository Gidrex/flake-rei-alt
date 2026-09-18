---
name: verify-hm-change
description: Use when validating any change to this home-manager flake — formatting, nix eval, build checks, FLAKE_MACHINE handling, and the committed-revision visibility trap.
---

# Verifying home-manager flake changes

There is no test suite here and `nix flake check` is irrelevant (only
`homeConfigurations.<machine>` exists). The verification chain is:

```sh
export FLAKE_MACHINE=tigerlake   # or icelake; required
just qa                          # nixfmt (if present) + niri validate
```

## The main trap: nix sees committed `main`, not the working copy

`nix flake metadata ./` resolves to `git+file://...?ref=refs/heads/main&rev=<sha>`.
Consequences:

- Edits to **tracked** files are visible to eval with `--impure`, no commit needed.
- **New (untracked) files** are invisible until they land in the `main` ref.
- The reliable way to make changes visible: commit the jj way
  (see the `jj-git-workflow` skill):
  `jj describe -m ...` + `jj bookmark move main --to @` — this moves the git branch
  `main`, and nix starts seeing everything, including new files.

## Targeted and full eval

```sh
# targeted: a fish function body, a module option, etc.
nix eval --impure ".#homeConfigurations.$FLAKE_MACHINE.config.programs.fish.functions.y.body"

# full eval without building (catches definition conflicts, type errors)
nix build --impure ".#homeConfigurations.$FLAKE_MACHINE.activationPackage" --dry-run
```

If eval complains `path '.../hm-modules/.../<new-file>' does not exist` while the
file is on disk — that is the trap above: the file is untracked, move `main` onto
`@` first. For diagnosis you can copy the tree without `.git`/`.jj` to `/tmp` and
eval it as a plain path flake — every file is visible there.

## Fish specifics

Check a function body from `hm-modules/termTools/fish/*.fish` without nix first:

```sh
{ printf 'function y\n'; cat hm-modules/termTools/fish/y_function.fish; printf 'end\n'; } > /tmp/check.fish
fish -n /tmp/check.fish && echo FISH_SYNTAX_OK
```

## Gotchas

- `just hm` performs a **real** `home-manager switch` (a new system generation),
  not a dry run. Run it only on explicit request.
- `scripts/flake_rebuild.sh` — on request only: needs `gum`, does
  `git add -A` + a `--no-verify` commit + force-push to `origin` (skip the push with
  `FLAKE_BACKUP=0`).
- `nixfmt` is usually not installed here — `just qa` silently skips it (guarded by
  `command -v`); that is not an error.
