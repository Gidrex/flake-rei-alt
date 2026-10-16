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
    };
  };

  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;

    # node on PATH: ponytail lifecycle hooks are node scripts (non-interactive shell).
    # rtk on PATH: token-saving proxy for agent shell commands (see skills/rtk).
    extraPackages = [
      pkgs.nodejs
      pkgs.rtk
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

  # Force ANSI colors (no `plugins` option, placed directly).
  xdg.configFile."opencode/plugins/force-color.ts".source = ./plugins/force-color.ts;

  # Jev decision skill runtime (non-secret default; key itself stays in sops).
  home.sessionVariables = {
    JEV_LANGUAGE = "en-US";
  };
}
