---
name: nix-hm
description: Use when editing a Nix or home-manager flake (modules, packages, options), or running nixfmt, just qa/check, home-manager eval failures.
---

# Nix / home-manager dev cycle

Generic gates for any Nix flake. In **this** repo (`flake-rei`) also load the
repo-local `.agents` skills (`verify-hm-change`, plus `add-hm-module` / `add-machine` /
`niri-machine-config` / `sops-add-secret` / `git-workflow` as matched) — they own
the repo-specific traps.

## 1. Full cycle (every change)

```
1. Explore → read target module + wiring (flake outputs, imports) first
2. Implement → smallest delta, match existing module style
3. Fix loop → nixfmt write → qa → dry-run eval
4. Verify → fmt-check green + eval sees the change (see trap §3)
```

## 2. QA gates (in this order)

```bash
fd -e nix -X nixfmt --width 120            # format write (width 120)
fd -e nix -X nixfmt --check --width 120    # format gate
just qa                                    # = fmt-check + niri validate (this repo)
just check [machine]                       # dry-run eval, no system changes
```

`nix flake check` is not a substitute where the repo defines `just qa` / `just check`.
`just hm` is a **real** `home-manager switch` (new generation) — only on explicit request,
requires `FLAKE_MACHINE=icelake|tigerlake`.

## 3. The committed-revision trap

Nix resolves the flake to committed `main`, not the working tree:

- Tracked-file edits: visible to eval with `--impure` (`just check` uses it), no commit needed.
- **New untracked files**: invisible until they land in `main` — eval fails with
  `path '.../<new-file>' does not exist` while the file is on disk.
- Fix the git way: `git switch main && git add -A && git commit -m ...`, then re-eval.

## 4. Rules

- Unfree packages: extend the `allowUnfree` list explicitly, no silent additions.
- No `_module.args` magic; declare needed args (`vars`, `inputs`, …) explicitly.
- Secrets: never plaintext in repo; wire via sops-nix, never print decrypted values.
