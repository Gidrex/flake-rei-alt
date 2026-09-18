---
name: jj-git-workflow
description: Use when committing, pushing, fetching, or diagnosing branch divergence in this repo (jj colocated on git, remotes origin/Codeberg and gitlab, bookmarks main@origin main@gitlab).
---

# jj + git workflow of this repo

The VCS is Jujutsu (`jj`) colocated on top of git. `git` is only the backend: commits,
bookmarks, and pushes go through `jj`. `trunk() = main@origin`.

## Remotes and defaults (configured locally, not committed)

- `origin` = `ssh://git@codeberg.org/Gidrex/flake-rei.git` — canonical, `trunk()`.
- `gitlab` = `git@gitlab.com:gidrex/flake-rei.git` — secondary.
- `git config remote.pushDefault=gitlab` → bare `git push` goes to GitLab.
- `jj config get git.push` = `gitlab` → bare `jj git push` goes to GitLab.
- `main` tracks both remote bookmarks (`main@origin`, `main@gitlab`), so the default
  push updates whichever remote you push to.

## Standard commit cycle

```sh
jj st                                    # what is in the working copy (@)
jj describe -m "<message>"               # describe the change
jj bookmark move main --to @             # move main onto @ (also updates the git branch main)
jj new                                   # fresh empty @ for the next edits (optional)
jj git fetch --all-remotes               # pull both remotes before pushing
jj git push                              # → gitlab (default)
jj git push --remote origin -b main      # + to origin, if both are needed
```

Raw-git equivalent (reading/pushing only, NEVER committing):

```sh
git push gitlab main:main
```

## Diagnosing divergence

```sh
jj bookmark list --all                   # where main, main@origin, main@gitlab, @git are
git log --oneline --graph --all --decorate -15
git push --dry-run -v                    # where a bare push would really go
jj git push --dry-run                    # what jj would push (and to which remote)
```

Typical pictures:

- `main@gitlab` N commits behind `main` after a local-only backup commit — fixed by a normal push.
- Changes sit in undescribed `@` off `main` — `push main` will NOT send them;
  `describe` + `bookmark move` first.
- `jj git push` says "No bookmarks/tags found in the default push revset" —
  either there is nothing to push (everything in sync) or the bookmark does not
  track that remote (`jj bookmark track main --remote=<name>`).

## Gotchas

- Never `git commit`, `git add -A`, or `git push -f` by hand (commits go through `jj`; pushes never forced).
- Push only on explicit user request.
- `jj` auto-snapshots the working copy on every command; `git status` may show
  staged/unstaged entries as a result — normal for colocated mode, do not touch
  the index by hand.
