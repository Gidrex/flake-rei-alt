
## Claude Code skills

Load `ponytail` (ultra) at session start and follow it for the whole session;
it stays active until the user says "stop ponytail" or "normal mode".

## rtk in Claude Code

A PreToolUse hook already routes every Bash command through rtk: write commands
bare, do not prefix `rtk` and do not load the `rtk` skill for it. The hook leaves
these bare: `just`, `biome`, `sops`, `age`, `env`, `printenv`.

- Project gates (`just qa`, `just test`, ...): `rtk err just <recipe>` gives
  failures only with the exit code kept; bare `just <recipe>` for the full log.
- `[full output: rtk recall <id>]` marks shortened output: `rtk recall <id>`
  shows the rest; `rtk bypass <cmd>` runs one command unfiltered.
