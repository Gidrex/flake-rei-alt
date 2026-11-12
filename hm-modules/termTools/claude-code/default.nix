# Declarative Claude Code; shared context, skills and MCP live in agents/.
# Deliberate drift: no providers (Anthropic login), no antigravity-auth, no
# opencode TUI settings; ponytail comes as its native Claude plugin.
{
  config,
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
  programs.claude-code = {
    enable = true;
    enableMcpIntegration = true;
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
      # Flicker-free renderer with virtualized scrollback.
      tui = "fullscreen";
      cleanupPeriodDays = 14;
      # No Co-Authored-By trailer, "Generated with" PR line or session link (needs v2.1.281+).
      attribution = false;
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
      # Every Bash call goes through rtk (`git x` -> `rtk git x`), subagents included,
      # so nobody has to remember the rtk skill. The jq merge of mutableSettings is
      # deep: herdr's runtime SessionStart hook survives next to this one.
      hooks.PreToolUse = [
        {
          matcher = "Bash";
          hooks = [
            {
              type = "command";
              command = "${pkgs.rtk}/bin/rtk hook claude";
            }
          ];
        }
      ];
    };

    context = "${sharedContext}";
    skills = sharedSkills;
    # /fableplan: Fable plans, Opus/Sonnet/Haiku subagents execute by difficulty.
    commands.fableplan = ./commands/fableplan.md;
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

  # Commands the rtk hook must leave bare (matched per command, also inside `&&`
  # chains): `just` (rtk truncates the middle of recipe output, hiding which test
  # failed; agents use `rtk err just qa` explicitly), `biome` (rewritten to the
  # ESLint filter), and secret readers (`sops`, `age`, `env`, `printenv`): rtk keeps
  # elided output in its recall store for 30 days. Read-only: tune here, not via
  # `rtk config`.
  xdg.configFile."rtk/config.toml".source = (pkgs.formats.toml { }).generate "rtk-config.toml" {
    hooks.exclude_commands = [
      "just"
      "biome"
      "sops"
      "age"
      "env"
      "printenv"
    ];
    telemetry.enabled = false;
  };

  # node/npx on PATH: ponytail hooks are node scripts, npx MCP servers and ctx7 run
  # via npx (rtk/uv are already global in core/packages).
  home.packages = [ pkgs.nodejs ];
}
