# All MCP servers plus the shared telegram-mcp daemon.
{
  config,
  pkgs,
  ...
}:
{
  programs.mcp = {
    enable = true;
    servers = {
      # Binaries come from AUR (wordcraft/gridcraft), absent in nixpkgs.
      # Rarely used: disabled by default, so opencode neither spawns them
      # nor injects their tool schemas into context. Flip `enabled` + `just hm`
      # on the sessions where you need them.
      # No --automation-*-root: defaults already open/save files (verified on .docx).
      wordcraft = {
        enabled = false;
        command = "wordcraft-cli";
        args = [ "mcp" ];
      };
      gridcraft = {
        enabled = false;
        command = "gridcraft-cli";
        args = [ "mcp" ];
      };
      # Telegram userbot (chigwell/telegram-mcp, pinned) via one shared local
      # daemon: per-session stdio collides on the Telethon session lock
      # (AuthKeyDuplicatedError), so all sessions share the daemon below
      # over streamable HTTP. No command/secrets here — just the URL.
      telegram = {
        enabled = false;
        url = "http://127.0.0.1:8765/mcp";
      };
      # Browser automation (ChromeDevTools/chrome-devtools-mcp, npm).
      # Disabled by default: needs local Chrome, spawns npx per session.
      # npx comes from pkgs.nodejs in programs.opencode extraPackages.
      # Host chromium (Arch /usr/bin/chromium): the MCP defaults to
      # /opt/google/chrome/chrome (stable channel), absent here.
      chrome-devtools = {
        enabled = false;
        command = "npx";
        args = [
          "-y"
          "chrome-devtools-mcp@latest"
          "--executablePath"
          "/usr/bin/chromium"
        ];
      };
    };
  };

  # Single telegram-mcp instance for every opencode session (streamable HTTP).
  # Secrets reach the daemon only through the sops-rendered env file (0400);
  # nothing secret lands in the nix store.
  sops.templates."telegram-mcp.env" = {
    content = ''
      TELEGRAM_API_ID=${config.sops.placeholder.telegram_api_id}
      TELEGRAM_API_HASH=${config.sops.placeholder.telegram_api_hash}
      TELEGRAM_SESSION_STRING=${config.sops.placeholder.telegram_session_string}
    '';
    path = "${config.xdg.configHome}/telegram-mcp/env";
  };

  systemd.user.services.telegram-mcp = {
    Unit = {
      Description = "Telegram MCP shared daemon (streamable HTTP for opencode)";
      After = [ "network.target" ];
    };
    Service = {
      ExecStart = "${pkgs.uv}/bin/uvx --from git+https://github.com/chigwell/telegram-mcp.git@v3.2.83 telegram-mcp";
      Environment = "MCP_TRANSPORT=http MCP_HOST=127.0.0.1 MCP_PORT=8765";
      EnvironmentFile = config.sops.templates."telegram-mcp.env".path;
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
