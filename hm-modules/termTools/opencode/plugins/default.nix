# TUI sidebar panels (v1 TUI plugins; opencode resolves npm specs itself at startup).
# NOTE: server plugins live in opencode.json `plugin`, TUI plugins live in
# tui.json `plugin` — sidebar slots only render from the latter.
# oc-mcp-plugin-manager deliberately absent: requires OpenCode >= 2.0.16.
{ config, ... }:
{
  programs.opencode.tui = {
    plugin = [
      "@oh-my-sidebar/opencode-session-tokens"
    ];
    # Hide the built-in Context sidebar section (tokens / % used / $ spent).
    plugin_enabled = {
      "internal:sidebar-context" = false;
    };
  };

  programs.opencode.settings = {
    # Server-side plugins only; TUI panels are in tui.plugin above.
    plugin = [
      "@dietrichgebert/ponytail"
      # Google OAuth via Antigravity proxy. Models are configured separately
      # in settings.provider after `opencode auth login` (see README).
      "opencode-antigravity-auth@latest"
    ];
  };

  # Antigravity OAuth accounts (opencode-antigravity-auth reads this path).
  # NOTE: the plugin updates lastUsed/tokens in place; `just hm` re-renders
  # this file from sops. If auth breaks after a switch, re-login and refresh
  # the sops values.
  sops.templates."antigravity-accounts.json" = {
    mode = "0600";
    path = "${config.xdg.configHome}/opencode/antigravity-accounts.json";
    content = builtins.toJSON {
      version = 4;
      accounts = [
        {
          email = config.sops.placeholder.antigravity_account_email;
          refreshToken = config.sops.placeholder.antigravity_account_refresh_token;
          addedAt = 1792395547095;
          lastUsed = 0;
          enabled = true;
        }
      ];
      activeIndex = 0;
      activeIndexByFamily = {
        claude = 0;
        gemini = 0;
      };
    };
  };
}
