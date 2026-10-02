# Neovim via NixVim (nixpkgs only). Wiring: logic lives in sibling modules.
{
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
