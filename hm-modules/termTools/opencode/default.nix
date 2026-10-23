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

  # Catppuccin targets tui.json, ignored by OpenCode 2; theme lives in programs.opencode.cli.
  catppuccin.opencode.enable = false;

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
    # CLI client settings (OpenCode 2; tui.json is ignored). Mirrors the
    # app-owned cli.json at merge time; HM owns the file, TUI edits do not persist.
    cli = {
      # Macchiato by choice (deliberate drift from global mocha;
      # mkForce wins over catppuccin autoEnable).
      theme = lib.mkForce { name = "catppuccin-macchiato"; };
      plugins = [ "-internal:sidebar-context" ];
      diffs = {
        wrap = "word";
        view = "auto";
      };
      session = {
        sidebar = "auto";
        scrollbar = false;
        thinking = "hide";
        permissions = "prompt";
        tps = true;
      };
      animations = true;
      keybinds = {
        "app.exit" = "ctrl+c,ctrl+d";
        "session.queued_prompts" = "ctrl+q";
        "opencode.status" = "ctrl+s";
        "session.new" = "ctrl+n";
        "session.list" = "ctrl+l";
        "messages.copy" = "ctrl+y";
        "model.list" = "ctrl+m";
        "session.undo" = "ctrl+u";
        "session.timeline" = "ctrl+g";
        "session.export" = "none";
        "terminal.toggle" = "none";
        "terminal.select" = "none";
        "prompt.editor" = "ctrl+e";
        "agent.list" = "ctrl+a";
        "session.sidebar.toggle" = "ctrl+b";
        "session.background" = "none";
        "input.move.left" = "left";
        "prompt.queue" = "none";
      };
      tabs = {
        mode = "off";
        layout = "horizontal";
        indicators = "status";
        scope = "cwd";
      };
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
        "inception" = {
          options = {
            apiKey = "{file:${config.sops.secrets.inceptionlabs_api_key.path}}";
          };
        };
      };
    };
  };

  # Jev decision skill runtime (non-secret default; key itself stays in sops).
  home.sessionVariables = {
    JEV_LANGUAGE = "en-US";
  };
}
