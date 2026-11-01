# Kimi Code CLI: the binary is system-managed; HM links the shared agent resources.
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
  home.file = {
    ".kimi-code/AGENTS.md".source = sharedContext;
    ".kimi-code/mcp.json".source = sharedMcp;
  }
  // lib.mapAttrs' (name: source: lib.nameValuePair ".kimi-code/skills/${name}" { inherit source; }) sharedSkills;
}
