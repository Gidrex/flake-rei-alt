# Declarative opencode; auth resolves at runtime from sops (path only in store).
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./mcp
    ./plugins
  ];

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
      };
    };
  };

  # TUI prefs (theme, keybinds): HM has no programs.opencode option for
  # cli.json, so the file is managed directly. force replaces the previous
  # hand-maintained ~/.config/opencode/cli.json one time.
  xdg.configFile."opencode/cli.json" = {
    source = ./cli.json;
    force = true;
  };

  # Jev decision skill runtime (non-secret default; key itself stays in sops).
  home.sessionVariables = {
    JEV_LANGUAGE = "en-US";
  };
}
