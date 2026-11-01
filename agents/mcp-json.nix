{
  config,
  lib,
  pkgs,
}:
(pkgs.formats.json { }).generate "agents-mcp.json" {
  mcpServers = lib.mapAttrs (
    name: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      extraTransforms = [ (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; }) ];
    }
  ) config.programs.mcp.servers;
}
