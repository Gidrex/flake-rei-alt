---
name: background-agent
description: >-
  Use when the user asks to launch an agent in the background with a prompt
  («запусти агента на фоне», "run an agent in the background"). Starts an
  opencode instance in a new Herdr tab and prompts it via the Herdr agent
  surface. If the user also asks for a report back («дай репорт»,
  "report back"), the worker delivers it into this chat via the Herdr agent
  surface.
---

# background-agent — opencode instance in a new Herdr tab

1. Confirm you are inside Herdr: `test "${HERDR_ENV:-}" = 1`.
   If not — say so and stop.
2. Pin the model via a worker config (never rely on the default model).
   If the user did not specify a model, default to Muse Spark 1.3 contributor
   at effort xhigh:
   `CFG=$(mktemp /tmp/oc-worker-XXXX.json)`
   then write `{"model":"opencode-go/muse-spark-1.3-contributor#xhigh"}` into `$CFG`.
   Selecting this model is what selects the opencode-go key: the
   `opencode-go` provider apiKey resolves from sops via
   `programs.opencode.settings.provider`
   (`hm-modules/termTools/opencode/default.nix`). The custom config merges
   with the global one.
3. Write the full task text into a file — never inline it into a shell command:
   `TASK=$(mktemp /tmp/oc-task-XXXX.md)`
   then `cat > "$TASK" <<'TASK_EOF'`, the task text, `TASK_EOF`.
   Quoted delimiter: no expansion — quotes, dollars, backticks pass through untouched.
   If report-back was requested, append the report-back block below to `$TASK`
   (only the pane ID in it expands in your shell at launch).
4. Open a background tab with that config in its environment (same directory,
   keep user focus):
   `herdr tab create --cwd "$PWD" --label "<short-task-name>" --no-focus --env OPENCODE_CONFIG=$CFG`
   Read the tab ID and `.result.root_pane` pane ID from the JSON response.
5. Start the instance in that pane, always with `--standalone` (without
   it the TUI uses the shared background server, which ignores
   `OPENCODE_CONFIG` and boots the last-used model instead):
   `herdr agent start <name> --kind opencode --pane <pane-id> -- --standalone`
   Append `--auto` only for bounded read-only tasks (audit, inspection).
6. Submit a fixed prompt through the agent surface (no `--wait`, fire-and-forget):
   `herdr agent prompt <name> "Read and execute $TASK"`.
   Nothing user-supplied passes through shell quoting anymore.
7. Report the tab ID. Output is readable any time via
   `herdr agent read <name> --source recent-unwrapped --lines 120`.
   Teardown when done: `herdr tab close <tab-id>` (only tabs you created)
   and `rm -f $CFG $TASK`.

## Report back («дай репорт»)

If the user asked the worker to report back, append this block to the task file
as-is (file content, no shell quoting — only your pane ID goes in):

> When finished: first print the full report in your own output, then
> deliver it to the calling agent with exactly one call:
> `herdr agent prompt <caller-pane-id> "report: <concise report>"`
> (escape double quotes inside; no trailing characters after the closing
> quote — even a period breaks parsing). Run it once, unconditionally: herdr queues
> the message even while the caller is working; only an approval dialog
> rejects it. Do not retry; the printed output stays the report.

For anything beyond start-plus-prompt (waits, lifecycle states, coordination),
run `herdr --skill` and follow it; external skills stay disabled by design,
only repo skills load.
