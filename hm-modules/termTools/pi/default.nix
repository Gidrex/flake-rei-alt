# Pi coding agent: same providers, MCP servers, skills and AGENTS.md as opencode.
# Auth: apiKey uses `!command` so sops files are read at request time;
# nothing secret lands in the store (only the file path, like opencode's {file:}).
{ config, pkgs, ... }:
{
  programs.pi-coding-agent = {
    enable = true;

    # npx for MCP servers + npm for pi packages (uv/rtk already global).
    extraPackages = [ pkgs.nodejs ];

    # Same global instructions as opencode sessions.
    context = ../opencode/AGENTS.md;

    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "muse-spark-1.3-contributor";
      defaultThinkingLevel = "xhigh";
      skills = [
        "${../opencode/skills/python-uv}"
        "${../opencode/skills/typescript-biome}"
        "${../opencode/skills/rust-cargo}"
        "${../opencode/skills/flutter-dart}"
        "${../opencode/skills/nix-hm}"
        "${../opencode/skills/lua-shell}"
        "${../opencode/skills/ctx7-docs}"
        "${../opencode/skills/rtk}"
      ];
    };

    models = {
      providers = {
        # No `models` list here: a bare `{ id = ...; }` replaces the catalog entry
        # and resets contextWindow to pi's 128k default (modelFromJson).
        # The catalog already knows muse-spark-1.3 (1048576 ctx / 131072 max).
        opencode-go = {
          baseUrl = "https://opencode.ai/inference/go/v1";
          api = "openai-responses";
          apiKey = "!cat ${config.sops.secrets.opencode_api_key.path}";
        };
        openrouter = {
          baseUrl = "https://openrouter.ai/api/v1";
          api = "openai-completions";
          apiKey = "!cat ${config.sops.secrets.openrouter_api_key.path}";
          models = [ ];
        };
      };
    };
  };

  # Same MCP servers as opencode (pi reads ~/.pi/agent/mcp.json).
  home.file.".pi/agent/mcp.json".source = ./mcp.json;
}
