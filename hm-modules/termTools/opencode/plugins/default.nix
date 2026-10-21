# TUI sidebar panels (v1 TUI plugins; opencode resolves npm specs itself at startup).
# NOTE: server plugins live in opencode.json `plugin`, TUI plugins live in
# tui.json `plugin` — sidebar slots only render from the latter.
# oc-mcp-plugin-manager deliberately absent: requires OpenCode >= 2.0.16.
{ ... }:
{
  programs.opencode.settings = {
    # Server-side plugins only; TUI panels are in tui.plugin above.
    plugin = [
      "@dietrichgebert/ponytail"
    ];
  };
}
