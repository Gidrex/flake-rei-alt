# Codex agent: same providers, MCP servers, skills and AGENTS.md as opencode.
# Auth: keys load on demand via the `aikeys` fish function (jevkey-style,
# never exported ambiently); settings only name the env vars.
# MCP servers come from programs.mcp.servers (enableMcpIntegration);
# the telegram-mcp daemon itself stays defined in the opencode module.
{ ... }:
{
  programs.codex = {
    enable = true;
    enableMcpIntegration = true;

    # Same global instructions as opencode sessions.
    context = ../opencode/AGENTS.md;

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

    settings = {
      model = "muse-spark-1.3-contributor";
      model_provider = "opencode-go";
      model_providers = {
        opencode-go = {
          name = "OpenCode Go";
          base_url = "https://opencode.ai/inference/go/openai/v1";
          env_key = "OPENCODE_API_KEY";
        };
        openrouter = {
          name = "OpenRouter";
          base_url = "https://openrouter.ai/api/v1";
          env_key = "OPENROUTER_API_KEY";
        };
      };
    };
  };
}
