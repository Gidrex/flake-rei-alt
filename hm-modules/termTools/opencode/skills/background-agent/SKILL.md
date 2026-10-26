---
name: background-agent
description: >-
  Use when the user asks to launch an agent in the background with a prompt
  («запусти агента на фоне», "run an agent in the background"). Opens a new
  Herdr tab running headless opencode with the prompt. If the user also asks
  for a report back («дай репорт», "report back"), the worker delivers it
  into this chat via the Herdr agent surface.
---

# background-agent — background agent in a new Herdr tab

1. Confirm you are inside Herdr: `test "${HERDR_ENV:-}" = 1`.
   If not — say so and stop.
2. Open a background tab (same directory, keep user focus):
   `herdr tab create --cwd "$PWD" --label "<short-task-name>" --no-focus`.
   Read the tab ID and `.result.root_pane` pane ID from the JSON response.
3. Run headless opencode with the user's prompt in that pane:
   `herdr pane run <pane-id> "opencode run '<prompt>'"`.
   Escape single quotes inside the prompt as `'\''`.
4. Report the tab ID. Output is readable any time via
   `herdr pane read <pane-id> --source recent-unwrapped --lines 120`.

## Report back («дай репорт»)

If the user asked the worker to report back, append this to the worker prompt:

> When finished: first print the full report in your own output, then
> deliver it to the calling agent with exactly one call:
> `herdr agent prompt <caller-pane-id> "report: <concise report>"`
> (escape double quotes inside). If delivery fails — e.g. the caller is at
> an approval dialog — do not retry; the printed output stays the report.

Use `$HERDR_PANE_ID` as `<caller-pane-id>` (agent commands accept the pane ID
of the hosted agent, no rename needed). Fire-and-forget: no `--wait`, the
report arrives in this chat as a new message on its own.

For anything beyond open-tab-plus-run (waits, lifecycle states, coordination),
load the `herdr` skill.
