# Declarative opencode: nixpkgs binary + managed config, no curl installer.
# Auth for the managed `opencode-go` provider resolves at runtime from the
# sops secret file — only the path lands in the nix store, never the key.
{ config, lib, ... }:
{
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    # Global rules: ./AGENTS.md lands at ~/.config/opencode/AGENTS.md,
    # auto-loaded by every session
    context = ./AGENTS.md;
    settings = {
      # nix owns the binary; self-update would fight the package manager.
      autoupdate = false;
      lsp = true;
      provider = {
        "opencode-go" = {
          options = {
            apiKey = "{file:${config.sops.secrets.opencode_api_key.path}}";
          };
        };
      };
    };
    # Currently selected TUI theme (was only in local TUI state, kv.json).
    # mkForce: catppuccin/nix defaults this to "catppuccin" (mocha flavour).
    tui = {
      theme = lib.mkForce "catppuccin-macchiato";
    };
  };
}
