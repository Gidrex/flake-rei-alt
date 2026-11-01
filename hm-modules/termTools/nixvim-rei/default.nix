# Wiring point: option + imports. Siblings only act when enabled.
{ lib, ... }:
{
  options.programs.nixvim-rei = {
    enable = lib.mkEnableOption "nixvim-rei Neovim configuration";
  };

  imports = [
    ./core.nix
    ./keymaps.nix
    ./autocmd.nix
    ./ui.nix
    ./pickers.nix
    ./dev.nix
    ./lsp.nix
    ./packages.nix
    ./runtime.nix
  ];
}
