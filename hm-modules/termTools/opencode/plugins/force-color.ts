// Force colorized output for all shell executions (AI tool calls + user terminals).
//
// Most CLI tools strip ANSI colors when stdout is not a TTY; these env vars opt
// back into colors for tools that respect them (chalk/picocolors-based tools,
// BSD ls, etc.). Tools that need an explicit flag (e.g. `grep --color=always`)
// are unaffected — pass the flag in the command itself.
export const ForceColor = async () => {
  return {
    "shell.env": async (_input, output) => {
      output.env.FORCE_COLOR = "1";
      output.env.CLICOLOR_FORCE = "1";
    },
  };
};
