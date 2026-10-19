# Declarative opencode; auth resolves at runtime from sops (path only in store).
{
  config,
  lib,
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
      # npx comes from pkgs.nodejs in extraPackages below.
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

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    # node on PATH: ponytail lifecycle hooks are node scripts (non-interactive shell).
    # rtk on PATH: token-saving proxy for agent shell commands (see skills/rtk).
    # uv on PATH: ad-hoc uvx runs in agent sessions (telegram-mcp itself
    # runs as the telegram-mcp user daemon, not per-session).
    extraPackages = [
      pkgs.nodejs
      pkgs.rtk
      pkgs.uv
    ];

    # AGENTS.md auto-loaded by every session
    context = ./AGENTS.md;

    # Skills on demand via `skill` tool
    skills = {
      python-uv = ./skills/python-uv;
      typescript-biome = ./skills/typescript-biome;
      rust-cargo = ./skills/rust-cargo;
      flutter-dart = ./skills/flutter-dart;
      nix-hm = ./skills/nix-hm;
      lua-shell = ./skills/lua-shell;
      ctx7-docs = ./skills/ctx7-docs;
      jev-agent = ./skills/jev-agent;
      rtk = ./skills/rtk;
    };
    # TUI theme: macchiato by choice (deliberate drift from global mocha;
    # mkForce wins over catppuccin autoEnable).
    tui = {
      theme = lib.mkForce "catppuccin-macchiato";
    };
    settings = {
      autoupdate = false; # Self-update off: nix owns the binary.
      lsp = true;
      plugin = [ "@dietrichgebert/ponytail" ];
      provider = {
        "opencode-go" = {
          options = {
            apiKey = "{file:${config.sops.secrets.opencode_api_key.path}}";
          };
        };
        "openrouter" = {
          options = {
            apiKey = "{file:${config.sops.secrets.openrouter_api_key.path}}";
          };
        };
        "google" = {
          options = {
            apiKey = "{file:${config.sops.secrets.gemini_api_key.path}}";
          };
          # Non-chat models: no generateContent support, only noise in /models.
          blacklist = [
            "veo-3.1-generate-preview"
            "veo-3.1-fast-generate-preview"
            "veo-3.1-lite-generate-preview"
            "lyria-3-pro-preview"
            "lyria-3-clip-preview"
            "gemini-embedding-001"
            "gemini-embedding-2"
            "gemini-2.5-flash-preview-tts"
            "gemini-2.5-pro-preview-tts"
            "gemini-3.1-flash-tts-preview"
            "gemini-3.1-flash-live-preview"
            "gemini-3.5-live-translate-preview"
          ];
        };
      };
    };
  };

  # Jev decision skill runtime (non-secret default; key itself stays in sops).
  home.sessionVariables = {
    JEV_LANGUAGE = "en-US";
  };
}
