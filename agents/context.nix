{
  pkgs,
  extra ? "",
}:
pkgs.writeText "agents-global-context.md" (builtins.readFile ./AGENTS.md + extra)
