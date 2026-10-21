# Declarative crush; mirrors hm-modules/termTools/opencode (same providers,
# same MCP servers via programs.mcp, same skills, same global AGENTS.md).
# Auth resolves at runtime via $(cat ...) (path only in store).
# Deliberate drift: no ponytail (opencode plugin API has no crush equivalent),
# no TUI theme (crush.json has no theme key), LSP via crush auto_lsp + nil
# already on PATH.
{
  config,
  pkgs,
  ...
}:
{
  programs.crush = {
    enable = true;
    enableMcpIntegration = true;

    settings = {
      providers = {
        # OpenAI-compatible root (same shape as the removed codex module,
        # which spoke this endpoint without protocol complaints).
        "opencode-go" = {
          name = "OpenCode Go";
          type = "openai-compat";
          base_url = "https://opencode.ai/inference/go/openai/v1";
          api_key = "$(cat ${config.sops.secrets.opencode_api_key.path})";
          # No pinned catalog: crush discovers models natively from
          # the provider's /models endpoint using this key.
          discover_models = true;
        };
        openrouter = {
          name = "OpenRouter";
          type = "openrouter";
          base_url = "https://openrouter.ai/api/v1";
          api_key = "$(cat ${config.sops.secrets.openrouter_api_key.path})";
          models = [ ];
        };
      };
      # Single-model setup like pi defaultModel (large AND small explicit).
      models = {
        large = {
          model = "muse-spark-1.3-contributor";
          provider = "opencode-go";
        };
        small = {
          model = "muse-spark-1.3-contributor";
          provider = "opencode-go";
        };
      };
      # Same global instructions as opencode sessions.
      options = {
        global_context_paths = [ "${config.programs.opencode.context}" ];
      };
    };

    # Same on-demand skill set as opencode.
    skills = {
      python-uv = ../opencode/skills/python-uv;
      typescript-biome = ../opencode/skills/typescript-biome;
      rust-cargo = ../opencode/skills/rust-cargo;
      flutter-dart = ../opencode/skills/flutter-dart;
      nix-hm = ../opencode/skills/nix-hm;
      lua-shell = ../opencode/skills/lua-shell;
      ctx7-docs = ../opencode/skills/ctx7-docs;
      jev-agent = ../opencode/skills/jev-agent;
      rtk = ../opencode/skills/rtk;
    };
  };

  # npx for chrome-devtools MCP (rtk/uv are already global in core/packages).
  # Crush has no extraPackages; home.packages lands on the same PATH.
  home.packages = [ pkgs.nodejs ];
}
