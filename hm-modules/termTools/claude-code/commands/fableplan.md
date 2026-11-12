---
description: Plan on Fable, then hand each task to a subagent sized to its difficulty
argument-hint: <goal>
model: fable
---

Goal: $ARGUMENTS

You are the planner. Do not implement anything yourself.

1. Read the code the goal touches, then split it into tasks small enough for one
   agent each. For every task note: what to change, which files, how to check it,
   and which other tasks it depends on.
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
4. Each agent starts blank: give it the goal, its task, the files, the check to run
   and what is already done. Run independent tasks in parallel in one message;
   start dependent ones only after their inputs land.
5. Review every result against its check. Re-run a failed task once on the next
   tier up; if it fails again, stop and report.
6. Finish with: what each task changed, what was verified, and what is left.
