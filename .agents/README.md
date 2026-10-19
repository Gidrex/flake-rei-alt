# .agents — how to manage the agent in this repository

This is a home-manager flake (dotfiles, not an app): edits here become live system
changes after `home-manager switch`. Details live in root `AGENTS.md` — that file is
authoritative. This directory is the operational layer: how to assign tasks and which
skills to load.

## How to assign a task to the agent

1. **Name the machine for apply/verify tasks.** `FLAKE_MACHINE=tigerlake|icelake`
   is required by `just hm` and `setup_niri.sh`.
2. **State the done criterion.** "Done" here means: `just qa` is green plus
   `nix eval`/`nix build --dry-run` sees the changes (see the `verify-hm-change` skill).
   A task is not closed without verification.
3. **Say whether applying is allowed.** By default the agent only edits files and
   verifies via eval. `just hm` (real switch) and `git push` — only on explicit request.

## Hard rules (non-negotiable)

- Commits: plain `git` on `main` (`git switch main` first — HEAD may be detached),
  push straight to `main`. Agents never use `jj`.
- No pushes (to `origin` or `gitlab`) without an explicit request.
- Secrets: never write plaintext values into the repo and never print decrypted
  `secrets/secrets.yaml` content into chat. New secrets only via the `sops-add-secret` skill.
- Do not edit `~/.config/niri` directly — those are symlinks into `dotfiles/niri/`.
- Do not touch `dotfiles/.unused/` (archive of old configs).
- Do not invent URLs or facts about external services — verify by reading files/command output.

## Skill map (`skills/<name>/SKILL.md`)

| Task | Skill |
|---|---|
| Commit, push, or fetch on `main` (remotes: Codeberg `origin`, GitLab mirror) | `git-workflow` |
| Validate a change: `qa`, eval, build, the committed-revision visibility trap | `verify-hm-change` |
| Add/change a home-manager module, fish function, yazi plugin, package set | `add-hm-module` |
| Edit niri layout/binds/autostart (generic vs machine) | `niri-machine-config` |
| Add a new secret via sops-nix + age | `sops-add-secret` |
| Add a new machine (`machines/<name>`) | `add-machine` |

Load a skill in full when the task matches its frontmatter trigger (`description`).
For cross-cutting tasks load both (e.g. `add-machine` + `niri-machine-config`).

## How to add a new skill

- Format: `SKILL.md` with YAML frontmatter (`name`, `description`), then markdown.
  `description` is the trigger: write WHEN to load the skill.
- A skill = concrete commands and checks for this repo, not general advice.
  Required: steps, exact commands, gotchas, how to verify the result.
- Reference files with line numbers (`flake.nix:112`) and verify them by reading
  before writing — remotes drift: confirm with `git remote -v` (`origin` =
  Codeberg canonical, `gitlab` = secondary mirror).
