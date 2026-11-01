# Pi coding agent: shared context, skills and MCP live in agents/.
# Auth: apiKey uses `!command` so sops files are read at request time;
# nothing secret lands in the store (only the file path, like opencode's {file:}).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  sharedSkills = import ../../../agents/skills.nix { inherit pkgs; };
  sharedContext = import ../../../agents/context.nix { inherit pkgs; };
  sharedMcp = import ../../../agents/mcp-json.nix { inherit config lib pkgs; };
in
{
  programs.pi-coding-agent = {
    enable = true;

    # npx for MCP servers + npm for pi packages (uv/rtk already global).
    extraPackages = [ pkgs.nodejs ];

    context = "${sharedContext}";

    settings = {
      defaultProvider = "opencode-go";
      defaultModel = "muse-spark-1.3-contributor";
      defaultThinkingLevel = "xhigh";
      skills = map toString (lib.attrValues sharedSkills);
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

  # Pi reads ~/.pi/agent/mcp.json.
  home.file.".pi/agent/mcp.json".source = sharedMcp;
}
