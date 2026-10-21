---
name: git-workflow
description: Use when committing, pushing, or fetching in this repo (plain git on main; origin pushes to GitLab+Codeberg via dual pushurls, alt is the Codeberg-only spare).
---

# git workflow of this repo

Plain `git` on branch `main`. Commit and push straight to `main` — agents never use
Jujutsu (`jj` may stay installed for interactive use, but it is not the agent path).

## Remotes (pushDefault=origin + dual pushurls — local config, not committed)

- `origin` (`git@gitlab.com:gidrex/flake-rei.git`) — primary. Two push URLs
  (GitLab, then Codeberg), so bare `git push` publishes to both mirrors at once.
- `alt` = Codeberg (`git@codeberg.org:Gidrex/flake-rei.git`) — spare for
  Codeberg-only fetch/push; normally unused since `origin` already pushes there.

## Standard commit cycle

```sh
git switch main                               # HEAD may be detached; get on main first
git status --short                            # what changed
git add -A && git commit -m "<message>"       # commit on main
git push                                      # → origin: GitLab + Codeberg (dual pushurl)
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
- Dual push is not atomic: if one mirror rejects, the other may still succeed —
  fix with `git pull --rebase`, push again, verify both with `git ls-remote`.
- Commits must not contain plaintext secrets.
