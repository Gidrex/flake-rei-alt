---
name: git-task-flow
description: >-
  Use when starting, committing, pushing, or finishing a coding task in any git
  repository: one branch per task, amend before push, never force-push, merge
  into main only on the user's approval.
---

# git task flow — one branch per task

Plain `git`, never `jj`. A repository's own `AGENTS.md` / project skill wins
where it disagrees with this file (some repos commit straight to `main`).

## Hard rules

- **Never force-push**, anywhere, in any form (`-f`, `--force-with-lease`).
  Consequence: a pushed commit is frozen — never amend or rebase it.
- **`main` moves only on the user's signal** (explicit approval of the task:
  "nice", "all good", "merge it"). Never commit on `main` directly.
- Local commits and pushes **on the task branch** need no permission.
- No `reset --hard`, `clean -fd`, branch deletion of unmerged work, or
  history rewrite of pushed commits without an explicit order.
- Non-interactive commands only: no `rebase -i`, `add -p`, nothing that opens
  `$EDITOR` (always `-m`, `--no-edit`).
- Stage what belongs to the task. `git add -A` only after `git status --short`
  shows nothing foreign. Never commit secrets.

## 1. Start

```sh
git fetch --prune
git switch -c <task-slug> origin/main      # default branch may be master: check
```

Dirty tree that is not yours → stop and ask. Parallel tasks → one worktree
each (`git worktree add ../<repo>-<task-slug> -b <task-slug> origin/main`).

## 2. Work: commit, verify, amend

A commit is **one reviewable logical step** — a reader understands it alone.

1. Finish a step → commit it with a message that says what and why.
2. Then hunt for bugs: run tests, linters, reread your own diff.
3. Fold every fix into the commit it belongs to, while it is unpushed:
   - last commit: `git commit --amend --no-edit`
   - older unpushed commit: `git commit --fixup <sha>` then
     `GIT_SEQUENCE_EDITOR=true git rebase -i --autosquash origin/main`
4. A new logical step → a new commit, not an amend.

Amend in moderation: fewer commits, but never one giant blob. Do not amend an
unrelated change into a commit just to keep the count low. Aim for a branch a
human can review commit by commit.

## 3. Push the task branch

Push only commits that are **finished and clean**: verified, no known bugs, no
fix pending. Unsure → keep it local and keep amending.

```sh
git push -u origin <task-slug>
```

After the push those commits are frozen. A bug found later is a **new commit**
on top (`fix: ...`), not an amend.

## 4. Report and wait

Tell the user what was done, what was verified and how, and what was not
checked. Their remarks → new commits (or amend, if nothing was pushed yet).
Do not touch `main` until they approve.

## 5. Finish (only after approval)

```sh
git fetch --prune
git log --oneline <task-slug>..origin/main          # did main move?
```

**main did not move** → fast-forward:

```sh
git switch main && git merge --ff-only origin/main
git merge --ff-only <task-slug>
```

**main moved** → bring the branch up to date first, then rerun the tests:

- branch never pushed: `git rebase origin/main`, then merge `--ff-only` as above;
- branch pushed (frozen): no rebase. `git switch main &&
  git merge --ff-only origin/main && git merge --no-ff <task-slug>` and resolve
  conflicts in the merge commit.

Then publish and clean up:

```sh
git push                                            # main
git branch -d <task-slug>
git push origin --delete <task-slug>                # if it was pushed
git worktree remove ../<repo>-<task-slug>           # if a worktree was used
```

`git push` of `main` rejected → someone pushed meanwhile: `git fetch`, repeat
step 5. Never force.

## Verify

- `git status -sb` → `## main...origin/main`, nothing ahead or behind.
- `git log --oneline --graph -10` → the task commits are on `main`.
- `git branch -a` → the task branch is gone locally and on the remote.

## Recovery

A bad rebase or amend is undone with `git reflog` +
`git reset --keep <sha>` — on unpushed work only. Anything involving pushed
history: stop and ask.
