---
description: Plan on Fable, then hand each task to a subagent sized to its difficulty
argument-hint: <goal>
model: fable
---

Goal: $ARGUMENTS

You are the planner. Do not implement anything yourself.

1. Read the code the goal touches, then split it into the fewest tasks that cover
   it, each small enough for one agent. A goal that is one task stays one task: skip
   the list and launch a single agent. For every task note: what to change, which
   files it may edit, how to check it, and which other tasks it depends on.
2. Show the plan as a short list with the tier each task gets (below) and wait for
   the user's go-ahead before launching anything.
3. Launch each task with the Agent tool, passing `model` and `effort` explicitly
   (this command is the instruction that authorizes setting effort):
   - **Opus, effort `high`**: hard work. Design decisions, tricky logic, cross-cutting
     refactors, debugging with an unknown cause, security-sensitive changes.
   - **Sonnet, effort `high`**: manual testing, writing or fixing automated tests,
     reproducing a bug from clear steps.
   - **Sonnet, effort `medium`**: routine code with a clear spec: boilerplate,
     mechanical edits across files, docs, config.
   - **Haiku, effort `medium`**: trivial work. A rename, a one-line fix, a lookup,
     running a command and reporting its output.
   When unsure between two tiers, pick the higher one.
4. Each agent starts blank: give it the goal, its task, the files it may edit, the
   check to run and what is already done. Tell it to stay inside those files and
   never commit or push.
5. Agents share one working tree. Run tasks in parallel (one message) only when
   their file lists do not overlap; run the rest one after another, and start
   dependent tasks only after their inputs land.
6. Do not trust an agent's report. For every finished task read the diff and run
   its check yourself.
7. A failed task is re-run once on the next tier up, with what failed and why in
   the new brief. If it fails again, or it was already on Opus, stop and report.
8. When all tasks are done, run the project's own check for the whole change (its
   QA or test command), since tasks that pass alone can break each other.
9. Finish with: what each task changed, what you verified yourself, and what is
   left.
