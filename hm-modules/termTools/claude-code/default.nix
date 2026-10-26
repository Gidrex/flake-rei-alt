# Declarative Claude Code; mirrors hm-modules/termTools/opencode (same skills,
# same global AGENTS.md). MCP servers are kept out of nix by choice: they live in
# ~/.claude.json (user scope, `claude mcp`), toggled per project via `/mcp`.
# Deliberate drift: no providers (Anthropic login), no antigravity-auth, no
# opencode TUI settings; ponytail comes as its native Claude plugin.
{
  config,
  pkgs,
  ...
}:
{
  programs.claude-code = {
    enable = true;
    # Native installer owns the binary (~/.local/bin/claude, `claude update`):
    # nixpkgs lags it and is unfree-gated. HM manages only ~/.claude.
    package = null;

    # Claude Code (/model, /theme) and herdr (its SessionStart hook) write
    # settings.json at runtime, so merge the declared keys on activation instead
    # of a read-only store symlink. Declared keys win, undeclared ones survive.
    mutableSettings = true;

    settings = {
      model = "opus";
      # ANSI palette follows the terminal's catppuccin-mocha.
      theme = "dark-ansi";
      permissions = {
        defaultMode = "auto";
        # Mirrors opencode: CHORA storage only through the `chora` CLI (see
        # skills/chora). Read rules also gate Glob/Grep, Edit rules gate Write.
        deny = [
          "Read(~/CHORA/**)"
          "Edit(~/CHORA/**)"
          "Read(~/.config/chora/**)"
          "Edit(~/.config/chora/**)"
        ];
      };
    };

    # Same global instructions as opencode sessions.
    context = ../opencode/AGENTS.md;

    # Same on-demand skill set as opencode.
    inherit (config.programs.opencode) skills;
  };

  # ponytail ships a native Claude plugin (session hooks, skills, band); its
  # default level is `full`, as AGENTS.md expects. Linked as one directory, not
  # via programs.claude-code.plugins: that wrapper turns hooks/ into a symlink,
  # which Claude Code skips (`claude plugin details ponytail` shows Hooks (0)).
  # Bump: tag + hash.
  home.file."${config.programs.claude-code.configDir}/skills/ponytail".source = pkgs.fetchFromGitHub {
    owner = "DietrichGebert";
    repo = "ponytail";
    tag = "v5.3.2";
    hash = "sha256-IJlhfkdXI6pMZZCZO7XBRg88LBiNfzc5Gnm4ofGybL8=";
  };

  # node/npx on PATH: ponytail hooks are node scripts, npx MCP servers and ctx7 run
  # via npx (rtk/uv are already global in core/packages).
  home.packages = [ pkgs.nodejs ];
}
