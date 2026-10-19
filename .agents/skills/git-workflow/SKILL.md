---
name: git-workflow
description: Use when committing, pushing, or fetching in this repo (plain git on main; remotes origin/Codeberg canonical and gitlab mirror).
---

# git workflow of this repo

Plain `git` on branch `main`. Commit and push straight to `main` — agents never use
Jujutsu (`jj` may stay installed for interactive use, but it is not the agent path).

## Remotes

- `origin` = Codeberg (`git@codeberg.org:Gidrex/flake-rei.git`) — canonical, bare `git push` goes here.
- `gitlab` (`git@gitlab.com:gidrex/flake-rei.git`) — secondary mirror, push explicitly.

## Standard commit cycle

```sh
git switch main                               # HEAD may be detached; get on main first
git status --short                            # what changed
git add -A && git commit -m "<message>"       # commit on main
git push                                      # → origin
git push gitlab main                          # → gitlab mirror
```

Session ran long? `git fetch --all --prune` before pushing. If push is rejected
(diverged), `git pull --rebase`, resolve, push again. Never `push -f`.

## Diagnosing divergence

```sh
git status -sb                                # must show ## main...origin/main
git log --oneline --graph --all --decorate -15
```

## Gotchas

- Push only on explicit user request.
- Commits must not contain plaintext secrets.
