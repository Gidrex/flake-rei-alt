# Declarative opencode; auth resolves at runtime from sops (path only in store).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  sharedSkills = import ../../../agents/skills.nix { inherit pkgs; };
  sharedContext = import ../../../agents/context.nix {
    inherit pkgs;
    extra = builtins.readFile ./AGENTS.md;
  };
in
{
  imports = [ ./plugins ];

  # Catppuccin targets tui.json, ignored by OpenCode 2; theme lives in programs.opencode.cli.
  catppuccin.opencode.enable = false;

  # HM owns cli.json; overwrite the app-owned file instead of failing on backup collision.
  xdg.configFile."opencode/cli.json".force = true;

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
      pkgs.android-tools # adb for the (disabled by default) android MCP server
    ];

    # AGENTS.md auto-loaded by every session
    context = "${sharedContext}";

    # Skills on demand via `skill` tool
    skills = sharedSkills // {
      background-agent = ./skills/background-agent;
    };
    # CLI client settings (OpenCode 2; tui.json is ignored). Mirrors the
    # app-owned cli.json at merge time; HM owns the file, TUI edits do not persist.
    cli = {
      # Macchiato by choice (deliberate drift from global mocha;
      # mkForce wins over catppuccin autoEnable).
      theme = lib.mkForce { name = "catppuccin-macchiato"; };
      plugins = [
        "-internal:sidebar-context"
        "./herdr-opencode"
      ];
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
        "app.exit" = "ctrl+c";
        "command.palette.show" = "none"; # hides the "ctrl+p commands" footer hint
        "diff.open" = "ctrl+d";
        "session.delete" = "none";
        "input.delete" = "delete,shift+delete";
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
      model = "opencode-go/muse-spark-1.3-contributor";
      autoupdate = false; # Self-update off: nix owns the binary.
      lsp = false; # Disabled upstream in v2 (no servers run); use lint/typecheck instead.
      # CHORA storage is agent-readable only through the `chora` CLI (see
      # skills/chora); direct file tools stay denied so --max-access cannot
      # be bypassed and index-first navigation is enforced. The chora config
      # itself is denied too, so the configured path is not discoverable
      # through file tools.
      permissions =
        let
          deny = action: resource: {
            inherit action resource;
            effect = "deny";
          };
        in
        [
          (deny "read" "~/CHORA/*")
          (deny "edit" "~/CHORA/*")
          (deny "glob" "*CHORA*")
          (deny "read" "~/.config/chora/*")
          (deny "edit" "~/.config/chora/*")
        ];
      provider =
        builtins.mapAttrs
          (_: secret: {
            options.apiKey = "{file:${config.sops.secrets.${secret}.path}}";
          })
          {
            "opencode-go" = "opencode_api_key";
            "openrouter" = "openrouter_api_key";
            # Temporarily disabled.
            # "vercel" = "vercel_gateway_api_key";
          };
    };
  };
}
